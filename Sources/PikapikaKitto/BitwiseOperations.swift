//
//  BitwiseOperations.swift
//  
//
//  Created by Dmitry Bespalov on 07.07.22.
//

import Foundation

func bitShiftRight<Digit>(_ a: [Digit], bits: Int, fill: Digit = 0) -> [Digit] where Digit: FixedWidthInteger & UnsignedInteger {
    // EXTENSION is 0 or all-Fs (max digit)
    let width = Digit.bitWidth
    // shift size aligned with digit bit width
    if bits % width == 0 {
        // shift digits right by ( bits / width ) digits
        var b = [Digit](repeating: fill, count: a.count)
        // for each digit, set its value from source or extension
        for i in (0..<a.count) {
            // result digit is source digit at ( i + bits / width ) or EXTENSION if index out of bounds
            let sourceIndex = i + bits / width
            b[i] = sourceIndex < a.count ? a[sourceIndex] : fill
                // Digits start at lowest significant digit first.
                // Bits of digits start at most significant bit first.
                // That means the digit shift direction is opposite to bit shift direction.
                // If we shift bits right by X, then we shift digits left by X.
                // Meaning, result digit index is less than source digit index by the number of digits shifted.
                // Thus, to get result index, we need to add to it the number of digits shifted.
        }
        return b
    } else {
    // shift size misaligned with digit bit width
        // result's digit is composed of source's parts of two digits
        // for each digit, set its value from source digits or extension
        var b = [Digit](repeating: fill, count: a.count)
        for i in (0..<a.count) {
            // high part is from source digit (i + bits / width + 1) or EXTENSION if index out of bounds
            let highIndex = i + bits / width + 1
                // part is a source digit left-shifted << by ( width - bits % width ) bits
            let highBitShift = width - bits % width
            let highPart = ( highIndex < a.count ? a[highIndex] : fill ) << highBitShift

            // low part is from source digit (i + bits / width ) or EXTENSION if index out of bounds
            let lowIndex = i + bits / width
                // part is a source digit right-shifted >> by ( bits % width ) bits
            let lowBitShift = bits % width
            let lowPart = ( lowIndex < a.count ? a[lowIndex] : fill ) >> lowBitShift

            b[i] = highPart | lowPart
        }
        return b
    }
}

func bitShiftLeft() {
    // EXTENSION is 0 or all-Fs (max digit)
    // shift size aligned with digit bit width
        // shift digits left by ( size / width ) digits
        // result digit is source digit at ( i - size / width ) or EXTENSION if index out of bounds
            // Digits start at least significant digit first.
            // Bits start at most significant bit first.
            // That means that digit shift is opposite to bit shift direction.
            // Left bit shift is right digit shift.
            // Thus, result digit index is more than source digit index by number of digits shifted.
            // Thus, to get result index, we need subtract from it the number of digits shifted.
    // shift size misaligned with digit bit width
        // result's digit is composed of source's parts of two digits
        // high part is from source digit (i - size / width ) or EXTENSION if index out of bounds
            // part is a source digit left-shifted << by ( size % width ) bits
        // low part is from source digit (i - size / width - 1 ) or EXTENSION if index out of bounds
            // part is a source digit right-shifted >> by ( width - size % width ) bits
}

