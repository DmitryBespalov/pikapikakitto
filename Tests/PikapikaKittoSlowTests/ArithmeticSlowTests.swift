//
//  ArithmeticRandomizedTests.swift
//  
//
//  Created by Dmitry Bespalov on 05.07.22.
//

import XCTest
@testable import PikapikaKitto

class ArithmeticRandomizedTests: XCTestCase {
    let numberOfOperations = 1_000_000

    func to_16(_ v: [UInt8]) -> UInt16 {
        UInt16(v[0]) + UInt16(v[1]) * 256
    }

    func test_sum_randomized() {
        continueAfterFailure = false

        // test sum algorithm using digits of
        // smaller size and convert the sum
        // to a bigger bit width to compare
        // with the builtin sum result

        for operation in (0..<numberOfOperations) {

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


            if operation % 100_000 == 0 {
                print(operation * 100 / numberOfOperations, "%", a, b, c)
            }

            XCTAssertEqual(to_16(c.result), c16.partialValue, "\(a) + \(b) = \(c)")
            XCTAssertEqual(c.overflow, c16.overflow ? 1 : 0, "\(a) + \(b) = \(c)")
        }
    }

    func test_subtract_randomized() {
        continueAfterFailure = false

        // test subtraction algorithm using digits of
        // smaller size and convert the difference
        // to a bigger bit width to compare
        // with the builtin subtraction result

        for operation in (0..<numberOfOperations) {
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

            if operation % 100_000 == 0 {
                print(operation * 100 / numberOfOperations, "%", a, b, c)
            }

            XCTAssertEqual(to_16(c.result), c16.partialValue, "\(a) - \(b) = \(c)")
            XCTAssertEqual(c.overflow, c16.overflow ? 1 : 0, "\(a) - \(b) = \(c)")
        }
    }
}
