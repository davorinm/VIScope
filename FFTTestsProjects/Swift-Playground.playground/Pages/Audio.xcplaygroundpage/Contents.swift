//: Extended Audio File Services provides simplified audio file access, combining features of Audio File Services and Audio Converter Services. It provides a unified interface for reading and writing compressed as well as linear PCM audio files.

import AudioToolbox
import Darwin
import Swift
import XCPlayground

let a = [#FileReference(fileReferenceLiteral: "Sine_wave_440.wav")#]
var audioFileRef: ExtAudioFileRef = nil

let status = ExtAudioFileOpenURL(a, &audioFileRef)

var ioPropertyDataSize:UInt32 = UInt32(sizeof(Int64))
var frameSize:Int64 = 0
ExtAudioFileGetProperty(audioFileRef, kExtAudioFileProperty_FileLengthFrames, &ioPropertyDataSize, &frameSize)

print("Frame Size : \(frameSize)")



var format = AudioStreamBasicDescription()
var size:UInt32 = UInt32(sizeof(AudioStreamBasicDescription))
ExtAudioFileGetProperty(audioFileRef, kExtAudioFileProperty_FileDataFormat, &size, &format)

format

var ioNumberFrames:UInt32 = 1024
var ioData = AudioBufferList()

let readFrameSize:UInt32 = 1024
let bufferByteSize = format.mBytesPerFrame * readFrameSize * format.mBytesPerFrame
var buffer = UnsafeMutablePointer<Void>.alloc( Int(bufferByteSize) )
defer { buffer.dealloc(Int(bufferByteSize)) }

ioData.mNumberBuffers = 1
var audioBuffers = ioData.mBuffers
audioBuffers.mNumberChannels = format.mChannelsPerFrame
audioBuffers.mDataByteSize = bufferByteSize
audioBuffers.mData = buffer
ioData.mBuffers = audioBuffers

let readStatus = ExtAudioFileRead(audioFileRef, &ioNumberFrames, &ioData)

print(readStatus)
print(ioNumberFrames)
print(ioData)

//: Breaks the guarantees of Swift's type system; use with extreme care. There's almost always a better way to do anything.
var IntPtr: UnsafeMutablePointer<Int16> = unsafeBitCast(ioData.mBuffers.mData, UnsafeMutablePointer<Int16>.self)


for var i in 0..<ioNumberFrames {
    XCPlaygroundPage.currentPage.captureValue(IntPtr[Int(i)], withIdentifier: "Raw Wave")
}

//: FFT
import Accelerate
// Playground Helper
func plot<T>(values: [T], title: String) {
    for value in values {
        XCPlaygroundPage.currentPage.captureValue(value, withIdentifier: title)
    }
}

func plot(real: [Float], imaginary: [Float], title: String) {
    for (index, r) in real.enumerate() {
        let i = imaginary[index]
        XCPlaygroundPage.currentPage.captureValue(r*r+i*i, withIdentifier: title)
    }
}

// Time Domain to Freqency Domain
var real = [Float](count: 1024, repeatedValue: 0.0)
vDSP_vflt16(IntPtr, 1, &real, 1, 1024)


plot(real, title: "Time Domain")
let imaginary = [Float](count:real.count, repeatedValue: 0.0)

var real_frequency = [Float](count:real.count, repeatedValue: 0.0)
var imaginary_frequency = [Float](count:real.count, repeatedValue: 0.0)

let length = vDSP_Length(real.count)

let forward = vDSP_DFT_zop_CreateSetup(nil, length, vDSP_DFT_Direction.FORWARD)

vDSP_DFT_Execute(forward, real, imaginary, &real_frequency, &imaginary_frequency)

plot(real_frequency, imaginary:imaginary_frequency, title: "Frequency Domain")

vDSP_DFT_DestroySetup(forward)

