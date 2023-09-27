using ChainRules
using ChainRulesCore
# using Infiltrator

struct Call{F, Args}
    f::F
    args::Args
    Call{F, Args}(f, args) where {F, Args} = new(f, args)
end

func(c::Call) = c.f
args(c::Call) = c.args

# outer constructor for the base Call, also with variable number of arguments
Call(f::F, args...) where {F} = Call{F, typeof(args)}(f, args)

# no call type
Call() = Call(nothing, nothing)

# call the inner function over the arguments
run(c::Call) = c.f(c.args...)

struct TrackedArray{T, N, A <: AbstractArray{T, N}}
    data::A
    call::Call
end

data(x::TrackedArray) = x.data
call(x::TrackedArray) = x.call
isleaf(x::TrackedArray) = isnothing(func(call(x)))

Base.:+(x::TrackedArray, y::TrackedArray) = TrackedArray(data(x) + data(y), Call(Base.:+, x, y))

params(a::AbstractArray) = TrackedArray(a, Call())

x = params([1, 2])
y = params([3, 4])
z = params([4, 5])

w = x + y + z

function back!(y, Δ)
    isleaf(y) && return Δ
    c = call(y)
    _, pullback = rrule(func(c), data.(args(c))...)
    Δargs = pullback(Δ)[2:end] 
    for (arg, Δarg) in zip(args, Δargs)
        back!(arg, Δarg)
    end
end

back!(w, [1, 1])

v = rand(1000)
v2 = [2*e for e in v]
v2 = rand(1000)
for e in v:
    v2 = e
end