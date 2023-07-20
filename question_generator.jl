using OpenAI, HTTP, ProgressMeter
const key = ENV["OPENAI_API_KEY"]

const model = "gpt-3.5-turbo"

#= PROMPT FORMAT 
(Prompt intro) Write an SAT critical reasoning question on the following prompt. Be sure to offer four choices, the correct answer, and an explanation of the correct answer:

"~~~~~~excerpt~~~~~~~~~~"
=# 

const prompt_intro = """
For the following prompt, write an SAT critical reasoning question. Be sure to offer four choices, the correct answer, and an explanation of the correct answer:

"""


#= QUESTION FORMAT
(Question number) Question 1: (Question Intro) Consider the following prompt and answer the question below:

~~~~~~~~prompt~~~

Which of the following....
A)
B)
C)
D)

Answer: A

Explanation: ~~~~~~~explanation~~~~~~~
=#

function generate_question_number(N)
    "Question $(N): "
end

const question_intro = """
Consider the following prompt and answer the question below:
"""

const SLEEP_SECONDS = 40

function generate_prompt(excerpt)
    prompt_intro * excerpt
end


function word_count(string)
    length(split(string, (' ','\n','\t','-','.',',',':','_','"',';','!'); keepempty = false))
end

text_paths = "texts/" .* readdir("texts/")
text_titles = replace.(text_paths, ".txt" => "")

function generate_many_questions(text_path, section, N, n_weeks)
    #generates all the questions for week N 
    #text path: path of complete text
    #section: which quarter of the book to search in 
    #N: number of Questions to generate
    @info "Gathering paragraphs..."
    output = "$(replace(text_path, ".txt" => "")) SAT questions\n"

    text = read(text_path, String)
    #fix non-ascii possibilities
    text = replace(text, !isascii=> "")
    sentences = split(text, ". ") .* ". "
    n_sentences = length(sentences)
    n_sentences_per_section = n_sentences ÷ n_weeks
    section_sentences = @view sentences[n_sentences_per_section*(section - 1) + 1 : n_sentences_per_section * section]

    @info "Starting to fetch responses..."
    it = Base.Stateful(section_sentences)
    @showprogress for n in 1:N

        excerpt = ""
        while word_count(excerpt) < 130
            if !isempty(it)
                excerpt *= popfirst!(it)
            else
                @warn "ran out of sentences to use."
                @goto escape_excerpt_gen 
            end
        end
        prompt = generate_prompt(excerpt)
        r = nothing
        try 
            r = create_chat(
                key, 
                model,
                [Dict("role" => "user", "content"=> prompt)]
            )
        catch e 
            if typeof(e) <: HTTP.Exceptions.StatusError && e.status == 429 
                @warn "Too many requests. Sleeping for $SLEEP_SECONDS seconds..."
                sleep(SLEEP_SECONDS)
            elseif typeof(e) <: HTTP.Exceptions.StatusError && e.status == 400
                @warn "status 400 error. Problem a malformed prompt. Printing:"
                println("Prompt:\n" * prompt)
                continue
            end
            r = create_chat(
            key, 
            model,
            [Dict("role" => "user", "content"=> prompt)]
            )   
            
        end
        answer = r.response[:choices][begin][:message][:content]
        output *= generate_question_number(n) * question_intro * excerpt * "\n\n" * answer * "\n\n"
    end
    @label escape_excerpt_gen

    return output
end


function create_all_weeks(tup)
    title, answers_dir, text_dir, N, week_range = tup 
    if !isdir(answers_dir)
        @info "Creating answers directory for $title..."
        mkdir(answers_dir)
    end
    n_weeks = maximum(week_range) #hack! need to support week_range = 4:5 etc
    for week in week_range
        @info "Starting $title week $week..."
        output = generate_many_questions(text_dir, week, N, n_weeks)
        open(answers_dir * "$(title)_week_$(week).txt", "w") do io
            write(io, output)
        end
        @info "Text written sucessfully."
    end
    @info "Completed all questions for $title"
end

data = [
    #("calpurnia", "answers/calpurnia/", "texts/calpurnia.txt", 15, 1:4),
    ("balloons", "answers/balloons/", "texts/balloons.txt", 15, 1:4),
    ("algernon", "answers/algernon/", "texts/algernon.txt", 15, 1:4),
    #("julius_caesar", "answers/julius_caesar/", "texts/julius_caesar.txt", 15, 1:4)
]


create_all_weeks.(data)