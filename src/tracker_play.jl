using Tracker

p=x->prod(x)
q=x->(p(x)./x, ) # the hard-coded gradient
r=x->q(x)[1]
jacobian(r, [1, 2]) # jacobian of the gradient = hessian

##
using Tracker

x = param(1)
y = param(2)
f = (x, y)->x+y
function fn3()
    z = x + y
end

@run fn3()

@run back!(z, 1)
Tracker.grad(x)

##
using Tracker
f(x, y) = x + y

@run gradient(f, 1, 2; nest=true)

##
using Tracker
x1 = param(1)
x2 = param(2)

f_(x1, x2) = x1*x2
∇f_(x1, x2) = gradient(f_, x1, x2, nest=true)

@run gradient(x1->∇f_(x1, x2)[1], x1)[1]

H11 = gradient(x1->∇f_(x1, x2)[1], x1)[1]
H12 = gradient(x2->∇f_(x1, x2)[1], x2, nest=true)[1]
H21 = gradient(x1->∇f_(x1, x2)[2], x1)[1]
H22 = gradient(x2->∇f_(x1, x2)[2], x2)[1]


## 
using Tracker
f(x) = prod(x)
∇f = x->gradient(f, x, nest=true)[1]
hess1 = x->gradient(u->∇f(u)[1], x, nest=true)

h1 = hess1([3, 4])
Tracker.print_graph(stdout, h1[1])

##
using Tracker
f(x) = x + 2x + sin.(x)
g(x) = sum(x)
h = g(f(x))

## 
using Tracker
# function test()
x = param([3, 4])
w = prod(x)

y = param([7, 22])
z = x+y
# end
# @enter test()
Tracker.print_graph(stdout, w)
Tracker.back!(w, 1; once=false)
@enter Tracker.back!(w, 1; once=false)

##
using Tracker
f2(x, y) = prod(x+2*y)
@run dx = gradient(f2, [3, 4], [7, 9])

# Tracker.print_graph(stdout, dx)

##
using Tracker
x = param([3, 4])
y = param([7, 9])

z = prod(x+2*y)
back!(z)
x.tracker.grad

##
using Tracker

f(x) = sin(x)
df(x) = gradient(f, x, nest=true)[1]
d2f(x) = gradient(u->df(u), x, nest=true)[1]
d3f(x) = gradient(u->d2f(u), x, nest=true)[1]

x0 = param(1)
df0 =df(x0)
d2f(x0)
d3f(x0)

## 
using Tracker

x = param(1)
sx = sin(x)
back2 = sx.tracker.f.func
cx = back2(1)
back3 = cx.tracker.f.func
back3(1)

##
using Tracker
using ChainRules
using ChainRules: rrule

x = param(1)
sinx, pb = rrule(sin, x)
cx = pb(1)[2]
Tracker.back!(cx)

##
using Tracker
using Tracker: data, TrackedReal, param, track, @grad
using DiffRules
import Base: sin, tan, cos

M=:Base
f=:sin
Mf = :($M.$f)
@eval begin
    # @grad creates a _forward method
    # _forward(::typeof(sin), a) = sin(data(a)), Δ->(Δ*cos(a),)
    @grad $Mf(a::Real) = $Mf(data(a)), Δ -> (Δ * $(DiffRules.diffrule(M, f, :a)),)
    $Mf(a::TrackedReal) = track($Mf, a)
end

@eval begin
    $(DiffRules.diffrule(M, f, :a)) 
end
DiffRules.diffrule(:Base, :tan, :a)
@eval $(DiffRules.diffrule(:Base, :tan, :a))
eval((DiffRules.diffrule(:Base, :tan, :a)))

# kindly note the evaluation of the expression only occurs when back is called
# also note diffrules works with symbols
sin(a::TrackedReal) = sin(data(a)), Δ->(Δ*eval(DiffRules.diffrule(:Base, :sin, :a)),)
cos(a::TrackedReal) = println("called cos of $a") === nothing && return cos(data(a))

a = param(1)
sin(a)
y, back = sin(a)
back(1)

y2, back2 = tan(a)