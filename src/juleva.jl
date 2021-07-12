module juleva

# Add the C library to PATH
global const mylib=joinpath(pwd(),"libgen.so")
# Arguments
global argv=["-h"]

export writeArray

# call geneva_run
#ccall((:geneva_run,"libgen.so"),Int32,(Int32, Ptr{Ptr{UInt8}}), length(argv), argv)

# Objective

mutable struct MyArray
    # Holds a pointer to an (m,n)-array
    m :: Cint
    n :: Cint

    data :: Ptr{Cdouble}

    # Constructor initializes empty Array
    MyArray() = new(-1,-1,C_NULL)
end


function writeArray(m :: T, n :: T) where {T<:Int}

    # Write array 'sourceArray' in MyArray.A
    
    # set up a Float64 (Cdouble) array
    sourceArray = reshape(collect(1:1.0:(n*m)),m,n)

    # initialize empty struct
    jArray = MyArray()

    # --------------------------------
    # Print addresses
    p_before = pointer_from_objref(jArray)
    p_array_before = jArray.data
    size_before = sizeof(jArray)



    println("\n\n\n*****************")
    println("Julia addresses (before ccall):")
    
    # Adress of julia struct
    println("MyArray:                  $p_before") 
    println("Array in MyArray:         $p_array_before") 
    println("Size of MyArray in Julia: $size_before")

    # Adress of 'sourceArray'
    println("Source array:             $(pointer(sourceArray))")
    println("*****************\n")
    # --------------------------------

    # Cann C library function that makes the array pointer in 'jArray' point
    # to the data stored in 'sourceArray'
    ccall((:fill_array, mylib), 
                        Cvoid,
                        (Ref{MyArray}, 
                        Cint, Cint, Ref{Cdouble}),
                        Ref(jArray),
                        Cint(m), Cint(n), sourceArray)


    # --------------------------------
    # Print addresses after ccall
    p_after = pointer_from_objref(jArray)
    p_array_after = jArray.data
    size_after = sizeof(jArray)

    println("\n\n\n*****************")
    println("Julia addresses (after ccall):")
    
    # Adress of julia struct changed again (in ccall and here)
    println("MyArray:                  $p_after") 
    println("Array in MyArray:         $p_array_after") 
    println("Size of MyArray in Julia: $size_after")
    
    # Here no change in address
    println("Source array:             $(pointer(sourceArray))")
    
    println("*****************\n")
    # --------------------------------
    
    return jArray
end


end

