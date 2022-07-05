//
//  Arithmetic.swift
//  
//
//  Created by Dmitry Bespalov on 03.07.22.
//

import Foundation

/// Adds two numbers detecting overflow
///
/// - **Requires**:
///   - `a, b`: numbers represented as an array of digits. Each digit is a
///     Base-N generic unsigned fixed width binary integer. First item is the lowest significant digit.
///
///     For example, given a UInt8 as a base digit type (base-256 numbers),
///     the 3-digit array would represent a number:
///     ```
///     a[0] + a[1] * 2^8 + a[2] * 2^16
///     ```
///   - `a.count == b.count`, i.e. both numbers have same number of digits.
/// - **Guarantees**:
///   - `result.count == a.count`, i.e. result is the same size as operands
///   - if overflow occurs, then result is the truncated sum `(a + b) % max number`, and `1` to indicate overflow
///   - if no overflow occurs, then result is the `sum of a and b`, and `0` for no overflow indication.
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
        (v, c_a) = addScalars(a[i], c)
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
        (s[i], c_b) = addScalars(v, b[i])
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
///   - `a` and `b` to be unsigned fixed width integers
/// - **Guarantees**:
///   - if sum of a and b overflows then returns tuple `(truncated sum, 1)`
///   - otherwise returns tuple `(sum of a and b, 0)`
///
/// - Parameters:
///   - a: one term to add
///   - b: the other term to add
/// - Returns: if sum overflows, then returns partial sum: `(a + b) % base` as a result and `1` for an overflow indication
///   if sum does not overflow, then returns it in the result, and `0` for no overflow indication.
func addScalars<Digit>(_ a: Digit, _ b: Digit) -> (result: Digit, overflow: Digit) where Digit: UnsignedInteger & FixedWidthInteger {
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
///     - `a.count == b.count`
///     - `a, b`: representation of a base-Digit number's polynomial coefficients
///       with the lowest significant coefficient as a first item (first digit)
///  - **Guarantees**:
///    - `result.count == a.count`
///    - if `a > b`, then `overflow == 1 && result == (a - b) % max number`
///    - else, `overflow == 0`, `result == a - b`
///
/// - Parameters:
///   - a: first number, base-Digit. Represents coefficients to the base-digit number representation.
///   - b: number to subtract from the first one.
/// - Returns: truncated difference, and `1` if overflow, or `0` if no overflow.
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
///   - `a` and `b` unsigned fixed width binary integers
/// - **Guarantees**:
///   - if `a >= b`: `result == a - b && overflow == 0`
///   - else: `result == (a - b) % base && overflow == 1`
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

/// Multiplies one scalar by another, producing a 2-digit product
///
/// - **Requires**:
///   - `a, b`: unsigned fixed width integers
/// - **Guarantees**:
///   - result is the full product of a and b, as a 2-digit number
///
/// - Parameters:
///   - a: first term
///   - b: multiplier
/// - Returns: product of a and b
func multiplyScalars<Digit>(_ a: Digit, _ b: Digit) -> [Digit] where Digit: UnsignedInteger & FixedWidthInteger {
    let result = a.multipliedFullWidth(by: b)
        // .low is the lower part of the full width result
        // .high is the higher part of the full width result
    return [Digit(result.low), result.high]
        // index 0 is lower part
        // index 1 is higher part
}


/// Multiplies scalar with a number (vector) full width, producing a longer-digit number.
///
/// - **Requires**:
///   - a: unsigned fixed width binary integer
///   - b: multiple-digit number represetned by array of coefficients, with the 0-index being lowest significant
///     coefficient
///  - **Guarantees**:
///    - `result.count == b.count + 1`
///    - result is the product of the multiplying a by b
///
/// - Parameters:
///   - a: scalar multiplier
///   - b: number in base-Digit
/// - Returns: product of multiplicating number by scalar, full width.
func multiplyByScalar<Digit>(_ a: Digit, _ b: [Digit]) -> [Digit] where Digit: UnsignedInteger & FixedWidthInteger {
    var p = [Digit](repeating: 0, count: b.count + 1)
        // p.count == b.count + 1
        // p[i] == 0

    var c: Digit = 0
        // c == 0

    // 0 <= c <= max
    for i in (0..<b.count) {
        // i.
        let s = multiplyScalars(a, b[i])
            // s[0], s[1] are resulting digits
                // 0 <= s[1] <= max - 1
                    // consider two N-based digits. Maximum number is N - 1.
                    // maximum multiplied scalars are ( N - 1 ) * ( N - 1 ) = N^2 - 2N +1 = N(N - 2) + 1 which is < N^2
                    // thus, the higher-order digit will N - 2 which is max - 1.
        // ii.
        let q = sum(s, [c, 0]).result
            // [s[0], s[1]] + [c, 0]
                // (s[0] + c) may result in overflow into next digit.
                // overflow == 1
                    // q[1] <- s[1] + 1
                    // since s[1] <= max - 1, then s[1] + 1 <= max, then q[1] <= max
                    // thus, add()'s overflow is always 0 and disregarded. We use .result instead.

        // iii.
        (p[i], c) = (q[0], q[1])
            // p[i] <- q[0], i.e. the digit of the result after multiplying two digits and adding carry-over from
                // previous digit.
            // c <- q[1]; c <= max
                // carry over to the next digit
    }
    // all digits corresponding to `b` traversed.

    // record carry over as an extra digit.
    p[b.count] = c

    return p
        // product of the a and b
}

/// Shifts the digits of a number by `N` positions to the right, i.e multiplying the number by base^N and truncating
/// at the size of the number.
///
/// - **Requires**:
///   - `a`: multiple-digit base-Digit number, 0-index is the lowest significant digit.
///   - `n < a.count`
/// - **Guarantees**:
///   - `result.count == a.count`
///   - `result[0..<n] == 0`
///   - `result[n..<a.count] == a[0..<(a.count - n)]`
///
/// - Parameters:
///   - a: number to shift
///   - n: how much to shift
/// - Returns: resulting number
func shiftRight<Digit>(_ a: [Digit], _ n: Int) -> [Digit] where Digit: UnsignedInteger & FixedWidthInteger {
    var result = a
        // result.count == a.count
    result[0..<n] = ArraySlice(repeating: 0, count: n)
        // result[0..<n] == 0
    result[n..<a.count] = a[0..<( a.count - n )]
        // result[n..<a.count] == a[0..<(a.count - n)]
            // count(left) = a.count - n
            // count(right) = a.count - n - 0
    return result
}

/// Extends the width of the number to a new size by adding zeroes to the higher-significant end till the required width.
///
/// - **Requires**:
///   - `a`: multple-digit base-Digit number, 0-index is the lowest significant digit.
/// - **Guarantees**:
///   - if `size > a.count` then `result.count == size && result[a.count..<size] == 0 && result[0..<a.count] == a[0..<a.count]`
///   - else `result == a`
///
/// - Parameters:
///   - a: number to pad
///   - size: new size
/// - Returns: padded number
func padRight<Digit>(_ a: [Digit], _ size: Int) -> [Digit] where Digit: UnsignedInteger & FixedWidthInteger {
    guard size > a.count else {
        return a
            // result == a iff !(size > a.count)
    }
    let padding = [Digit](repeating: 0, count: size - a.count)
        // padding.count == size - a.count
        // padding[i] == 0
    let result = a + padding
        // result[0..<a.count] == a && result[a.count..<size] == 0
        // result.count == a.count + padding.count == a.count + size - a.count == size
    return result
}

/// Multiplies two numbers together, full-width.
///
/// - **Requires**:
///   - `a, b`: multiple-digit base-Digit numbers represented by coefficients with 0-index as lowest significant digit.
///     Digits are unsigned fixed width binary integers.
///   - `a.count == b.count`
/// - **Guarantees**:
///   - `result.count == a.count * 2`
///   - result is the product of multiplying `a` and `b`.
///
///
/// - Parameters:
///   - a: multiplicand
///   - b: multiplier
/// - Returns: full-width product of multiplying `a` by `b`
func multiply<Digit>(_ a: [Digit], _ b: [Digit]) -> [Digit] where Digit: UnsignedInteger & FixedWidthInteger {
    // long multiplication, or multiplying two polynomes.
        // multiply each digit of a by b while shifting the result to a higher digit (multiplying by base)
        // and sum all such products
        //
        // or, if each number is a polynome, then we take each term of one polynome and multiply by another
        // polynome and then sum all such products to get the result.

    // (*): the strict upper bound on the resulting product is the greatest number in double digit length.
        // the greatest D-digit number M in base X is X^D - 1 where D > 0 and X > 1
            // maximum digit in base X has value X - 1.
            // for 1-digit, M(1) = X - 1   (1)
            // if we assume that for (N - 1) digits true: M(N-1) = X^(N - 1) - 1
            // then, N-digit maximum number is M(N) = M(N - 1) + (X - 1) X^(N - 1)
            // i.e. is the maximum N-1 digit number with the maximum exponent for next digit
            // so M(N) = X^(N - 1) - 1 + (X - 1) X^(N - 1) = X^(N - 1) + X^N - X^(N - 1) = X^N - 1.
            // prooving by induction, the proposition holds.

        // the greatest product of 2 such numbers is (X^D - 1)(X^D - 1) = X^2D - 2X^D + 1 and it is true that:
        // (1): X^2D - 2X^D + 1 < X^2D - 1
            // Proof by contradiction. Assume that the opposite is true, i.e.
            // (2): X^2D - 2X^D + 1 >= X^2D - 1, then
            // -2X^D + 1 >= -1  ==>  -2X^D >= -2  ==>  X^D <= 1 iff X^D = 1 OR X^D < 1
            // X^D = 1 iff D = 0 OR X = 1, i.e. number has no digits or it is in the base-1.
                // for our practical purposes, this will not be the case, so we can actually set it as a requirement.
                // so it is not true.
            // X^D < 1 iff X < 1, which is not true according to our requirements.
            // so, we supposed that (2) is true but arrived at contradiction, so we conclude that it is false
            // and it follows that (1) is true instead.

        // Because X^2D - 1 is the greatest 2D-digit number in base X, we conclude that the product of
        // two greatest D-digit numbers is less than the greatest 2D-digit numbers, and thus will always
        // have 2D-digits and will never exceed that bound (overflow).

        // that is why we need double-digit width for the result of the product.

    var p = [Digit](repeating: 0, count: a.count * 2)

    for i in (0..<a.count) {
        // take i-th coefficient from a and multiply it by the polynome b
        let l = multiplyByScalar(a[i], b)
            // a[i] is an unsigned fixed width binary integer
            // b is a number with multiple digits
            // requirements are fulfilled, so it is guaranteed that:
            // l is a number equal to product of multiplying a[i] by b
            // l.count == b.count + 1


        // extend the result to be double-digit size, so that resulting product sum can be performed.
        let m = padRight(l, p.count)
            // l is a multi-digit number AND
            // l.count == b.count + 1 AND
            // p.count == a.count * 2 AND
            // a.count == b.count AND
            // i.e. p.count == b.count * 2 which is greater than b.count + 1
            // thus it is guaranteed that
            // m[0..<l.count] == l[0..<l.count] and m[l.count..<p.count] == 0 and m.count == p.count

        // multiply by the base raised to the exponent for the coefficient, i.e. the "i" is the exponent
        // that is equivalent to "shifting" the number to the right for "i" positions.
        // we will never lose the numbers because the width is double-digit
        let r = shiftRight(m, i)
            // m is a multiple-digit number
            // i < m.count
                // true because max(i) == a.count - 1 and m.count == p.count == a.count * 2
                // so, a.count * 2 > a.count - 1 and so m.count > i for all i in the loop.
            // thus it is guaranteed that
            // r.count == m.count and
            // r[0..<i] == 0 && r[i..<m.count] == m[0..<(m.count - i)]
            // so the product is shifted by i positions to the right.

        // add the product to the accumulated sum.
        // the product will never overflow the 2-digit size (see proposition (*) above),
        // so we ignore the "overflow"/carry of the sum
        p = sum(p, r).result
            // r.count == m.count == p.count and
            // p and r are multiple-digit numbers
            // and no overflow can occur,
            // so, it is guaranteed that
            // add().result is the sum of p and r and add().overflow is 0 if no overflow occurred
            // so resulting p is the result of sum p + r
    } // end of the loop
    // all digits of the first number multiplied by the number b and resulting product added together to number p

    return p
        // return the p, a product of a and b.
}

func divide<Digit>(_ a: [Digit], _ b: [Digit]) -> (quotient: [Digit], remainder: [Digit]) where Digit: UnsignedInteger & FixedWidthInteger {
    // division is the inverse of multiplication
        // division without remainder
            // a / b = c is inverse of c * b = a
            // thus, for b > 1
            // a has 2D digits while c and b have D digits.
            // for b == 1: c == a, i.e. a has 2D digits and c has 2D digits.
                // what do we do? we have only D digits to fit,
                // Swift standard library just truncates the result to D digits
            // for b == 0: runtime error, division by zero, i.e. c can be anything
        // division with remainder r > 0
            // a / b = c + r / b where r < b, is inverse of a = c * b + r
            // again, b != 0, otherwise it is division by 0 and is a runtime error
            // b == 1 is impossible, remainder is always 0, because only 0 < 1
            // so, the result is always D-digit long if the dividend is 2D - digit long, and so divisor is also
            // D digits long.

        // division is answering the question: which number multiplied by divisor and then added with which another
        // number would be equal to the dividend? It is equivalent to finding coefficients of the
        // number a in terms of linear combination by factor b:
        // a / b = x + y / b (x is the quotient and y is the remainder)
        // a = x * b^1 + y * b^0 = x * b + y


    ([], [])
}
