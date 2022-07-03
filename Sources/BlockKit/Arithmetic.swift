//
//  File.swift
//  
//
//  Created by Dmitry Bespalov on 03.07.22.
//

import Foundation

/// Adds two numbers detecting overflow
///
/// - **Requires**:
///   - a, b: number represented as an array of digits. Each digit is a Base-N generic unsigned fixed width binary integer. First item is the lowest significant digit.
///
///     For example, given a UInt8 as a base digit type (base-256 numbers),
///     the 3-digit array would represent a number:
///     ```
///     a[0] + a[1] * 2^8 + a[2] * 2^16
///     ```
///   - a.count == b.count, i.e. both numbers have same number of digits.
/// - **Guarantees**:
///   - result.count == a.count, i.e. result is the same size as operands
///   - if overflow occurs, then result is the truncated sum (a + b) % max number, and 1 to indicate overflow
///   - if no overflow occurs, then result is the sum of a and b, and 0 for no overflow indication.
///
/// - Parameters:
///   - a: first number to add
///   - b: second number to add
/// - Returns: if no overflow, then sum of the a and b and 0. Otherwise, the truncated sum and 1
///
func sum<Digit>(_ a: [Digit], _ b: [Digit]) -> (result: [Digit], overflow: Digit) where Digit: UnsignedInteger & FixedWidthInteger {
    // add two numbers digit by digit with carrying over the overflow to the next digit.

    // resulting sum
    var s = [Digit](repeating: 0, count: a.count)
        // s.count == a.count
        // s[i] == 0

    // overall overflow / carry digit
    var c: Digit = 0
        // c == 0

    // v is a temporary sum
    // c_a and c_b are overflows / carry digits
    var v: Digit = 0, c_a: Digit = 0, c_b: Digit = 0
        // v, c_a, c_b: all equal to 0

    // invariant: c, c_a, c_b: [0, 1]
    for i in (0..<a.count) {

        // (I) sum of first term and carry from the previous digit
        (v, c_a) = sumScalars(a[i], c)
        // c == 0
            // (1): a[i] + 0 = a[i]; v <- a[i]; c_a <- 0
        // c == 1
            // (2): a[i] == max
                // (overflow) (a[i] + 1) % base = (max + 1) % base = 0; v <- 0; c_a <- 1
            // (3): a[i] < max
                // a[i] + 1 <= max; c_a <- 0

        // in all 3 cases, c_a: [0, 1]
        // if c_a == 1 then v == 0
        // otherwise, c_a == 0 and v <= max

        // (II) sum of the previous sum and the second term
        (s[i], c_b) = sumScalars(v, b[i])
            // (1): v == 0 and c_a == 1
                // s[i] <- b[i]; c_b <- 0
            // (2): v <= max and c_a == 0
                // A: v + b[i] overflows
                    // s[i] = (v + b[i]) % base; c_b <- 1
                // B: v + b[i] does not overflow
                    // s[i] = v + b[i]; c_b <- 0

        // c_b == 1 iff c_a == 0 and sum overflows
        // otherwise, c_b == 0, including when c_a == 1.

        // s[i] is the sum (c + a[i] + b[i]) % base

        // thus, after operations (I) and (II),
        // c_a is 1 and c_b is 0 OR c_a is 0 and c_b is 1 OR c_a and c_b are 0.
        c = c_a + c_b
        // c = (1 + 0) || (0 + 1) || (0 + 0) ==> c >= 0 and c <= 1
        // c is 1 when the operations (I) or (II) overflow.
    }
    // invariant holds for each i-th digit of the operand
    // c = 0 or 1
    // s[i] = c[i-1] + a[i] + b[i]

    return (s, c)
    // returns each digit of the truncated sum, with carry (0 or 1) showing overflow
    // s.count == a.count
}

/// Sum of 2 fixed-width digits that can overflow
///
/// - **Requires**:
///   - a and b to be unsigned fixed width integers
/// - **Guarantees**:
///   - if sum of a and b overflows then returns (truncated sum, 1)
///   - otherwise returns (sum, 0)
///
/// - Parameters:
///   - a: one term to add
///   - b: the other term to add
/// - Returns: if sum overflows, then returns partial sum: (a + b) % base as a result and 1 for an overflow indication
/// if sum does not overflow, then returns it in the result, and 0 for no overflow indication.
func sumScalars<Digit>(_ a: Digit, _ b: Digit) -> (result: Digit, overflow: Digit) where Digit: UnsignedInteger & FixedWidthInteger {
    // before: n/a
    let result: (partialValue: Digit, overflow: Bool) = a.addingReportingOverflow(b)
    // after:
    //  - result.partialValue is a truncated sum of `a` and `b` to the bitWidth
    //  - result.overflow is true if a + b is greater than maximum representable value

    return (result.partialValue, result.overflow ? 1 : 0)
    // returned sum and 1 if overflows, or sum and 0 if not overflows
}


/// Difference between two numbers with overflow detection
///
/// Each number is represented as coefficients in the base-Digit polynomial.
/// For example, if the Digit is UInt8, then the numbers are in base-256.
/// Thus, 3-digit number would be represented
///
/// ```
/// a[0] + a[1] * 2^8 + a[2] * 2^16 = a[0] + a[1] * 256 + a[2] * 65.536
/// where a[i]: [0...255]
/// ```
///
///  The array starts with the lowest significant coefficient.
///
///  - **Requires**:
///     - a.count == b.count
///     - a, b: representation of a base-Digit number's polynomial coefficients
///       with the lowest significant coefficient as a first item (first digit)
///  - **Guarantees**:
///    - result.count == a.count
///    - if a > b, then overflow == 1 && result = (a - b) % max number
///    - else, overflow == 0, result = a - b
///
/// - Parameters:
///   - a: first number, base-Digit. Represents coefficients to the base-digit number representation.
///   - b: number to subtract from the first one.
/// - Returns: truncated difference, and 1 if overflow, or 0 if no overflow.
func subtract<Digit>(_ a: [Digit], _ b: [Digit]) -> (result: [Digit], overflow: Digit) where Digit: UnsignedInteger & FixedWidthInteger {
    assert(a.count == b.count)
    // difference
    var d = [Digit](repeating: 0, count: a.count)
        // d.count == a.count
        // d[i] == 0 for i = 0..<a.count

    // borrow / carry digit
    var c: Digit = 0
        // c == 0

    // v is a temporary subtraction result
    // c_a and c_b are temporary borrow / carry
    var v: Digit = 0, c_a: Digit = 0, c_b: Digit = 0
        // v, c_a, c_b == 0

    // invariant: c, c_a, c_b: [0, 1]
    for i in (0..<a.count) {
        // (I) subtract borrow digit from the first term
        (v, c_a) = subtractScalars(a[i], c)
        // (1) c == 0
            // a[i] - 0 = a[i]; v <- a[i]; c_a <- 0
        // (2) c == 1
            // A: a[i] == 0
                // (overflow) (0 - 1) % base = max; v <- max; c_a <- 1
            // B: a[i] > 0
                // a[i] - 1 >= 0; v = a[i] - 1; c_a <- 0

        // thus:
        // C: c_a == 1 && v == max ||
        // D: ( c_a == 0 && v == a[i] (>= 0) ) ||
        // E: ( c_a == 0 && v = a[i] - 1 (>= 0) )


        // (II) subtract second term from (I) to get the resulting difference digit
        (d[i], c_b) = subtractScalars(v, b[i])
            // C: s[i] <- max - b[i]; s[i] >= 0 && s[i] <= max; c_b <- 0
            // D: s[i] = a[i] - b[i]; s[i] can overflow
            // E: s[i] = a[i] - 1 - b[i]; s[i] can overflow
            // D && E:
                // (overflow) 0 <= s[i] <= max; c_b <- 1
                // (no overflow) 0 <= s[i] <= max; c_b <- 0

        // c_a == 1 && c_b == 0 && 0 <= s[i] <= max OR
        // c_a == 0 && c_b == 1 && 0 <= s[i] <= max OR
        // c_a == 0 && c_b == 0 && 0 <= s[i] <= max
        c = c_a + c_b
            // c = (1 + 0) || (0 + 1) || (0 + 0); c == 0 || c == 1
            // c_a, c_b: 0 or 1
            // invariant holds.
            // s[i] is the difference between first term, borrow, and second term
    }

    return (d, c)
        // return truncated difference between a and b
        // and c == 1 or 0 depending if it is overflow or not
}

/// Subtracts one scalar from another, can overflow.
///
/// - **Requires**:
///   - a and b unsigned fixed width binary integers
/// - **Guarantees**:
///   - if a >= b: result = a - b && overflow == 0
///   - else: result = (a - b) % base && overflow == 1
///
/// - Parameters:
///   - a: first term
///   - b: subtrahend
/// - Returns: difference between a and b truncated to the Base; overflow indication
func subtractScalars<Digit>(_ a: Digit, _ b: Digit) -> (result: Digit, overflow: Digit) where Digit: UnsignedInteger & FixedWidthInteger {
    let result = a.subtractingReportingOverflow(b)
    return (result.partialValue, result.overflow ? 1 : 0)
        // overflow == true: result is truncated value of a - b; 'overflow' <- 1
        // overflow == false: result is difference between a and b; 'overflow' <- 0
}
