using ChainRules
using ChainRules: rrule, Tangent, NoTangent
import Base: sincos

struct A <: Number
    u::Float64
end

sincos(a::A) = A.(sincos(a.u))

a = A(1)
rrule(sin, a)
rrule(sin, 1)

rf=a->rrule(sin, a)
rf(a)

##
struct Bar
    a::Float64
end

(bar::Bar)(x, y) = return bar.a + x + y 
Bar(2)(3, 4)

Tangent{Bar}(;a=1)

function ChainRulesCore.rrule(bar::Bar, x, y)
    # Notice the first return is not `NoTangent()`
    Bar_pullback(Δy) = Tangent{Bar}(;a=Δy), Δy, Δy
    return bar(x, y), Bar_pullback
end

bar = Bar(2)
y, back = rrule(bar, 3, 4)
back(1)