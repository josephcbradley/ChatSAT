# ChatSAT
## A simple script to generate SAT questions. 

### Setup
1. Install [Julia](https://julialang.org/downloads/). Any verion >= 1.8 should work.

2. Get an [OpenAI API key](https://platform.openai.com/account/api-keys) and save it in your Julia environment (```~/.julia/config/startup.jl```) as ```ENV["OPENAI_API_KEY"] = "123456789abcdefg"``` etc.

3. Clone this repo, cd into the folder and create folders for your input texts and arguments:

``` 
cd ~
git clone https://github.com/josephcbradley/ChatSAT
cd ChatSAT
mkdir texts answers
```

4. Install the relevant packages by running 

```julia --project=. setup.jl```

at the command line. You should then be ready to go.

### Creating questions

1. Drop texts into ```texts/```, e.g. ```texts/gatsby.txt```. The script assumes everything is a ```.txt```. 

2. Open ```question_generator.jl```. Edit around line 149 - this is the input for the script. 

3. Each line in ```data``` should be a five-tuple that contains:
    1. the 'title' of the text, 
    2. the directory in which to write the answers, 
    3. the directory in which to read the texts, 
    4. the number of questions to generate per 'week',
    5. the sections of the book from which to generate questions. The largest number is ```N```, the number of 'weeks' that the book will be divided into.

There are some examples in the code already. 

4. Run ```julia --project=. question_generator.jl``` and you should be good to go!

### How It Works & Troubleshooting

The script works by dividing the lines of the ```.txt``` file into ```N``` sections, the idea being that you might want to study one quarter of the book in one week. or similar. So if you use ```1:4``` as your sections, the script will divide the book into quarters and generate questions for each quarter. If you used ```[1, 5]```, the scroipt will divide the book into five sections but only generate questions for sections one and five.

The script is quite dumb - it starts with a 'blank' excerpt, and keeps adding linkes from the section in question until there are at least 130 words in the excerpt. It then turns the excerpt into a prompt for ChatGPT, and sends the request. The request is read back (assuming there are no errors) and written to the output file. 

If OpenAI says you're making too many requests, the script will sleep for 40 seconds. This is enough in my experience. 