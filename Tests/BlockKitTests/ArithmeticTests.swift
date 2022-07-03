//
//  ArithmeticTests.swift
//  
//
//  Created by Dmitry Bespalov on 03.07.22.
//

import XCTest
@testable import BlockKit

class ArithmeticTests: XCTestCase {
    typealias Digit = UInt8

    // MARK: addition

    func test_sumDigits_overflow_1() throws {
        let (s, c) = sumScalars(Digit(255), Digit(1))
        XCTAssertEqual(s, 0, "invalid sum")
        XCTAssertEqual(c, 1, "expected overflow")
    }

    func test_sumDigits_overflow_2() throws {
        let (s, c) = sumScalars(Digit(255), Digit(2))
        XCTAssertEqual(s, 1, "invalid sum")
        XCTAssertEqual(c, 1, "expected overflow")
    }

    func test_sumDigits_noOverflow() {
        let (s, c) = sumScalars(Digit(254), Digit(1))
        XCTAssertEqual(s, 255, "invalid sum")
        XCTAssertEqual(c, 0, "not expected overflow")
    }

    func test_sum_2digit_no_overflow() {
        let a: [Digit] = [0, 1] // 256
        let b: [Digit] = [3, 0] // 3
        let c: [Digit] = [3, 1] // 259, no overflow

        let (s, o) = sum(a, b)

        XCTAssertEqual(s, c, "invalid sum")
        XCTAssertEqual(o, 0, "not expected overflow")
    }

    func test_sum_2digit_overflow_1() {
        let a: [Digit] = [255, 255] // 65.535
        let b: [Digit] = [1, 0] // 1
        let c: [Digit] = [0, 0] // overflow!

        let (s, o) = sum(a, b)

        XCTAssertEqual(s, c, "invlaid sum")
        XCTAssertEqual(o, 1, "expected to overflow")
    }

    func test_sum_2digit_overflow_2() {
        let a: [Digit] = [255, 255] // 65.535
        let b: [Digit] = [2, 0] // 2
        let c: [Digit] = [1, 0] // overflow!

        let (s, o) = sum(a, b)

        XCTAssertEqual(s, c, "invlaid sum")
        XCTAssertEqual(o, 1, "expected to overflow")
    }

    func test_sum2digit_overflow_3() {
        let a: [Digit] = [3, 2] // 515
        let b: [Digit] = [255, 255] // 65.535
        let c: [Digit] = [2, 2] // 514

        let (s, o) = sum(a, b)

        XCTAssertEqual(s, c, "invlaid sum")
        XCTAssertEqual(o, 1, "expected to overflow")
    }

    func test_sum_2digit_carryOver() {
        let a: [Digit] = [255, 0] // 255
        let b: [Digit] = [1, 0] // 1
        let c: [Digit] = [0, 1] // 255

        let (s, o) = sum(a, b)

        XCTAssertEqual(s, c, "invalid sum")
        XCTAssertEqual(o, 0, "not expected overflow")
    }

    func test_sum_3digit_carryOver() {
        let a: [Digit] = [255, 255, 0] // 65.535
        let b: [Digit] = [1, 0, 0] // 1
        let c: [Digit] = [0, 0, 1] // 65.536

        let (s, o) = sum(a, b)

        XCTAssertEqual(s, c, "invalid sum")
        XCTAssertEqual(o, 0, "not expected overflow")
    }

    // MARK: subtraction

    func test_subtract_1digit_overflow_1() {
        let (d, c) = subtractScalars(Digit(0), Digit(1))
        XCTAssertEqual(d, 255, "invalid difference")
        XCTAssertEqual(c, 1, "expected overflow")
    }

    func test_subtract_1digit_overflow_2() {
        let (d, c) = subtractScalars(Digit(0), Digit(2))
        XCTAssertEqual(d, 254, "invalid difference")
        XCTAssertEqual(c, 1, "expected overflow")
    }

    func test_subtract_1digit_no_overflow() {
        let (d, c) = subtractScalars(Digit(255), Digit(1))
        XCTAssertEqual(d, 254, "invalid difference")
        XCTAssertEqual(c, 0, "expected overflow")
    }

    func test_subtract_2digit_overflow() {
        let a: [Digit] = [3, 2] // 515
        let b: [Digit] = [255, 255] // 65.535
        let c: [Digit] = [2, 0] // 514

        let (s, o) = subtract(a, b)

        XCTAssertEqual(s, c, "invlaid sum")
        XCTAssertEqual(o, 1, "expected to overflow")
    }
}

class ArithmeticRandomizedTests: XCTestCase {
    // randomized test
    func to_16(_ v: [UInt8]) -> UInt16 {
        UInt16(v[0]) + UInt16(v[1]) * 256
    }

    func test_sum_randomized() {
        continueAfterFailure = false

        // test sum algorithm using digits of
        // smaller size and convert the sum
        // to a bigger bit width to compare
        // with the builtin sum result

        let numberOfOperations = 5_000_000

        for operation in (0..<numberOfOperations) {
            if operation % 100000 == 0 {
                print(operation)
            }

            let a: [UInt8] = [
                .random(in: 0...UInt8.max),
                .random(in: 0...UInt8.max)
            ]

            let b: [UInt8] = [
                .random(in: 0...UInt8.max),
                .random(in: 0...UInt8.max)
            ]

            let c = sum(a, b)

            let c16 = to_16(a).addingReportingOverflow(to_16(b))

            XCTAssertEqual(to_16(c.result), c16.partialValue)
            XCTAssertEqual(c.overflow, c16.overflow ? 1 : 0)
        }
    }

    func test_subtract_randomized() {
        continueAfterFailure = false

        // test subtraction algorithm using digits of
        // smaller size and convert the difference
        // to a bigger bit width to compare
        // with the builtin subtraction result

        let numberOfOperations = 5_000_000

        for operation in (0..<numberOfOperations) {
            if operation % 100_000 == 0 {
                print(operation)
            }

            let a: [UInt8] = [
                .random(in: 0...UInt8.max),
                .random(in: 0...UInt8.max)
            ]

            let b: [UInt8] = [
                .random(in: 0...UInt8.max),
                .random(in: 0...UInt8.max)
            ]

            let c = subtract(a, b)

            let c16 = to_16(a).subtractingReportingOverflow(to_16(b))

            XCTAssertEqual(to_16(c.result), c16.partialValue)
            XCTAssertEqual(c.overflow, c16.overflow ? 1 : 0)
        }
    }
}
