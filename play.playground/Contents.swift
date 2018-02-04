//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

var image = UIImage(named: "pic1.png")!
var H = Int(image.size.height)
var W = Int(image.size.width)

extension UIImage {
    func pixelData() -> [UInt8]? {
        let size = self.size
        let dataSize = size.width * size.height * 4
        var pixelData = [UInt8](repeating: 0, count: Int(dataSize))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context =
            CGContext(data: &pixelData,
                        width: Int(size.width),
                        height: Int(size.height),
                        bitsPerComponent: 8,
                        bytesPerRow: 4 * Int(size.width),
                        space: colorSpace,
                        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
        guard let cgImage = self.cgImage else { return nil }
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        return pixelData
    }
}

var rgbArray : [UInt8] =  image.pixelData()!
var arr: [[Int]] = Array(repeating: Array(repeating: 0, count: W*4), count: H)
var x : Int = 0

for i in 0...H-1 {
    for j in 0...(W*4)-1 {
        arr[i][j] = Int(rgbArray[x])
        x = x + 1
    }
}



/*************************** CENTER ***********************************************/



func main(a: [[Int]]) -> [[Int]] {
    var kernel_mean: [[Double]] = [[1.0/9.0, 1.0/9.0, 1.0/9.0], [1.0/9.0, 1.0/9.0, 1.0/9.0], [1.0/9.0, 1.0/9.0, 1.0/9.0]]
    
    var newA: [[Int]] = [[]]
    newA = convolution(a: a, kernel: kernel_mean)
    
    return newA
}

//func doubled(a:[[Int]]) -> [[Int]] {
//
//    var A:[[Int]] = a
//
//    for i in 0...a.count-1 {
//        for j in 0...a[i].count-1 {
//            A[i][j] = 2 * a[i][j]
//            if ((A[i][j] > 255) && ((j+1) % 4 != 0)) {
//                A[i][j] = 255
//            }
//        }
//    }
//
//    return A
//}
//
//
//func threshold(a:[[Int]], t:Int) -> [[Int]] {
//
//    var A:[[Int]] = a
//
//    for i in 0...a.count-1 {
//        for j in 0...a[i].count-1 {
//
//            if ((A[i][j] > t)) {
//                A[i][j] = 255
//            } else if ((A[i][j] <= t)) {
//                A[i][j] = 0
//            }
//        }
//    }
//
//    return A
//}

func multiply(c: [[Int]], d: [[Double]]) -> [[Double]]? {
    
    var sameD: Bool = false
    if (c.count == d.count) {
        for i in 0...c.count-1 {
            if (c[i].count == d[i].count) {
                sameD = true;
            } else {
                print("null")
                return nil
            }
        }
    } else {
        sameD = false
        print("null")
        return nil
    }
    
    var e:[[Double]] = [[]]
    
    for i in 0...c.count-1 {
        for j in 0...c[i].count-1 {
            e[i][j] = Double(c[i][j]) * d[i][j]
        }
    }
    
    return e
}

func snip(a: [[Int]], i:Int, j:Int, dx:Int) -> [[Int]]? {
    
    if (i < 0 || i > a.count || j < 0 || j > a[0].count ||
        i - (dx / 2) < 0 || j - (dx / 2) < 0 || i + (dx / 2) > a.count
        || j + (dx / 2) > a[0].count) {
        print("null")
        return nil
    }
    
    var s:[[Int]] = [[]]
    var p: Int = 0
    var q: Int
    
    for m in (i - (dx / 2))...(i+(dx/2)) {
        q = 0
        for n in (j - (dx / 2))...(j+(dx/2)) {
            s[p][q] = a[m][n]
            q = q + 1
        }
        p = p + 1
    }
    
    return s
}

func absSum(a: [[Double]]) -> Double {
    
    var sum : Double = 0.0
    
    for i in 0...a.count {
        for j in 0...a[i].count {
            sum = sum + a[i][j]
        }
    }
    sum = abs(sum)
    if (sum > 255) {
        sum = 255
    }
    
    return (sum)
}

func convolution(a:[[Int]], kernel:[[Double]]) -> [[Int]] {
    var dx: Int = kernel[0].count
    var newA:[[Int]] = [[]]
    var s:[[Int]] = [[]]
    var e:[[Double]] = [[]]
    var sum:Double
    
    for i in (dx/2)...(a.count-(dx/2)) {
        sum = 0
        for j in (dx/2)...(a[i].count-(dx/2)) {
            s = snip(a: a, i: i, j: j, dx: dx)!
            e = multiply(c: s, d: kernel)!
            sum = absSum(a: e)
            newA[i][j] = Int(sum)
        }
    }
    return newA
}


arr = main(a: arr)



/*********************************************************************************/
var v: Int = 0

for i in 0...arr.count - 1 {
    for j in 0...arr[i].count - 1 {
        rgbArray[v] = UInt8(arr[i][j])
        v = v + 1
    }
}

let data = UnsafeMutablePointer(mutating: rgbArray)

let releaseMaskImagePixelData: CGDataProviderReleaseDataCallback = { (info: UnsafeMutableRawPointer?, data: UnsafeRawPointer, size: Int) -> () in
    return
}

let provider: CGDataProvider! = CGDataProvider(dataInfo: nil, data: data, size: rgbArray.count, releaseData: releaseMaskImagePixelData)

let cgImage = CGImage(
    width: W,
    height: H,
    bitsPerComponent: 8,
    bitsPerPixel: 32,
    bytesPerRow: 4 * W,
    space: CGColorSpaceCreateDeviceRGB(),
    bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
    provider: provider,
    decode: nil,
    shouldInterpolate: true,
    intent: .defaultIntent
)

let uiImage = UIImage(cgImage: cgImage!)
