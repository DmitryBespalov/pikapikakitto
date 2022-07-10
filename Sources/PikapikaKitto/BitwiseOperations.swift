//
//  BitwiseOperations.swift
//  
//
//  Created by Dmitry Bespalov on 07.07.22.
//

import Foundation


/// Shifts the digit `a` by `t` bits to the right with 0-padding from the left.
///
/// - **Requires**:
///   - a: multiple-digit number, with least significant digit at index 0
/// - **Guarantees**:
///   - if `t < 0` then result is `bitShiftLeft(a, -t)`
///   - if `t == 0` then result is same as input `a`
///   - if `t >= a.count` then result is number with `a.count` zero digits
///   - otherwise, the result is a number shifted to the right by `t` bits and padded with 0-bits from left.
///
/// - Parameters:
///   - a: multi-digit number
///   - t: number of bits to shift `a` right
/// - Returns: number with shifted bits
func bitShiftRight<Digit>(_ a: [Digit], _ t: Int) -> [Digit] where Digit: FixedWidthInteger & UnsignedInteger {
    if t == 0 {
        return a
    }
    // else t != 0

    if t < 0 {
        return bitShiftLeft(a, -t)
    }
    // else t > 0

    // resulting number
    var x = [Digit](repeating: 0, count: a.count)

    if t >= a.count {
        // overshift occurred, no bits of a are in the result.
        return x
    }
    // else t > 0 && t < a.count

    let W = Digit.bitWidth
    let q = t / W
    let r = t % W
    // it follows from above that t == q * W + r

    // let's define a helper: a's subscript that returns 0 if offset is out of bounds
    let a_at: (Int) -> Digit = { offset in  ( offset < a.count && offset >= 0 ) ? a[offset] : 0 }

    if r == 0 {
        for d in (0..<x.count) {
            x[d] = a_at(d + q)
                // Result's digit at offset d is the input's digit at higher index d + q.
                // Shifting bits to the right means shifting from most significant to least significant bits.
                // The more significant digits have higher index, so to get the resulting digit,
                // we add `q` to the result's index to find un-shifted digit.
        }
    } else {
        // else r > 0, meaning shift size is misaligned with digit's bit width.
        //
        // Intuitive understanding would come from observing translation of bits (input to result)
        //
        // |876|543|210| >> 5  => |000|008|765|
        //
        //   2   1   0   // digit index
        // |876|543|210| // input
        // |000|008|765| // result
        //
        // observe that
        // result[0] is composed of lower part of input[2] and higher part of input[1] and
        // 2 = 0 + 5 / 3 + 1 and 1 = 0 + 5 / 3
        //
        // To formalize that, let's consider the follwoing.
        //
        // Any i-th bit of x can be represented as
        // i = dW + j
        // where d is x's digit offset, d: (0..<x.count)
        // and j is the bit offset in d-th the digit, j: (0...W-1)
        //
        // x's bit is taken from the input's bit i'
        // i' = (dW + j) + t = dW + j + qW + r = (dW + qW) + (j + r)
        //
        // since 0 < j < W and 0 < r < W, then 0 < (j + r) < 2W, even more specific,
        // max(j) = max(r) = W - 1  =>  max(j + r) = 2(W - 1) = W + W - 2
        //
        // Then the maximum bit index of the result can come from the bit of the input
        // max i' = (dW + qW) + W + W - 2 = (dW + qW + W) + (W - 2) = (d + q + 1)W + (W - 2)
        //
        // So, when shift amount is misaligned with the digit's bit width, then the bits of the result digit
        // at position d come from bits of digit (d + q) and of digit (d + q + 1).
        //
        // If ordering from most to least significant bits, then those digits are ordered as
        // (d + q + 1), (d + q)
        // and the edge between them lies inside the resulting digit d.
        //
        // The lower `r` bits of (d + q) are shifted to the next digit of the result at index d - 1,
        // and so the remaining higher (W - r) bits of (d + q) are in the digit at index `d`.
            // To get those (W - r) higher bits, we need to shift (d + q) right by `r` bits.
        //
        // Then, the remaining `r` bits of digit `d` are from the lower `r` bits of digit (d + q + 1).
            // To get those r lower bits into correct position, we need to shift (d + q + 1) left by (W - r) bits.
        for d in (0..<x.count) {
            let high = a_at(d + q + 1) << (W - r)
            let low = a_at(d + q) >> r
            x[d] = high | low
        }
    }
    return x
}

/// Shifts the digit `a` by `t` bits to the left with 0-padding from the right.
///
/// - **Requires**:
///   - a: multiple-digit number, with least significant digit at index 0
/// - **Guarantees**:
///   - if `t < 0` then result is `bitShiftRight(a, -t)`
///   - if `t == 0` then result is same as input `a`
///   - if `t >= a.count` then result is number with `a.count` zero digits
///   - otherwise, the result is a number shifted to the left by `t` bits and padded with 0-bits from right.
///
/// - Parameters:
///   - a: multi-digit number
///   - t: number of bits to shift `a` left
/// - Returns: number with shifted bits
func bitShiftLeft<Digit>(_ a: [Digit], _ t: Int) -> [Digit] where Digit: FixedWidthInteger & UnsignedInteger {
    if t == 0 {
        return a
    }
    // else t != 0
    if t < 0 {
        return bitShiftRight(a, -t)
    }
    // else t > 0

    var x = [Digit](repeating: 0, count: a.count)

    if t >= a.count {
        // overshift occurred, no bits of a are in the result.
        return x
    }
    // else t > 0 && t < a.count

    let W = Digit.bitWidth
    let q = t / W
    let r = t % W
    // t == q * W + r

    let a_at: (Int) -> Digit = { offset in  ( offset < a.count && offset >= 0 ) ? a[offset] : 0 }
        // `0` is used if offset < 0 or offset >= a.count

    if r == 0 {
        // shift size divisable without remainder by digit width, so we translate all digits by the factor, `q`.
        for d in (0..<x.count) {
            x[d] = a_at(d - q)
                // left shift by q bits is translating bits from lower indices to higher ones
                // and thus index `d` of a result needs to be decreased by `q` to get to the input digit index.
        }
    } else {
        // else r > 0 && r < W
        //
        // every digit of result is composed of 2 misaligned digits of input
        //
        //
        // |876|543|210| << 5  => |321|000|000|
        //
        //   2   1   0   // digit index
        // |876|543|210| // input
        // |321|000|000| // result
        //
        // reuslt[2] composed of (5 % 3 = 1) lower bit of input[1] and (3 - 5/3 = 2) higher bits of input[0].
        // input indices 1 and 0 are calculated from the result index by 2 - 5/3 = 1 and 2 - 5/3 - 1 = 0
        //
        // Let's generalize to any bit and digit index.
        //
        // The result's bit index is represented as
        // i = dW + j
        // where d is digit offset in the result number, d: [0..<x.count]
        // and j is the bit offset within that digit, j: [0...W-1]
        //
        // The shifted bit of input can be calculated from the result bit with
        // i' = i - t = (dW + j) - (qW + r) = dW + j - qW - r = (d - q)W + (j - r)
        //
        // (j - r) is greatest when j is at max and r is at min, and
        // the difference is lowest when j is at min and r is at max.
        // Since 0 <= r < W and 0 <= j < W, it follows:
        //
        // max(j - r) = max(j) - min(r) = W - 1 - 0 = W - 1
        //
        // min(j - r) = min(j) - max(r) = 0 - (W - 1) = -W + 1
        //
        // so, max(i') = (d - q)W + W - 1
        // and min(i') = (d - q)W - W + 1 = (d - q - 1 + 1)W - W + 1 = (d - q - 1)W + W - W + 1 = (d - q - 1)W + 1
        //
        // The digits at (d - q) and (d - q - 1) if looking from most to least significant digit, are ordered as:
        // (d - q), (d - q - 1)
        // and the digit edge of input lies inside the digit of output.
        //
        // Also, digit (d - q) moved left by `r` bits,
        // so we need to get its (W - r) lower bits into higher bits of result.
        // To do this, we shift the digit left by `r` bits.
        //
        // Next, digit (d - q - 1) was moved left by `r` bits and they ended up in digit `d`.
        // So, we need to get higher `r` bits and put them in the lower bits of digit `d`.
        // To do this, we shift the digit right by (W - r) bits.
        //
        // Gluing together both parts with binary OR will give us the digit of the result.
        //
        // If at any point (d - q) < 0 or (d - q - 1) < 0 we will use value `0` to pad the result.
        for d in (0..<x.count) {
            let high = a_at(d - q) << r
            let low = a_at(d - q - 1) >> (W - r)
            x[d] = high | low
        }
    }
    return x
}
