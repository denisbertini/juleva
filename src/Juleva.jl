module Juleva

#include("Gopts.jl")
using ..Gopts

export optimize, Algorithm, ea, gd, ps, sa, swarm

# Add the C library to PATH
global const mylib=joinpath(pwd(),"C","libgen.so")

@enum Algorithm begin
    ea
    gd
    ps
    sa
    swarm
end

function f_callback(p::Ptr{Cvoid}, f_::Ptr{Cvoid})
    f = unsafe_pointer_to_objref(f_)::Function
    f(p)::Ptr{Cvoid}
end

#enter stuff via a GOpts object
function optimize(o::GOpts, x::Vector{Cdouble}, argv::Vector{String})
    if (length(x) != o.dim)
        throw(BoundsError())
    end
    o.x_s = pointer(x)
    ccall((:g_optimize2,mylib)
          ,Int32,(Int32,Ptr{Ptr{UInt8}}, Ref{GOpts})
          ,length(argv), argv, Ref(o))
    return (unsafe_load(o.retRes), unsafe_load(o.retErr))  
end

# f has to be a function already turned into a cfunction, since it is not possible to dynamically convert a function depending on it's
# amount of parameters and their type
function optimize(f::Ptr{Cvoid}, lower::Vector{Cdouble}, upper::Vector{Cdouble}, algorithm::Vector{Algorithm}, dim::Int64, start::Vector{Cdouble}; kwargs...)
    opts = GOpts()
    opts.dim = Int32(dim)
    opts.x_l = pointer(lower)
    opts.x_u = pointer(upper)
    opts.func = f
    argv = Vector{String}()

    arg_algo = "";
    for x in algorithm
        if length(arg_algo) != 0
            arg_algo = arg_algo * ","
        end
        arg_algo = arg_algo * string(x)
    end
    arg_algo = "-a " * arg_algo
    push!(argv, arg_algo)

    println(argv)
    if(length(start) != dim) 
        throw(BoundsError())
    end

    sleep(10)
    opts.x_s = pointer(start)
    ccall((:g_optimize2,mylib)
          ,Int32,(Int32,Ptr{Ptr{UInt8}}, Ref{GOpts})
          ,length(argv), argv, Ref(opts))
    return (unsafe_load(opts.retRes), unsafe_load(opts.retErr), unsafe_load(opts.iter), unsafe_load(opts.algo))
end

end
    
