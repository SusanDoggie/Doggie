
import Foundation
import Accelerate

public func vDSP_fft_zropD_Benchmark(_ n: Int) -> Double {
    
    var real = [Double](repeating: 0.0, count: 1 << n)
    var _real = [Double](repeating: 0.0, count: 1 << (n - 1))
    var _imag = [Double](repeating: 0.0, count: 1 << (n - 1))
    
    let setup = vDSP_create_fftsetupD(vDSP_Length(n), FFTRadix(kFFTRadix2))!
    defer { vDSP_destroy_fftsetupD(setup) }
    
    var time: clock_t = 0
    
    for _ in 0..<10 {
        
        let t = clock()
        
        real.withUnsafeMutableBufferPointer {
            
            guard let real = $0.baseAddress else { return }
            
            _real.withUnsafeMutableBufferPointer {
                
                guard let _real = $0.baseAddress else { return }
                
                _imag.withUnsafeMutableBufferPointer {
                    
                    guard let _imag = $0.baseAddress else { return }
                    
                    var source = DSPDoubleSplitComplex(realp: real, imagp: real + 1)
                    var result = DSPDoubleSplitComplex(realp: _real, imagp: _imag)
                    
                    vDSP_fft_zropD(setup, &source, 2, &result, 1, vDSP_Length(n), FFTDirection(FFT_FORWARD))
                }
            }
        }
        
        time += clock() - t
    }
    
    return 0.1 * Double(time) / Double(CLOCKS_PER_SEC)
}
public func vDSP_fft_zripD_Benchmark(_ n: Int) -> Double {
    
    var _real = [Double](repeating: 0.0, count: 1 << (n - 1))
    var _imag = [Double](repeating: 0.0, count: 1 << (n - 1))
    
    let setup = vDSP_create_fftsetupD(vDSP_Length(n), FFTRadix(kFFTRadix2))!
    defer { vDSP_destroy_fftsetupD(setup) }
    
    var time: clock_t = 0
    
    for _ in 0..<10 {
        
        let t = clock()
        
        _real.withUnsafeMutableBufferPointer {
            
            guard let _real = $0.baseAddress else { return }
            
            _imag.withUnsafeMutableBufferPointer {
                
                guard let _imag = $0.baseAddress else { return }
                
                var buffer = DSPDoubleSplitComplex(realp: _real, imagp: _imag)
                
                vDSP_fft_zripD(setup, &buffer, 1, vDSP_Length(n), FFTDirection(FFT_FORWARD))
            }
        }
        
        time += clock() - t
    }
    
    return 0.1 * Double(time) / Double(CLOCKS_PER_SEC)
}
public func vDSP_fft_zopD_Benchmark(_ n: Int) -> Double {
    
    var real = [Double](repeating: 0.0, count: 1 << n)
    var imag = [Double](repeating: 0.0, count: 1 << n)
    var _real = [Double](repeating: 0.0, count: 1 << n)
    var _imag = [Double](repeating: 0.0, count: 1 << n)
    
    let setup = vDSP_create_fftsetupD(vDSP_Length(n), FFTRadix(kFFTRadix2))!
    defer { vDSP_destroy_fftsetupD(setup) }
    
    var time: clock_t = 0
    
    for _ in 0..<10 {
        
        let t = clock()
        
        real.withUnsafeMutableBufferPointer {
            
            guard let real = $0.baseAddress else { return }
            
            imag.withUnsafeMutableBufferPointer {
                
                guard let imag = $0.baseAddress else { return }
                
                _real.withUnsafeMutableBufferPointer {
                    
                    guard let _real = $0.baseAddress else { return }
                    
                    _imag.withUnsafeMutableBufferPointer {
                        
                        guard let _imag = $0.baseAddress else { return }
                        
                        var source = DSPDoubleSplitComplex(realp: real, imagp: imag)
                        var result = DSPDoubleSplitComplex(realp: _real, imagp: _imag)
                        
                        vDSP_fft_zopD(setup, &source, 1, &result, 1, vDSP_Length(n), FFTDirection(FFT_FORWARD))
                    }
                }
            }
        }
        
        time += clock() - t
    }
    
    return 0.1 * Double(time) / Double(CLOCKS_PER_SEC)
}
public func vDSP_fft_zipD_Benchmark(_ n: Int) -> Double {
    
    var _real = [Double](repeating: 0.0, count: 1 << n)
    var _imag = [Double](repeating: 0.0, count: 1 << n)
    
    let setup = vDSP_create_fftsetupD(vDSP_Length(n), FFTRadix(kFFTRadix2))!
    defer { vDSP_destroy_fftsetupD(setup) }
    
    var time: clock_t = 0
    
    for _ in 0..<10 {
        
        let t = clock()
        
        _real.withUnsafeMutableBufferPointer {
            
            guard let _real = $0.baseAddress else { return }
            
            _imag.withUnsafeMutableBufferPointer {
                
                guard let _imag = $0.baseAddress else { return }
                
                var buffer = DSPDoubleSplitComplex(realp: _real, imagp: _imag)
                
                vDSP_fft_zipD(setup, &buffer, 1, vDSP_Length(n), FFTDirection(FFT_FORWARD))
            }
        }
        
        time += clock() - t
    }
    
    return 0.1 * Double(time) / Double(CLOCKS_PER_SEC)
}
