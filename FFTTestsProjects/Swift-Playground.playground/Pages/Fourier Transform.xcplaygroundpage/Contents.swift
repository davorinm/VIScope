import Foundation
import XCPlayground

// Playground Helper
func plot<T>(values: [T], title: String) {
    for value in values {
        XCPlaygroundPage.currentPage.captureValue(value: value, withIdentifier: title)
    }
}

var len = 64 // radix-2 FFT length must be a power of 2

var myArray1 = [Double](count: len, repeatedValue: 0.0) // for Real Component
var myArray2 = [Double](count: len, repeatedValue: 0.0) // for Imaginary

var f0 = 1.0  // test input frequency

func myFill1 (inout a : [Double], inout b: [Double], n: Int, f0: Double) -> () {
    for i in 0 ..< n {
        // some test data
        let x = cos(2.0 * M_PI * Double(i) * f0 / Double(n))
        myArray1[i] = Double(x)  // Quicklook here to see a plot of the input waveform
        myArray2[i] = 0.0
        //
    }
    plot(myArray1, title: "myArray1")
}

var sinTab = [Double]()

// Canonical in-place decimation-in-time radix-2 FFT
func myFFT ( u : inout [Double], v : inout [Double], n: Int, dir : Int) -> () {
    
    let flag = dir // forward
    
    if sinTab.count != n {   // build twiddle factor lookup table
        while sinTab.count > n {
            sinTab.removeLast()
        }
        sinTab = [Double](count: n, repeatedValue: 0.0)
        for i in 0 ..< n {
            let x = sin(2.0 * M_PI * Double(i) / Double(n))
            sinTab[i] = x
        }
        plot(values: sinTab, title: "SinTab")
    }
    
    let m : Int = Int(log2(Double(n)))
    for k in 0 ..< n {
        // rem *** generate a bit reversed address vr k ***
        var ki = k
        var kr = 0
        for _ in 1...m { // =1 to m
            kr = kr << 1  //  **  left shift result kr by 1 bit
            if ki % 2 == 1 { kr = kr + 1 }
            ki = ki >> 1   //  **  right shift temp ki by 1 bit
        }
        // rem *** swap data vr k to bit reversed address kr
        if (kr > k) {
            let tr = u[kr] ; u[kr] = u[k] ; u[k] = tr
            let ti = v[kr] ; v[kr] = v[k] ; v[k] = ti
        }
    }
    
    var istep = 2
    while ( istep <= n ) { //  rem  *** layers 2,4,8,16, ... ,n ***
        let is2 = istep / 2
        let astep = n / istep
        for km in 0 ..< is2 { // rem  *** outer row loop ***
            let a  = km * astep  // rem  twiddle angle index
            // var wr = cos(2.0 * M_PI * Double(km) / Double(istep))
            // var wi = sin(2.0 * M_PI * Double(km) / Double(istep))
            let wr =  sinTab[a+(n/4)] // rem  get sin from table lookup
            var wi =  sinTab[a]       // rem  pos for fft , neg for ifft
            if (flag == -1) { wi = -wi }
            for var ki = 0; ki <= (n - istep) ; ki += istep { //  rem  *** inner column loop ***
                let i = km + ki
                let j = (is2) + i
                let tr = wr * u[j] - wi * v[j]  // rem ** butterfly complex multiply **
                let ti = wr * v[j] + wi * u[j]  // rem ** using a temp variable **
                let qr = u[i]
                let qi = v[i]
                u[j] = qr - tr
                v[j] = qi - ti
                u[i] = qr + tr
                v[i] = qi + ti
            } // next ki
        } // next km
        istep = istep * 2
    }
    let a = 1.0 / Double(n)
    for i in 0 ..< n {
        u[i] = u[i] * a
        v[i] = v[i] * a
    }
}
// compute magnitude vector
func myMag (u : [Double], v : [Double], n: Int) -> [Double] {
    var m = [Double](count: n, repeatedValue: 0.0)
    for i in 0 ..< n {
        m[i] = sqrt(u[i]*u[i]+v[i]*v[i])   // Quicklook here to see a plot of the results
        
    }
    return(m)
}

myFill1(&myArray1, b: &myArray2, n: len, f0: f0)
myFFT(  &myArray1, v: &myArray2, n: len, dir: 1)

var mm = myMag(myArray1, v: myArray2, n: len)

plot(mm, title: "mm")

// Feel free to treat the above code as if it were under an MIT style Open Source license.
// rhn 2014-June-08

// modified 2014-Jul-10 for Xcode6-beta3 newer Swift syntax
