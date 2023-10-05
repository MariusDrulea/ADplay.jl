import autograd.numpy as np  # Thinly-wrapped numpy
from autograd import grad    # The only autograd function you may ever need

def myfun(x):
    y = 2.0*x*x + x*x*x
    return y

grad_myfun = grad(myfun)
grad_grad_myfun = grad(grad_myfun)
print(grad_grad_myfun(1.0))