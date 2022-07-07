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
        // util_generateTable_compare()

        let table: [[Digit]] = [
            [ 0,   0,   0,   0,   0,    ],
            [ 0,   0,   1,   0,   255,  ],
            [ 0,   1,   0,   1,   0,    ],
            [ 0,   1,   1,   1,   255,  ],
            [ 0,   1,   255, 0,   1,    ],
            [ 0,   127, 0,   127, 0,    ],
            [ 0,   127, 1,   127, 255,  ],
            [ 0,   127, 255, 126, 1,    ],
            [ 0,   254, 0,   254, 0,    ],
            [ 0,   254, 1,   254, 255,  ],
            [ 0,   254, 255, 253, 1,    ],
            [ 0,   255, 0,   255, 0,    ],
            [ 0,   255, 1,   255, 255,  ],
            [ 0,   255, 255, 254, 1,    ],
            [ 1,   0,   1,   0,   0,    ],
            [ 1,   0,   2,   0,   255,  ],
            [ 1,   0,   0,   0,   1,    ],
            [ 1,   1,   1,   1,   0,    ],
            [ 1,   1,   2,   1,   255,  ],
            [ 1,   1,   0,   1,   1,    ],
            [ 1,   127, 1,   127, 0,    ],
            [ 1,   127, 2,   127, 255,  ],
            [ 1,   127, 0,   127, 1,    ],
            [ 1,   254, 1,   254, 0,    ],
            [ 1,   254, 2,   254, 255,  ],
            [ 1,   254, 0,   254, 1,    ],
            [ 1,   255, 1,   255, 0,    ],
            [ 1,   255, 2,   255, 255,  ],
            [ 1,   255, 0,   255, 1,    ],
            [ 127, 0,   127, 0,   0,    ],
            [ 127, 0,   128, 0,   255,  ],
            [ 127, 0,   126, 0,   1,    ],
            [ 127, 1,   127, 1,   0,    ],
            [ 127, 1,   128, 1,   255,  ],
            [ 127, 1,   126, 1,   1,    ],
            [ 127, 127, 127, 127, 0,    ],
            [ 127, 127, 128, 127, 255,  ],
            [ 127, 127, 126, 127, 1,    ],
            [ 127, 254, 127, 254, 0,    ],
            [ 127, 254, 128, 254, 255,  ],
            [ 127, 254, 126, 254, 1,    ],
            [ 127, 255, 127, 255, 0,    ],
            [ 127, 255, 128, 255, 255,  ],
            [ 127, 255, 126, 255, 1,    ],
            [ 254, 0,   254, 0,   0,    ],
            [ 254, 0,   255, 0,   255,  ],
            [ 254, 0,   253, 0,   1,    ],
            [ 254, 1,   254, 1,   0,    ],
            [ 254, 1,   255, 1,   255,  ],
            [ 254, 1,   253, 1,   1,    ],
            [ 254, 127, 254, 127, 0,    ],
            [ 254, 127, 255, 127, 255,  ],
            [ 254, 127, 253, 127, 1,    ],
            [ 254, 254, 254, 254, 0,    ],
            [ 254, 254, 255, 254, 255,  ],
            [ 254, 254, 253, 254, 1,    ],
            [ 254, 255, 254, 255, 0,    ],
            [ 254, 255, 255, 255, 255,  ],
            [ 254, 255, 253, 255, 1,    ],
            [ 255, 0,   255, 0,   0,    ],
            [ 255, 0,   0,   1,   255,  ],
            [ 255, 0,   254, 0,   1,    ],
            [ 255, 1,   255, 1,   0,    ],
            [ 255, 1,   0,   2,   255,  ],
            [ 255, 1,   254, 1,   1,    ],
            [ 255, 127, 255, 127, 0,    ],
            [ 255, 127, 0,   128, 255,  ],
            [ 255, 127, 254, 127, 1,    ],
            [ 255, 254, 255, 254, 0,    ],
            [ 255, 254, 0,   255, 255,  ],
            [ 255, 254, 254, 254, 1,    ],
            [ 255, 255, 255, 255, 0,    ],
            [ 255, 255, 254, 255, 1,    ],
        ]

        for row in table {
            let a = [row[0], row[1]]
            let b = [row[2], row[3]]
            let expected = row[4]
            let result = compare(a, b)
            XCTAssertEqual(result, expected, "\(a) compare \(b)")
        }
    }

    func util_generateTable_compare() {
        let S: [Digit] = [0, 1, 127, 254, 255]
        var table: [[Digit]] = []

        for a0 in S {
            for a1 in S {
                let a = UInt16(a0) + UInt16(a1) * 1 << 8

                let b0: (UInt16) -> UInt8 = { b in UInt8(b & 0xff) }
                let b1: (UInt16) -> UInt8 = { b in UInt8(b >> 8) }

                // a = b
                table.append([a0, a1, b0(a), b1(a), 0])

                // a < b: a + 1 = b
                if a < UInt16.max {
                    table.append([a0, a1, b0(a + 1), b1(a + 1), Digit.max])
                }

                // a > b: a - 1 = b
                if a > 0 {
                    table.append([a0, a1, b0(a - 1), b1(a - 1), 1])
                }
            }
        }

        for row in table {
            let line = row.map { "\($0),".padding(toLength: 5, withPad: " ", startingAt: 0) }.joined()
            print("[ \(line) ],")
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
