struct Point
    x
    y
end

struct Rectangle
    a::Int16
    b::Int16
    p::Point
end

struct Point2
    x::Int16
    y::Int16
end

struct Rectangle2
    a::Int16
    b::Int16
    p::Point2
end

sizeof(Int16)
sizeof(Point)
sizeof(Point2)
sizeof(Rectangle)
sizeof(Rectangle2)