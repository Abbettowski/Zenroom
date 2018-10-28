print()
print "= ELLIPTIC CURVE ARITHMETIC OPERATIONS TESTS FOR GENERIC TRANSFORMATIONS"
print()

rng = RNG.new()
g1 = ECP.generator()
o = ECP.order()

wk = rng:modbig(o)
k = rng:modbig(o)
c = rng:modbig(o)
rk = wk:modsub(c * k, o)
-- rk = (wk - c*k) % o -- error when not using modsub
Aw1 = g1 * wk
Aw2 = (g1*k) * c + g1 * rk

assert(Aw1 == Aw2, 'Error in subtraction / modsub()')

print "OK"
