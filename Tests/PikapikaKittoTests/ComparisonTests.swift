//
//  ComparisonTests.swift
//  
//
//  Created by Dmitry Bespalov on 07.07.22.
//

import XCTest
@testable import PikapikaKitto

class ComparisonTests: XCTestCase {
    typealias Digit = UInt8

    func test_compare() {
        util_generateTable_compare()

        let table: [(a: [Digit], b: [Digit], result: Int)] = [
            (a: [0, 0], b: [0, 0], result: EQUAL),
            (a: [0, 0], b: [1, 0], result: LESS_THAN),
            (a: [0, 1], b: [0, 1], result: EQUAL),
            (a: [0, 1], b: [1, 1], result: LESS_THAN),
            (a: [0, 1], b: [255, 0], result: GREATER_THAN),
            (a: [0, 127], b: [0, 127], result: EQUAL),
            (a: [0, 127], b: [1, 127], result: LESS_THAN),
            (a: [0, 127], b: [255, 126], result: GREATER_THAN),
            (a: [0, 254], b: [0, 254], result: EQUAL),
            (a: [0, 254], b: [1, 254], result: LESS_THAN),
            (a: [0, 254], b: [255, 253], result: GREATER_THAN),
            (a: [0, 255], b: [0, 255], result: EQUAL),
            (a: [0, 255], b: [1, 255], result: LESS_THAN),
            (a: [0, 255], b: [255, 254], result: GREATER_THAN),
            (a: [1, 0], b: [1, 0], result: EQUAL),
            (a: [1, 0], b: [2, 0], result: LESS_THAN),
            (a: [1, 0], b: [0, 0], result: GREATER_THAN),
            (a: [1, 1], b: [1, 1], result: EQUAL),
            (a: [1, 1], b: [2, 1], result: LESS_THAN),
            (a: [1, 1], b: [0, 1], result: GREATER_THAN),
            (a: [1, 127], b: [1, 127], result: EQUAL),
            (a: [1, 127], b: [2, 127], result: LESS_THAN),
            (a: [1, 127], b: [0, 127], result: GREATER_THAN),
            (a: [1, 254], b: [1, 254], result: EQUAL),
            (a: [1, 254], b: [2, 254], result: LESS_THAN),
            (a: [1, 254], b: [0, 254], result: GREATER_THAN),
            (a: [1, 255], b: [1, 255], result: EQUAL),
            (a: [1, 255], b: [2, 255], result: LESS_THAN),
            (a: [1, 255], b: [0, 255], result: GREATER_THAN),
            (a: [127, 0], b: [127, 0], result: EQUAL),
            (a: [127, 0], b: [128, 0], result: LESS_THAN),
            (a: [127, 0], b: [126, 0], result: GREATER_THAN),
            (a: [127, 1], b: [127, 1], result: EQUAL),
            (a: [127, 1], b: [128, 1], result: LESS_THAN),
            (a: [127, 1], b: [126, 1], result: GREATER_THAN),
            (a: [127, 127], b: [127, 127], result: EQUAL),
            (a: [127, 127], b: [128, 127], result: LESS_THAN),
            (a: [127, 127], b: [126, 127], result: GREATER_THAN),
            (a: [127, 254], b: [127, 254], result: EQUAL),
            (a: [127, 254], b: [128, 254], result: LESS_THAN),
            (a: [127, 254], b: [126, 254], result: GREATER_THAN),
            (a: [127, 255], b: [127, 255], result: EQUAL),
            (a: [127, 255], b: [128, 255], result: LESS_THAN),
            (a: [127, 255], b: [126, 255], result: GREATER_THAN),
            (a: [254, 0], b: [254, 0], result: EQUAL),
            (a: [254, 0], b: [255, 0], result: LESS_THAN),
            (a: [254, 0], b: [253, 0], result: GREATER_THAN),
            (a: [254, 1], b: [254, 1], result: EQUAL),
            (a: [254, 1], b: [255, 1], result: LESS_THAN),
            (a: [254, 1], b: [253, 1], result: GREATER_THAN),
            (a: [254, 127], b: [254, 127], result: EQUAL),
            (a: [254, 127], b: [255, 127], result: LESS_THAN),
            (a: [254, 127], b: [253, 127], result: GREATER_THAN),
            (a: [254, 254], b: [254, 254], result: EQUAL),
            (a: [254, 254], b: [255, 254], result: LESS_THAN),
            (a: [254, 254], b: [253, 254], result: GREATER_THAN),
            (a: [254, 255], b: [254, 255], result: EQUAL),
            (a: [254, 255], b: [255, 255], result: LESS_THAN),
            (a: [254, 255], b: [253, 255], result: GREATER_THAN),
            (a: [255, 0], b: [255, 0], result: EQUAL),
            (a: [255, 0], b: [0, 1], result: LESS_THAN),
            (a: [255, 0], b: [254, 0], result: GREATER_THAN),
            (a: [255, 1], b: [255, 1], result: EQUAL),
            (a: [255, 1], b: [0, 2], result: LESS_THAN),
            (a: [255, 1], b: [254, 1], result: GREATER_THAN),
            (a: [255, 127], b: [255, 127], result: EQUAL),
            (a: [255, 127], b: [0, 128], result: LESS_THAN),
            (a: [255, 127], b: [254, 127], result: GREATER_THAN),
            (a: [255, 254], b: [255, 254], result: EQUAL),
            (a: [255, 254], b: [0, 255], result: LESS_THAN),
            (a: [255, 254], b: [254, 254], result: GREATER_THAN),
            (a: [255, 255], b: [255, 255], result: EQUAL),
            (a: [255, 255], b: [254, 255], result: GREATER_THAN),
        ]

        for row in table {
            let expected = row.result
            let result = compare(row.a, row.b)
            XCTAssertEqual(result, expected, "\(row.a) compare \(row.b)")
        }
    }

    func util_generateTable_compare() {
        let S: [Digit] = [0, 1, 127, 254, 255]
        var table: [(a: [Digit], b: [Digit], result: Int)] = []

        for a0 in S {
            for a1 in S {
                let a = UInt16(a0) + UInt16(a1) * 1 << 8

                let b0: (UInt16) -> UInt8 = { b in UInt8(b & 0xff) }
                let b1: (UInt16) -> UInt8 = { b in UInt8(b >> 8) }

                // a = b
                table.append(([a0, a1], [b0(a), b1(a)], EQUAL))

                // a < b: a + 1 = b
                if a < UInt16.max {
                    table.append(([a0, a1], [b0(a + 1), b1(a + 1)], LESS_THAN))
                }

                // a > b: a - 1 = b
                if a > 0 {
                    table.append(([a0, a1], [b0(a - 1), b1(a - 1)], GREATER_THAN))
                }
            }
        }

        for row in table {
            let result = row.result == EQUAL ? "EQUAL" : (row.result == LESS_THAN ? "LESS_THAN" : "GREATER_THAN")
            print("(a: \(row.a), b: \(row.b), result: \(result)),")
        }
    }

    func test_isEqual() {
        let table: [(a: [Digit], b: [Digit], result: Bool)] = [
            // count == 0
            (a: [], b: [], result: true),

            // count == 1
            // both equal
            (a: [0], b: [0], result: true),
            // different
            (a: [0], b: [255], result: false),
            (a: [255], b: [0], result: false),
            (a: [3], b: [7], result: false),

            // count == 4
            // all digits equal
            (a: [1, 2, 3, 4], b: [1, 2, 3, 4], result: true),
            // all digits different
            (a: [1, 2, 3, 4], b: [7, 8, 9, 10], result: false),
            // first digit different (left)
            (a: [7, 2, 3, 4], b: [1, 2, 3, 4], result: false),
            // last digit different (right)
            (a: [1, 2, 3, 4], b: [1, 2, 3, 43], result: false),

            // count == 7
            // all digits equal
            (a: [7, 6, 5, 4, 3, 2, 1], b: [7, 6, 5, 4, 3, 2, 1], result: true),
            // all digits different
            (a: [27, 26, 25, 24, 23, 22, 21], b: [7, 6, 5, 4, 3, 2, 1], result: false),
            // first digit different (left)
            (a: [0, 6, 5, 4, 3, 2, 1], b: [7, 6, 5, 4, 3, 2, 1], result: false),
            // last digit different (right)
            (a: [7, 6, 5, 4, 3, 2, 1], b: [7, 6, 5, 4, 3, 2, 0], result: false),

            // a.count == b.count - 1
            (a: [1, 2, 3], b: [1, 2, 3, 4], result: false),

            // a.count == b.count + 1
            (a: [1, 2, 3, 4], b: [2, 3, 4], result: false),
        ]

        for row in table {
            let result = numbersEqual(row.a, row.b)
            XCTAssertEqual(result, row.result, "\(row.a) == \(row.b))")
        }
    }

}
