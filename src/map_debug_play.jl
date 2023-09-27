function just(x)
    y = 2*x
    return y
end

a = collect(1:10)
@run just_a = map(just, a)