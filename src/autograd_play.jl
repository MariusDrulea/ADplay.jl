using AutoGrad
using AutoGrad: @primitive

x = Param([1,2,3])		# user declares parameters
value(x)		# we can get the original value
f = x->sum(abs2,x)		# they act like regular values outside of differentiation
@enter grad(f)
y = @diff sum(abs2,x)	        # if you want the gradients
@enter y = @diff sum(abs2,x)	        # if you want the gradients
value(y)			# which represents the same value
@enter grad(y,x)

struct Linear; w; b; end		# user defines a model
(f::Linear)(x) = (f.w * x .+ f.b)

# Initialize a model as a callable object with parameters:
f = Linear(Param(randn(2,3)), Param(randn(2)))

# SGD training loop:
# for (x,y) in data
# for i in 1:10
    x = rand(3)
    y = rand(2)
    loss = @diff sum(abs2,f(x)-y)
    # for w in params(f)
        w = params(f)[1]
        g = grad(loss,w)
        g = grad(loss, f.b)
	    @show g
        # AutoGrad.axpy!(-0.01, g, w)
        w .-= 0.01*g
    # end
# end

g1 = grad(p)
g4(x, i) = grad(g1(x))[i]
g4(x, 1)

grad(x -> x*grad(y -> x+y)(x))(5.0) == 1
grad(x -> x*grad(y -> x+y)(1x))(5.0) == 1

##
using AutoGrad

x = Param(2)		# user declares parameters
f(x) = x^3 + 3

hess2(f,i=1) = grad(x->grad(f)(x)[i])
@run hess2(f, 1)(x)

# hess3(i) = grad(x->grad(p)(x)[i])
# hess3(1)(x)