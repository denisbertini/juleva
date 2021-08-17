module Gopts

export GOpts

mutable struct GOpts
    algo :: Cint
    dim  :: Cint
    x_s  :: Ptr{Cdouble}  
    x_l  :: Ptr{Cdouble}
    x_u  :: Ptr{Cdouble}
    iter :: Cint
    retRes :: Ptr{Cdouble}
    retErr :: Ptr{Cdouble}
    func   :: Ptr{Cvoid}
    GOpts() = new(-1,-1,C_NULL,C_NULL,C_NULL,-1,C_NULL,C_NULL,C_NULL)    
end


end
