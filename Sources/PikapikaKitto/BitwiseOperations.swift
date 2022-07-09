//
//  BitwiseOperations.swift
//  
//
//  Created by Dmitry Bespalov on 07.07.22.
//

import Foundation

/// Shifts multiple-digit number to the right by `bitShiftCount` number of bits, filling the
/// left part with either 0 or 1s.
///
/// - **Requires**:
///   - a: multiple-digit fixed width number, least significant digit first (at index 0)
///   - `bits > 0 && bits < a.count`
///   - `fill == 0 || fill == Digit.max`  (all 0-s or all 1-s)
/// - **Guarantees**:
///   - `result_bits[i] == source_bits[i + bitShiftCount] for i >= bitShiftCount and i < result_bits.count`
///   - `result_bits[i] == 0 for i < bitShiftCount and i > 0`
///   - `result.count == a.count`
///
/// - Parameters:
///   - a: number to shift
///   - bits: shift size
///   - fill: pass 0 or Digit.max (0 default) which will be used to fill the bits on the left
/// - Returns: shifted number
func bitShiftRight<Digit>(_ a: [Digit], bitShiftCount: Int) -> [Digit] where Digit: FixedWidthInteger & UnsignedInteger {
    let misalignment = bitShiftCount % Digit.bitWidth
        // there are 2 cases to handle:
        // when the number of bits to shift is exactly divisible by the digit's bit width,
        // and when there's a remainder, leading to a misalignment of source/result digit edges
        // that we need to account for.

    let digitShiftCount = bitShiftCount / Digit.bitWidth
        // this is the integer number of digits shifted by the bit shift.
        // if `bitShiftCount` is high enough, the `digitShiftCount` number of most significant digits will be
        // completely equal to the `fill` in the result.

    // Case 1) shift size is aligned with digit's bit width
        // shift digits of a number right by the `digitShiftCount` amount
        // because the bit shift divides without remainder by the digit bit width
    if misalignment == 0 {
        var b = [Digit](repeating: 0, count: a.count)

        // for each digit, set its value from source
        for resultIndex in (0..<b.count) {

            // result's digit is a shifted source digit by `digitShiftCount` number, or "fill" value if out of bounds
            let sourceIndex = resultIndex + digitShiftCount
            b[resultIndex] = sourceIndex < a.count ? a[sourceIndex] : 0
                // in a bit shift by M bits,
                // if M % bitWidth == 0 then D = (M / bitWidth) is the shift of digits to
                // the bit shift direction.
                //
                // Given that the least significant digit is at index 0, and most
                // significant digit is at the index `a.count - 1`,
                //
                // k-th bit of source digit at index j becomes k-th bit of result digit at (j - D).
                //  <=> k-th bit of result digit at j is from k-th bit of source digit (j + D).
        }
        return b
    } else {
    // Case 2) shift size misaligned with digit bit width
        // misalignment < bitWidth, therefore resulting digit may be composed of
        // parsts of 2 source digits next to each other.

        var b = [Digit](repeating: 0, count: a.count)

        // for each digit, set its value from source digits
        for resultIndex in (0..<a.count) {

            // result digit is composed of 2 parts: high (bits) part and low (bits) part.

            // high part is from source digit (i + bits / bitWidth + 1)
            let highSourceIndex = resultIndex + digitShiftCount + 1
                // in a bit shift by M bits,
                // if p = (M % bitWidth) and p != 0 then D = (M / bitWidth) and M = D + p
                // a's digit indices
                // D <= i < a.count --> i - D (higher part) and to i - D - 1 (lower part)
                // i < qD --> out of bounds
                

                // because bits and digits' indices start at opposite sides,
                // the right bit shift leads to the left digit shift,
                // which means that the source index is greater than the result index,
                // and that result digit is composed from the shifted digit and the one next to it.
                //
                //
                //  The source's index is same as result by adding the number
                //  of digits shifted, and adding 1 to account for misalignment
                //  with the bit width of each digit
                //
                //  Example:
                //
                //    3     2   1    0           <- digit's index
                //  |1001|1010|1011|1100| >> 5      source digits
                //
                //    3     2     1     0
                //  |0000|0.100|1.101|0.101|1.1100  result digits
                //
                //     here the "." is the source's digit edge
                //
                //  We see that the source translated to the right by 5 bits
                //  which led to the 2nd result digit be produced from "fill" value and from
                //  part of the 3rd source digit, 1st result digit produced from
                //  3rd and 2nd source digits, and 0-th result digit produced from
                //  2nd and 1st source digit. The 0-th source digit went away completely.

            // high part is a source digit left-shifted << by ( bitWidth - misalignment ) bits
            let highBitShift = Digit.bitWidth - misalignment
            let highPart = ( highSourceIndex < a.count ? a[highSourceIndex] : 0 ) << highBitShift
                // consider the high ("left") part of the result.
                // it comes from the low ("right") part of a source digit
                //
                // source[3] |1001|
                // result[1] |1...|
                //
                // misalignment by 1 means the low part of source gets pushed to the high part of result.
                // thus, to get the high part of the result,
                // we need to shift the source digit to the *left* so that only the `misalignment'
                // number of bits has left, i.e. we shift by (bitWidth - misalignment).

            // low part is from source digit (i + bits / bitWidth )
                // similar to the high part's logic, the low part's digit is coming from
                // a source digit at higher index which is bigger than the result index
                // by the number of digits shifted.
            let lowIndex = resultIndex + digitShiftCount

            // part is a source digit right-shifted >> by ( misalignment ) bits
            let lowBitShift = misalignment
            let lowPart = ( lowIndex < a.count ? a[lowIndex] : 0 ) >> lowBitShift
                // consider the low (right) part of the result.
                // It comes from the high (left) part of the source digit.
                //
                // source[2] |1010|
                // result[1] |.101|
                //
                // so we can get the low part by shifting the source digit to the *right*
                // by the number of misaligned bits.

            b[resultIndex] = highPart | lowPart
                // High part is shifted left by (bitWidth - misalignment) that number of 0-bits on the right.
                // Low part is shifted right by the (misalignment) and has that number of 0-bits on the left.
                // Thus, bitwise OR would superimpose high and low parts to produce the resulting digit.
        }
        return b
    }
}

func bitShiftLeft() {
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
}

