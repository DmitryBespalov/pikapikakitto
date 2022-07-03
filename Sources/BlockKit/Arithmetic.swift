//
//  File.swift
//  
//
//  Created by Dmitry Bespalov on 03.07.22.
//

import Foundation

// sum of two numbers.
// each number represented as array of digits, lowest digit first.
// numbers must have same digits.
// returns: partial result, and 1 if overflows
func sum<Digit>(_ a: [Digit], _ b: [Digit]) -> (result: [Digit], overflow: Digit) where Digit: UnsignedInteger & FixedWidthInteger {
    assert(a.count == b.count)
    // resulting sum
    var s = [Digit](repeating: 0, count: a.count)
    // let c (carry) = 0
    var c: Digit = 0
    // for each digit index from 0 to N
    var v: Digit = 0, c_a: Digit = 0, c_b: Digit = 0
    for i in (0..<a.count) {
        // add carry to the left term, observe overflow a: (v, c_a) <- a[i] + c
        (v, c_a) = sum(a[i], c)
        // add result with right term, observe overflow b: (s[i], c_b) <- v + b[i]
        (s[i], c_b) = sum(v, b[i])
        // current digit carry/overflow is one of the carries a or b: c <- c_a + c_b.
        // Only one of them can overflow at the same time
        c = c_a + c_b
    }
    // resulting carry is 1 iff overflow occurred
    return (s, c)
}

// sum of 2 digits reporting overflow (value of 1)
func sum<Digit>(_ a: Digit, _ b: Digit) -> (result: Digit, overflow: Digit) where Digit: UnsignedInteger & FixedWidthInteger {
    let result = a.addingReportingOverflow(b)
    return (result.partialValue, result.overflow ? 1 : 0)
}
