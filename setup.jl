@info "Getting ready..."
using Pkg
@info "Installing packages..."
Pkg.instantiate()
@info "Package installation finished."

#see if OpenAI key is present in ENV 
@info "Looking for an OpenAI API key..."
if haskey(ENV, "OPENAI_API_KEY")
    @info "I found an OpenAI key in your Julia environment. You shouldn't need to do anything else."
else
    @warn """
    I couldn't find an OpenAI key in your Julia environemt.
    This is normally found in ~/.julia/config/startup.jl.
    See https://docs.julialang.org/en/v1/manual/environment-variables/ for more details.
    You need to set this before using the script to generate questions.
    """
end

