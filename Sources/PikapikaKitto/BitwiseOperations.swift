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
    // Now, t != 0

    if t < 0 {
        return bitShiftLeft(a, -t)
    }
    // Now, t > 0

    // resulting number
    var x = [Digit](repeating: 0, count: a.count)

    if t >= a.count {
        // overshift occurred, no bits of a are in the result.
        return x
    }
    // Now, t > 0 && t < a.count

    let W = Digit.bitWidth
    let q = t / W
    let r = t % W
    // it follows from above that t == q * W + r

    // let's define a helper: a's subscript that returns 0 if offset is out of bounds
    let a_at: (Int) -> Digit = { offset in  offset < a.count && offset >= 0 ? a[offset] : 0 }

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

func bitShiftLeft<Digit>(_ a: [Digit], _ t: Int) -> [Digit] where Digit: FixedWidthInteger & UnsignedInteger {
    // `fill` is 0 or all-Fs (max digit)
    // shift size aligned with digit bit width
        // shift digits left by ( size / bitWidth ) digits
        // result digit is source digit at ( i - size / bitWidth ) or `fill` if index out of bounds
            // Digits start at least significant digit first.
            // Bits start at most significant bit first.
            // That means that digit shift is opposite to bit shift direction.
            // Left bit shift is right digit shift.
            // Thus, result digit index is more than source digit index by number of digits shifted.
            // Thus, to get result index, we need subtract from it the number of digits shifted.
    // shift size misaligned with digit bit width
        // result's digit is composed of source's parts of two digits
        // high part is from source digit (i - size / bitWidth ) or `fill` if index out of bounds
            // part is a source digit left-shifted << by ( size % bitWidth ) bits
        // low part is from source digit (i - size / bitWidth - 1 ) or `fill` if index out of bounds
            // part is a source digit right-shifted >> by ( bitWidth - size % bitWidth ) bits
    []
}

