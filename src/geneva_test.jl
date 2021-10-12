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

xs = [-1.4; -2.2; -3.3]
xl = [-100.; -100.; -100.]
xu = [100.; 100.; 100.]


function integrand(x::Ptr{Float64},dim::Int32)
  A = 1.0 / (pi * pi * pi)
  product = 1
  for value in 1:dim
    product*= cos(unsafe_load(x,value))
  end
  return 3*A / (1.0 - product)::Cdouble
end

c_integrand = @cfunction(integrand,Cdouble,(Ptr{Cdouble},Cint))

function sphere(x::Ptr{Float64}, dim::Int32) 
  y = 0.
  for value in 1:dim
    y += unsafe_load(x, value)^2
  end
  return y::Cdouble
end

c_sphere = @cfunction(sphere,Cdouble,(Ptr{Cdouble},Cint))

function rastigrin(x::Ptr{Float64}, dim::Int32)
  f_pi = convert(Float64,pi)
  y = 0.
  for value in 1:dim
    rast = unsafe_load(x, value)^2 - 10*cos(2*f_pi*unsafe_load(x,value))
    y += rast
  end
  y += 10*dim
  return y::Cdouble 
end

c_rastigrin = @cfunction(rastigrin,Cdouble,(Ptr{Cdouble},Cint))

function rosenbrock(x::Ptr{Float64}, dim::Int32)
  if dim < 2
    throw("Dimension too small")
  end
  y = 0.
  for value in 1:dim-1
    rosen = 100*((unsafe_load(x,value+1) - unsafe_load(x,value)^2)^2) + (1 - unsafe_load(x,value))^2
    y += rosen
  end
  return y::Cdouble
end

c_rosenbrock = @cfunction(rosenbrock,Cdouble,(Ptr{Cdouble},Cint))

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
g_opts.func = @cfunction(rosenbrock,Cdouble,(Ptr{Cdouble},Cint))


println(g_opts.dim)
res = optimize(g_opts, xs, ["-a ea,gd"])
#res = optimize(c_integrand, xl, xu, [ea,gd], 3, xs)

println(res)

