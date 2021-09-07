module Juleva

#include("Gopts.jl")
using ..Gopts

export optimize

# Add the C library to PATH
global const mylib=joinpath(pwd(),"C","libgen.so")
# Arguments
global argv=["-h\0"]

function f_callback(p::Ptr{Cvoid}, f_::Ptr{Cvoid})
    f = unsafe_pointer_to_objref(f_)::Function
    f(p)::Ptr{Cvoid}
end


function optimize(f::Function)
    return Symbol(f)  
end


function optimize_t(f::Function, o::GOpts, x::Vector{Cdouble})
    if (length(x) != o.dim)
        throw(BoundsError())
    end
   f_ = unsafe_pointer_to_objref(f)::Function
    o.x_s = pointer(x)
    f_ptr = @cfunction( $f_ 
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



end
    
