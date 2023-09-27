using ChainRules
using ChainRules: rrule
using ChainRulesCore
import Base: +, *

struct _Tracked <: Real
    data::Float64
    f::Any
    _Tracked(data, f) = new(data, f)
    _Tracked(data) = new(data, nothing)
end

function track(f, a, b)
    data, delayed = _forward(f, a, b)
    return _Tracked(data, delayed)
end

function _forward(f, a, b)
    data = f(a.data, b.data) # primal no tracking
    delayed = ()->rrule(f, a, b) # delayed pullback with tracking
    return data, delayed
end

a::_Tracked + b::_Tracked = track(+, a, b)
a::_Tracked * b::_Tracked = track(*, a, b)

##
a = _Tracked(10)
b = _Tracked(20)
tr = a*b
back2 = tr.f()[2]
da, db = back2(_Tracked(1.0))[2:end]

# c, delayed = a+b
# back = delayed()[2]
# back(1.0)

