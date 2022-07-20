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
///   - `0 < n < a.count`
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

func divide<Digit>(_ a: [Digit], _ b: [Digit]) -> (q: [Digit], r: [Digit]) where Digit: UnsignedInteger & FixedWidthInteger {
    // TODO: handle b == 1
    // TODO: handle b == 0
    // TODO: handle a < b
    // TODO: handle a == b

    // find q
        // n = floor(ln b)
        // n is the exponent of the nearest power of 2 that is less than or equal to b
            // Consider a binary number 0001_0001. It's bit width is 8 bits. It's most significant "1" bit is
            // at index 5. That bit is equivalent to the power of two 2^4, since the 1st bit is for the 2^0 coefficient.
            //
            // So, to get the nearest lower power of two's exponent, we subtract number of leading zeroes from
            // the bit width and reduce by 1 to get the 2's exponent.
            //
            // The lowest value of b with value's bit width B is just 2^(B-1). The highest b is (2^B - 1).
            //
            // By definition, 2^n <= b
    let n = numberBitWidth(b) - numberLeadingZeroBitCount(b) - 1
        // n == 0 when b == 1, but that case is handled already.
        // n < 0 when b == 0, but that case is handled already.
        // so, n > 0 and at least 1.


    let one = padRight( [ Digit(1) ], a.count )
        // one is a number with least significant digit equal to 1, others are 0 digits. OK.

    // u = (a >> n) + 1  = a/2^n + 1
        // what is su, a sign of (a - ub) = a - b(a/2^n + 1))?
            // since (ln b) >= n => 2^ln(b) >= 2^n (because 2 > 1) => b >= 2^n
            // then, for b = 2^n: (a - 2^n(a/2^n + 1) = (a - a - 2^n) => signi is < 0
            // and for b > 2^n: (a - (2^n + k)*(a/2^n + 1) = a - 2^n a / 2^n - 2^n - k a / 2^n - k = a - a - 2^n - ka/2^n - k < 0
            // so, a - ub < 0 or su = -1
    var u = sum( bitShiftRight(a, n), one ).result
        // one.count == a.count is true
        // bitShiftRight(a, n).count == a.count
            // If number of bits in the value of a is less or equal to n, then value can be 0.
                // In other words, a <= 2^n-1. But 2^n <= b, then a < b.
                // But that case is handled already and not possible here.
            // If number of bits in value of a is greater than n, then after shifting right, a > 0.
            // so, the resulting value is greater than 0.

        // sum will not overflow.
            // sum can overflow iff (a >> n) == max number
            // is true when a == max number and n == 0, which is true when b == 1. That case is handled already.
            // Since any number shifted right by n positions is equivalent by dividing by 2^n,
            // therefore sum can overflow if a == max number * 2^n, which is greater than max number possible.
            // Therefore, this sum will not overflow.
        // Now, u is (a >> n) + 1
            // since (a >> n) > 0, then u > 1
        // u.count == a.count == one.count



    // l = a >> (n + 1) ( = a/2^(n+1) )
        // what is sl, a sign of (a - lb) = a - b(a/2^(n+1)) ?
            // since 2^n <= b < 2^(n+1)
            // then b / 2^(n+1) < 1 => a * b / 2^(n+1) < a * 1
            // then, b * l < a, then a - lb > 0, or sl = +1
    var l = bitShiftRight(a, n + 1)
        // Number of bits in the value of a is greater than n.
            // Can it be exactly n + 1?
            // i.e. if a is 001100 and it has 4 bits, then 4 = n + 1, then 3 = n
            // but 2^3 == 001000 and 2^4 = 010000, and a > 2^3 but less than 2^4.
            // If a would be 2^4 then the n + 1 would be 5 and we would have a contradiction.
            // so, 2^n <= a < 2^(n + 1)
            // but if that's the case, then 2^n <= b or 2^3 <= b and b < 2^(n + 1).
            // For example, b can be 001010 which is less than a, but satisfies the constrains.
            // So, it is possible that `a` shifted right by (n + 1) bits would be 0.
        // Therefore, shifting right by n + 1 makes value l >= 0 and less than u
        // u.count == a.count

    var q: [Digit] = []
        // q.count == 0

    // if bounds (l, u) are differ by 1, then the quotient lies between them, meaning we found the answer
    // and the loop below should stop. If bounds differ by 0, then the same, we found the quotient.
    // Until that time we will reduce bounds such that the quotient still lies between them.

    let GREATER_THAN: Digit = 1

    #warning("continue here")

    // while u - l > 1
    while compare( subtract(u, l).result, one ) == GREATER_THAN {
        // loop invariant: a - ub < 0 and a - lb > 0 and u - l > 1
        // step 0: u > l + 1

        // step 0: sl = +1, su = -1 or (sl, su) is (+1, -1)

        // m = u >> 1 + l >> 1 ( = u/2 + l/2 = floor((u + l)/2) )
            // since m is in the middle of the interval, and u - l > 1,
            // then l < m < u
        let m = sum( bitShiftRight(u, 1), bitShiftRight(l, 1) ).result

        // sm = compare(a, mb)
            // get sign of (a - mb), or sign of a remainder when q = m
        let sm = compare(a, multiply(m, b))

        // sl = compare(a, lb)
            // get sign of a remainder when q = l
            // step0: sl = +1
        let sl = compare(a, multiply(l, b))

        // su = compare(a, ub)
            // get sign of a remainder when q = u
            // step 0: su = -1
        let su = compare(a, multiply(u, b))

        if sm == sl {
                // step 0: (sl, sm, su) = (+1, +1, -1), i.e. remainder is 0 between (m and u) => step 1: (+1, -1)
                // step 1: same logic as in as step 0

                // l = m
                    // step 0: next internval is (m, u) => (sl, su) = (+1, -1)
                    // m < u => new l < u
            l = m

        } else if sm == su {
                // step 0: (sl, sm, su) = (+1, -1, -1), i.e. remainder is 0 between (l and m) => step 1: (+1, -1)
                // step 1: same logic as in step 0

                // u = m
                    // step 0: next interval is (l, m) => (sl, su) = (+1, -1)
                    // m > l => new u > l
            u = m

        } else {
        // else sm != sl && sm != su

                // step 0: (+1, 0, -1), i.e. remainder is 0 => found q
                // step 1: same logic as in step 0
                // return q = m
            q = m
            break
        }
    } // end loop
        // return q = l
            // if u - l == 1, then quotient is between l and u, so we take the integer part only, which is l
            // if u - l == 0, then quotient == l == u, so we can take l as an answer.
    if q.isEmpty {
        q = l
    }

    // q is found, then find remainder
    // r = a - bq
    let r = subtract(a, multiply(b, q)).result
    // return (q, r)
    return (q, r)
}
