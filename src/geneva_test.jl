#using Pkg
#pkg"activate ."

push!(LOAD_PATH, pwd(),"C")

include("Gopts.jl")
using .Gopts
include("Juleva.jl")
using .Juleva

# Avoid ambiguity 
fpi = convert(Float64,π)

# Parameters
x = Array{Float64,1}(undef,3)
y = Array{Float64,1}(undef,3)

xs = [0.; 0.; 0.]
xl = [0.; 0.; 0.]
xu = [fpi; fpi; fpi]

function integrand(x::Ptr{Float64},dim::Ptr{Float64},params::Ptr{Float64})
  A = 1.0 / (pi * pi * pi)
  return 3*A / (1.0 - cos(unsafe_load(x,1))*cos(unsafe_load(x,2))*cos(unsafe_load(x,3)))::Cdouble
end

# Init options
g_opts = GOpts()
g_opts.algo = 2
g_opts.dim = 3
g_opts.iter = 10
g_opts.retRes = pointer(x)
g_opts.retErr = pointer(y)
g_opts.x_s = pointer(xs)
g_opts.x_l = pointer(xl)
g_opts.x_u = pointer(xu)
g_opts.func = @cfunction(integrand,Cdouble,(Ptr{Cdouble},Ptr{Cdouble},Ptr{Cdouble}))


println(g_opts.dim)

res = optimize(g_opts, [0.1,0.2,0.3])

println(res)

