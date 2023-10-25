import autograd.numpy as np  # Thinly-wrapped numpy
from autograd import grad    # The only autograd function you may ever need

def tanh(x):                 # Define a function
    y = np.exp(-2.0 * x)
    return (1.0 - y) / (1.0 + y)

# grad_tanh = grad(tanh) 
# grad_grad_tanh = grad(grad(tanh)) 
# # print(grad_tanh(0.3))
# print(grad_grad_tanh(0.3))

gsin = grad(np.sin)
ggsin = grad(gsin)

print(ggsin(3.1))
