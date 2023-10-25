P = 64

s = BigInt(0)
g = BigInt(1)
for p in 1:P
    s = s + g
    println("patratica $p=($g, $s)")
    g = g*2
end

tone = round(BigInt, s*46/1000/1000/1000)
tone
