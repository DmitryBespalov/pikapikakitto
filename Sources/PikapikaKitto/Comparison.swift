//
//  File.swift
//  
//
//  Created by Dmitry Bespalov on 07.07.22.
//

import Foundation

let EQUAL: Int = 0
let LESS_THAN: Int = -1
let GREATER_THAN: Int = 1

/// Compares two multi-digit numbers
///
/// - **Requires**:
///   - a, b: multiple-digit numbers with lowest significant digit at index 0
///   - a.count == b.count
/// - **Guarantees**:
///   - if `a == b` then returns 0
///   - if `a < b` then returns -1
///   - if `a > b` then returns 1
///
/// - Parameters:
///   - a: number on the left-hand side
///   - b: number on the right-hand side
/// - Returns: `0` if numbers are equal, Digit.max if `a` less than `b`, and `1` if `a` greater than `b`
func compare<Digit>(_ a: [Digit], _ b: [Digit]) -> Int where Digit: FixedWidthInteger & UnsignedInteger {
    // going from highest to lowest significant digit
    for i in (0..<a.count).reversed() {
        if a[i] == b[i] {
            // continue check iff digits are equal
            continue
        } else if a[i] < b[i] {
            // stop at the first highest-order digit of `a` that is less than `b`
            return LESS_THAN
        } else {
            // else a[i] > b[i]
            // stop at the first highest-order digit of `a` that is greater than `b`
            return GREATER_THAN
        }
    }
    // loop continue to the end, so all digits were equal, then both numbers are equal.
    return EQUAL
}

/// Checks whether two multi-digit numbers are equal
///
/// - **Requires**:
///  - a, b: multiple-digit numbers with lowest significant digit at index 0
/// - **Guarantees**:
///  - Returns `true` iff `a.count == b.count` && `a[i] == b[i]` for every `i` in range from `0` to `a.count`,
///  otherwise returns `false`.
///
/// - Parameters:
///   - a: one number
///   - b: the other number
/// - Returns: true if they are equal, otherwise false
func numbersEqual<Digit>(_ a: [Digit], _ b: [Digit]) -> Bool where Digit: FixedWidthInteger & UnsignedInteger {
    a == b
}
