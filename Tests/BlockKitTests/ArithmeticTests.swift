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
        let (s, c) = addScalars(Digit(255), Digit(1))
        XCTAssertEqual(s, 0, "invalid sum")
        XCTAssertEqual(c, 1, "expected overflow")
    }

    func test_sumDigits_overflow_2() throws {
        let (s, c) = addScalars(Digit(255), Digit(2))
        XCTAssertEqual(s, 1, "invalid sum")
        XCTAssertEqual(c, 1, "expected overflow")
    }

    func test_sumDigits_noOverflow() {
        let (s, c) = addScalars(Digit(254), Digit(1))
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
        let c: [Digit] = [4, 2] // 514

        let (s, o) = subtract(a, b)

        XCTAssertEqual(s, c, "invlaid sum")
        XCTAssertEqual(o, 1, "expected to overflow")
    }

    func test_multiplyScalars() {
        let table: [[Digit]] = [
        //  [a,     b,     c[0],   c[1]
            [0,     0,      0,      0],
            [0,     1,      0,      0],
            [0,     128,    0,      0],
            [0,     254,    0,      0],
            [0,     255,    0,      0],

            [1,     0,      0,      0],
            [1,     1,      1,      0],
            [1,     128,  128,      0],
            [1,     254,  254,      0],
            [1,     255,  255,      0],

            [128,   0,      0,      0],
            [128,   1,     128,     0],
            [128,   128,    0,     64],
            [128,   254,    0,    127],
            [128,   255,  128,    127],

            [254,   0,      0,      0],
            [254,   1,    254,      0],
            [254,   128,    0,    127],
            [254,   254,    4,    252],
            [254,   255,    2,    253],

            [255,   0,      0,      0],
            [255,   1,    255,      0],
            [255,   128,  128,    127],
            [255,   254,    2,    253],
            [255,   255,    1,    254],
        ]

        for row in table {
            let product = multiplyScalars(row[0], row[1])
            let expected = [row[2], row[3]]
            XCTAssertEqual(product, expected, "\(row[0]) x \(row[1])")
        }
    }

    func test_multiplyByScalar() {
        let table: [[Digit]] = [
            [0,    0,    0,    0,    0,    0,    ],
            [0,    0,    1,    0,    0,    0,    ],
            [0,    0,    128,  0,    0,    0,    ],
            [0,    0,    254,  0,    0,    0,    ],
            [0,    0,    255,  0,    0,    0,    ],
            [0,    1,    0,    0,    0,    0,    ],
            [0,    1,    1,    0,    0,    0,    ],
            [0,    1,    128,  0,    0,    0,    ],
            [0,    1,    254,  0,    0,    0,    ],
            [0,    1,    255,  0,    0,    0,    ],
            [0,    128,  0,    0,    0,    0,    ],
            [0,    128,  1,    0,    0,    0,    ],
            [0,    128,  128,  0,    0,    0,    ],
            [0,    128,  254,  0,    0,    0,    ],
            [0,    128,  255,  0,    0,    0,    ],
            [0,    254,  0,    0,    0,    0,    ],
            [0,    254,  1,    0,    0,    0,    ],
            [0,    254,  128,  0,    0,    0,    ],
            [0,    254,  254,  0,    0,    0,    ],
            [0,    254,  255,  0,    0,    0,    ],
            [0,    255,  0,    0,    0,    0,    ],
            [0,    255,  1,    0,    0,    0,    ],
            [0,    255,  128,  0,    0,    0,    ],
            [0,    255,  254,  0,    0,    0,    ],
            [0,    255,  255,  0,    0,    0,    ],
            [1,    0,    0,    0,    0,    0,    ],
            [1,    0,    1,    0,    1,    0,    ],
            [1,    0,    128,  0,    128,  0,    ],
            [1,    0,    254,  0,    254,  0,    ],
            [1,    0,    255,  0,    255,  0,    ],
            [1,    1,    0,    1,    0,    0,    ],
            [1,    1,    1,    1,    1,    0,    ],
            [1,    1,    128,  1,    128,  0,    ],
            [1,    1,    254,  1,    254,  0,    ],
            [1,    1,    255,  1,    255,  0,    ],
            [1,    128,  0,    128,  0,    0,    ],
            [1,    128,  1,    128,  1,    0,    ],
            [1,    128,  128,  128,  128,  0,    ],
            [1,    128,  254,  128,  254,  0,    ],
            [1,    128,  255,  128,  255,  0,    ],
            [1,    254,  0,    254,  0,    0,    ],
            [1,    254,  1,    254,  1,    0,    ],
            [1,    254,  128,  254,  128,  0,    ],
            [1,    254,  254,  254,  254,  0,    ],
            [1,    254,  255,  254,  255,  0,    ],
            [1,    255,  0,    255,  0,    0,    ],
            [1,    255,  1,    255,  1,    0,    ],
            [1,    255,  128,  255,  128,  0,    ],
            [1,    255,  254,  255,  254,  0,    ],
            [1,    255,  255,  255,  255,  0,    ],
            [128,  0,    0,    0,    0,    0,    ],
            [128,  0,    1,    0,    128,  0,    ],
            [128,  0,    128,  0,    0,    64,   ],
            [128,  0,    254,  0,    0,    127,  ],
            [128,  0,    255,  0,    128,  127,  ],
            [128,  1,    0,    128,  0,    0,    ],
            [128,  1,    1,    128,  128,  0,    ],
            [128,  1,    128,  128,  0,    64,   ],
            [128,  1,    254,  128,  0,    127,  ],
            [128,  1,    255,  128,  128,  127,  ],
            [128,  128,  0,    0,    64,   0,    ],
            [128,  128,  1,    0,    192,  0,    ],
            [128,  128,  128,  0,    64,   64,   ],
            [128,  128,  254,  0,    64,   127,  ],
            [128,  128,  255,  0,    192,  127,  ],
            [128,  254,  0,    0,    127,  0,    ],
            [128,  254,  1,    0,    255,  0,    ],
            [128,  254,  128,  0,    127,  64,   ],
            [128,  254,  254,  0,    127,  127,  ],
            [128,  254,  255,  0,    255,  127,  ],
            [128,  255,  0,    128,  127,  0,    ],
            [128,  255,  1,    128,  255,  0,    ],
            [128,  255,  128,  128,  127,  64,   ],
            [128,  255,  254,  128,  127,  127,  ],
            [128,  255,  255,  128,  255,  127,  ],
            [254,  0,    0,    0,    0,    0,    ],
            [254,  0,    1,    0,    254,  0,    ],
            [254,  0,    128,  0,    0,    127,  ],
            [254,  0,    254,  0,    4,    252,  ],
            [254,  0,    255,  0,    2,    253,  ],
            [254,  1,    0,    254,  0,    0,    ],
            [254,  1,    1,    254,  254,  0,    ],
            [254,  1,    128,  254,  0,    127,  ],
            [254,  1,    254,  254,  4,    252,  ],
            [254,  1,    255,  254,  2,    253,  ],
            [254,  128,  0,    0,    127,  0,    ],
            [254,  128,  1,    0,    125,  1,    ],
            [254,  128,  128,  0,    127,  127,  ],
            [254,  128,  254,  0,    131,  252,  ],
            [254,  128,  255,  0,    129,  253,  ],
            [254,  254,  0,    4,    252,  0,    ],
            [254,  254,  1,    4,    250,  1,    ],
            [254,  254,  128,  4,    252,  127,  ],
            [254,  254,  254,  4,    0,    253,  ],
            [254,  254,  255,  4,    254,  253,  ],
            [254,  255,  0,    2,    253,  0,    ],
            [254,  255,  1,    2,    251,  1,    ],
            [254,  255,  128,  2,    253,  127,  ],
            [254,  255,  254,  2,    1,    253,  ],
            [254,  255,  255,  2,    255,  253,  ],
            [255,  0,    0,    0,    0,    0,    ],
            [255,  0,    1,    0,    255,  0,    ],
            [255,  0,    128,  0,    128,  127,  ],
            [255,  0,    254,  0,    2,    253,  ],
            [255,  0,    255,  0,    1,    254,  ],
            [255,  1,    0,    255,  0,    0,    ],
            [255,  1,    1,    255,  255,  0,    ],
            [255,  1,    128,  255,  128,  127,  ],
            [255,  1,    254,  255,  2,    253,  ],
            [255,  1,    255,  255,  1,    254,  ],
            [255,  128,  0,    128,  127,  0,    ],
            [255,  128,  1,    128,  126,  1,    ],
            [255,  128,  128,  128,  255,  127,  ],
            [255,  128,  254,  128,  129,  253,  ],
            [255,  128,  255,  128,  128,  254,  ],
            [255,  254,  0,    2,    253,  0,    ],
            [255,  254,  1,    2,    252,  1,    ],
            [255,  254,  128,  2,    125,  128,  ],
            [255,  254,  254,  2,    255,  253,  ],
            [255,  254,  255,  2,    254,  254,  ],
            [255,  255,  0,    1,    254,  0,    ],
            [255,  255,  1,    1,    253,  1,    ],
            [255,  255,  128,  1,    126,  128,  ],
            [255,  255,  254,  1,    0,    254,  ],
            [255,  255,  255,  1,    255,  254,  ],
        ]

        for row in table {
            let product = multiplyByScalar(row[0], [row[1], row[2]])
            let expected = [row[3], row[4], row[5]]
            XCTAssertEqual(product, expected, "\(row[0]) x (\(row[1]), \(row[2]))")
        }
    }

    func util_generate_multiplyByScalarTable() {
        let S: [UInt8] = [0, 1, 128, 254, 255]

        for a in S {
            for b0 in S {
                for b1 in S {
                    let c: UInt32 = UInt32(a) * (UInt32(b0) + UInt32(b1) * 1 << 8)
                    let c2 = c / 1 << 16
                    let c1 = (c - c2 * 1 << 16) / (1 << 8)
                    let c0 = (c - (c2 * 1 << 16 + c1 * 1 << 8))

                    assert(c0 + 1 << 8 * c1 + 1 << 16 * c2 == c)

                    let row = [a, b0, b1, UInt8(c0), UInt8(c1), UInt8(c2)]

                    print("[" + row.map(String.init(describing:)).map { ($0 + ",").padding(toLength: 6, withPad: " ", startingAt: 0)}.joined() + "],")
                }
            }
        }

    }
}
