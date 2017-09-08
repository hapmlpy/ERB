//
//  DurationSpan.swift
//  Animo
//
//  Copyright © 2016 eureka, Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//


// MARK: - DurationSpan

public enum DurationSpan: ExpressibleByNilLiteral, ExpressibleByFloatLiteral {
    
    
    // MARK: Public
    
    case automatic
    case constant(TimeInterval)
    case infinite
    
    public static let defaultConstant = TimeInterval(0.3)
    
    
    // MARK: NilLiteralConvertible
    
    public init(nilLiteral: ()) {
        
        self = .automatic
    }
    
    
    // MARK: FloatLiteralConvertible
    
    public init(floatLiteral value: TimeInterval) {
        
        if value == 0 {
            
            self = .automatic
        }
        else if value.isInfinite && value > 0 {
            
            self = .infinite
        }
        else {
            
            self = .constant(value)
        }
    }
}
