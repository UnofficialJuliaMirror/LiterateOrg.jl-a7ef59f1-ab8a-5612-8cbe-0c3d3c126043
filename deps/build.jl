println("Building LiterateOrg.jl")

# Bootstrap package by extracting all package code to a Julia file and
# include it.

src_file = joinpath(Pkg.dir("LiterateOrg"), "src", "LiterateOrg.org")

build_dir = joinpath(Pkg.dir("LiterateOrg"), "deps", "build")
mkpath(build_dir)
bootstrap_file = joinpath(build_dir, "bootstrap.jl")

start_code_pat = r"[ ]*#\+begin_src[ ]+julia(.*)"
end_code_pat = r"[ ]*#\+end_src"

println("Bootstrapping LiterateOrg.jl to $(bootstrap_file)")

code_mode = false

open(src_file) do infile
    open(bootstrap_file, "w") do outfile
        for line in readlines(infile)
            global code_mode
            if ismatch(start_code_pat, lowercase(line))
                code_mode = true
                continue
            elseif ismatch(end_code_pat, lowercase(line))
                code_mode = false
                continue
            end
            code_mode && write(outfile, "$(line)\n")
        end
    end
end

println("Running bootstrap file")

# This is necessary for included test expressions to work.
using Base.Test
include(bootstrap_file)
rm(bootstrap_file)

println("Tangling LiterateOrg.jl")

tangle_package(src_file, "LiterateOrg")