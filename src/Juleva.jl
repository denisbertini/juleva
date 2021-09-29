module Juleva

#include("Gopts.jl")
using ..Gopts

export optimize

# Add the C library to PATH
global const mylib=joinpath(pwd(),"C","libgen.so")
# Arguments
global argv=["-a ea,gd"]

function f_callback(p::Ptr{Cvoid}, f_::Ptr{Cvoid})
    f = unsafe_pointer_to_objref(f_)::Function
    f(p)::Ptr{Cvoid}
end


function optimize(f::Function)
    c = @cfunction($f, Cdouble, (Ptr{Cdouble},Ptr{Cdouble},Ptr{Cdouble}))
    return typeof(c)  
end


function optimize(f::Function, o::GOpts, x::Vector{Cdouble})
    if (length(x) != o.dim)
        throw(BoundsError())
    end
    o.x_s = pointer(x)
    f_ptr = @cfunction( $f
        ,Cdouble,(Ptr{Cdouble},Ptr{Cdouble},Ptr{Cdouble}))
    lk=ReentrantLock()
    begin
        lock(lk)
        try
            
            GC.@preserve f_ptr ccall((:g_optimize,mylib),Int32,(Int32,Ptr{Ptr{UInt8}}
                                                                ,Ptr{Cvoid},Ref{GOpts}),length(argv), argv
                                     ,Base.unsafe_convert(Ptr{Cvoid},f_ptr), Ref(o))
        finally
            unlock(lk)
        end
    end
        
    return (o.retRes)  
end


function optimize(o::GOpts, x::Vector{Cdouble})
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
function optimize(f::Ptr{Cvoid}, lower::Vector{Cdouble}, upper::Vector{Cdouble}, algorithm::Int64, dim::Int64, start::Vector{Cdouble}, argv::Vector{String}; kwargs...)
    opts = GOpts()
    opts.dim = Int32(dim)
    opts.x_l = pointer(lower)
    opts.x_u = pointer(upper)
    opts.algo = Int32(algorithm)
    opts.func = f
    if(length(start) != dim) 
        throw(BoundsError())
    end
    opts.x_s = pointer(start)
    ccall((:g_optimize2,mylib)
          ,Int32,(Int32,Ptr{Ptr{UInt8}}, Ref{GOpts})
          ,length(argv), argv, Ref(opts))
    return (unsafe_load(opts.retRes), unsafe_load(opts.retErr), unsafe_load(opts.iter), unsafe_load(opts.algo))
end

end
    
