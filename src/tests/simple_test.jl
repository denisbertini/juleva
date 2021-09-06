#module juleva

export @safe_cfunction

macro safe_cfunction(f, rt, args)
  return esc(:(@cfunction($f, $rt, $args), $rt, [$(args.args...)]))
end



# Add the C library to PATH
const mylib=joinpath(pwd(),"../C","libgen.so")
# Arguments
argv=["-c sc"]

fpi = convert(Float64,π)
# Parameters
x = Array{Float64,1}(undef,3)
y = Array{Float64,1}(undef,3)

xs = [0.; 0.; 0.]
xl = [0.; 0.; 0.]
xu = [fpi; fpi; fpi]



mutable struct GOpts
    algo :: Cint
    dim  :: Cint
    x_s  :: Ptr{Cdouble}  
    x_l  :: Ptr{Cdouble}
    x_u  :: Ptr{Cdouble}
    iter :: Cint
    retRes :: Ptr{Cdouble}
    retErr :: Ptr{Cdouble}
    func  :: Ptr{Cvoid}
    GOpts() = new(-1,-1,C_NULL,C_NULL,C_NULL,-1,C_NULL,C_NULL,C_NULL)
end



function integrand(x::Ptr{Float64},dim::Ptr{Float64},params::Ptr{Float64})
    A = 1.0 / (pi * pi * pi)
    return 3*A / (1.0 - cos(unsafe_load(x,1))*cos(unsafe_load(x,2))*cos(unsafe_load(x,3)))::Cdouble
end



function get_ptr(f::Function)
    integrand_c = @cfunction( $f , Cdouble,(Ptr{Cdouble},Ptr{Cdouble},Ptr{Cdouble}))
#    cf =  Base.cconvert(Ptr{Cvoid}, integrand_c)
#    GC.@preserve cf begin
#        fptr = Base.unsafe_convert(Ptr{Cvoid}, cf)
#    end
    #    return fptr
    return integrand_c
end



# Init options
g_opts = GOpts()
g_opts.algo = 2
g_opts.dim = 3
println(g_opts.dim)
g_opts.iter = 10
g_opts.retRes = pointer(x)
g_opts.retErr = pointer(y)
g_opts.x_s = pointer(xs)
g_opts.x_l = pointer(xl)
g_opts.x_u = pointer(xu)

function TestCallBackFunc(f::Ptr{Cvoid}, o::GOpts)
    g_opts.func = f
    dump(g_opts)
    return ccall((:g_optimize2,mylib),Int32,(Int32,Ptr{Ptr{UInt8}},Ref{GOpts}),length(argv), argv, Ref(g_opts))  
end

function f end

function g(func::Function, o::GOpts)
    f = func
    return TestCallBackFunc(
        @cfunction(f,Cdouble,(Ptr{Cdouble},Ptr{Cdouble},Ptr{Cdouble}))
        , o)
end


function f(x::Ptr{Float64},dim::Ptr{Float64},params::Ptr{Float64})
    A = 1.0 / (pi * pi * pi)
    return 3*A / (1.0 - cos(unsafe_load(x,1))*cos(unsafe_load(x,2))*cos(unsafe_load(x,3)))::Cdouble
end


g(f, g_opts)





#test(g_opts)

