import Accelerate

let n = 5.0

pow(10.0, n)

exp(log(10)*n)

__exp10(n)

cos(M_PI*0.5)

__cospi(0.5)


var x: Double = 0, y:Double = 0
__sincos(M_PI*0.5,  &x,  &y)

print(x,y)



// Fix a float vector to int vector
var f = [Float](count: 20, repeatedValue: 1.0)

var i:Int = 0

for _ in f {
    f[i]=Float(0.1) * Float(i)
    i = i+1
}

var q = [Int16](count:20, repeatedValue: 0)
vDSP_vfix16(f, 1, &q, 1, 100)

print(f)
print(q)