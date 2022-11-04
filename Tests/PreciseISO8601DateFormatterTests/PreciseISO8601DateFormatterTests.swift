@testable import PreciseISO8601DateFormatter
import XCTest

final class PreciseISO8601DateFormatterTests: XCTestCase {
    func testStringFromDate() {
        let formatter = PreciseISO8601DateFormatter()

        XCTAssertEqual(
            "1799-09-01T01:59:30.123456Z",
            formatter.string(from: distantPast)
        )

        XCTAssertEqual(
            "2021-02-03T12:48:00.000123Z",
            formatter.string(from: recentPast)
        )

        XCTAssertEqual(
            "2039-12-31T23:59:59.999999Z",
            formatter.string(from: nearFuture)
        )

        XCTAssertEqual(
            "2499-01-01T00:00:00.000000Z",
            formatter.string(from: distantFuture)
        )
    }

    func testDateForString() {
        let formatter = PreciseISO8601DateFormatter()

        XCTAssertEqual(
            distantPast,
            formatter.date(from: "1799-09-01T01:59:30.123456Z")
        )

        XCTAssertEqual(
            recentPast,
            formatter.date(from: "2021-02-03T12:48:00.000123Z")
        )

        XCTAssertEqual(
            nearFuture,
            formatter.date(from: "2039-12-31T23:59:59.999999Z")
        )

        XCTAssertEqual(
            distantFuture,
            formatter.date(from: "2499-01-01T00:00:00.000000Z")
        )

        XCTAssertNil(formatter.date(from: ""))
        XCTAssertNil(formatter.date(from: "🦹‍♂️🧙‍♂️a"))
        XCTAssertNil(formatter.date(from: "2021-02-03T12:48:00.000123"))
        XCTAssertNil(formatter.date(from: "2021-02-03t12:48:00.000123Z"))
        XCTAssertNil(formatter.date(from: "2021102-03T12:48:00.000123Z"))
        XCTAssertNil(formatter.date(from: "2021-02-03T12:48:00.00012ZZ"))
    }

    func testThreadSafety() {
        let formatter = PreciseISO8601DateFormatter()

        let dates = dates(count: 1000)

        let group = DispatchGroup()

        (0 ..< 10_000).forEach { _ in
            group.enter()

            DispatchQueue.global().async {
                let str = formatter.string(from: dates.randomElement()!)
                XCTAssertNotNil(formatter.date(from: str))
                group.leave()
            }
        }

        group.wait()
    }

    func testStringForObject() {
        let formatter = PreciseISO8601DateFormatter()

        XCTAssertEqual(
            "2021-02-03T12:48:00.000123Z",
            formatter.string(for: recentPast)
        )

        XCTAssertNil(formatter.string(for: "🦹‍♂️🧙‍♂️a"))
        XCTAssertNil(formatter.string(for: NSDictionary()))
        XCTAssertNil(formatter.string(for: NSNull()))
        XCTAssertNil(formatter.string(for: nil))
    }

    func testObjectForStringWithValidString() {
        let formatter = PreciseISO8601DateFormatter()

        let outputPointer = UnsafeMutablePointer<Date?>.allocate(capacity: 1)
        outputPointer.initialize(to: nil)
        let output = AutoreleasingUnsafeMutablePointer<AnyObject?>(outputPointer)

        let errorPointer = UnsafeMutablePointer<String?>.allocate(capacity: 1)
        errorPointer.initialize(to: nil)
        let error = AutoreleasingUnsafeMutablePointer<NSString?>(errorPointer)

        XCTAssertTrue(formatter.getObjectValue(
            output,
            for: "2021-02-03T12:48:00.000123Z",
            errorDescription: error
        ))

        XCTAssertEqual(recentPast, output.pointee as? Date)
        XCTAssertNil(error.pointee)
    }

    func testObjectForStringWithInvalidStringAndErrorPointer() {
        let formatter = PreciseISO8601DateFormatter()

        let outputPointer = UnsafeMutablePointer<Date?>.allocate(capacity: 1)
        outputPointer.initialize(to: nil)
        let output = AutoreleasingUnsafeMutablePointer<AnyObject?>(outputPointer)

        let errorPointer = UnsafeMutablePointer<String?>.allocate(capacity: 1)
        errorPointer.initialize(to: nil)
        let error = AutoreleasingUnsafeMutablePointer<NSString?>(errorPointer)

        XCTAssertFalse(formatter.getObjectValue(
            output,
            for: "🦹‍♂️🧙‍♂️a",
            errorDescription: error
        ))

        XCTAssertNil(output.pointee)
        XCTAssertEqual("yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'", error.pointee)
    }

    func testObjectForStringWithInvalidStringAndNoErrorPointer() {
        let formatter = PreciseISO8601DateFormatter()

        let outputPointer = UnsafeMutablePointer<Date?>.allocate(capacity: 1)
        outputPointer.initialize(to: nil)
        let output = AutoreleasingUnsafeMutablePointer<AnyObject?>(outputPointer)

        XCTAssertFalse(formatter.getObjectValue(
            output,
            for: "🦹‍♂️🧙‍♂️a",
            errorDescription: nil
        ))

        XCTAssertNil(output.pointee)
    }

    // 0.646 sec
    func testPerformanceOfISO8601DateFormatter() {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFractionalSeconds, .withInternetDateTime]

        let dates = dates(count: 10_000)

        measure {
            for date in dates {
                let string = formatter.string(from: date)
                let date = formatter.date(from: string)
                assert(date != nil)
            }
        }
    }

    // 0.284 sec
    func testPerformanceOfPreciseISO8601DateFormatter() {
        let formatter = PreciseISO8601DateFormatter()

        let dates = dates(count: 10_000)

        measure {
            for date in dates {
                let string = formatter.string(from: date)
                let date = formatter.date(from: string)
                assert(date != nil)
            }
        }
    }
}

private extension PreciseISO8601DateFormatterTests {
    var distantPast: Date {
        DateComponents(
            calendar: Calendar(identifier: .iso8601),
            timeZone: .init(secondsFromGMT: 0),
            year: 1799,
            month: 9,
            day: 1,
            hour: 1,
            minute: 59,
            second: 30,
            nanosecond: Int(NSEC_PER_USEC) * 123_456
        ).date!
    }

    var recentPast: Date {
        DateComponents(
            calendar: Calendar(identifier: .iso8601),
            timeZone: .init(secondsFromGMT: 0),
            year: 2021,
            month: 2,
            day: 3,
            hour: 12,
            minute: 48,
            second: 0,
            nanosecond: Int(NSEC_PER_USEC) * 123
        ).date!
    }

    var nearFuture: Date {
        DateComponents(
            calendar: Calendar(identifier: .iso8601),
            timeZone: .init(secondsFromGMT: 0),
            year: 2039,
            month: 12,
            day: 31,
            hour: 23,
            minute: 59,
            second: 59,
            nanosecond: Int(NSEC_PER_USEC) * 999_999
        ).date!
    }

    var distantFuture: Date {
        DateComponents(
            calendar: Calendar(identifier: .iso8601),
            timeZone: .init(secondsFromGMT: 0),
            year: 2499,
            month: 1,
            day: 1,
            hour: 0,
            minute: 00,
            second: 00,
            nanosecond: Int(NSEC_PER_USEC) * 0
        ).date!
    }

    func dates(count: Int) -> [Date] {
        (0 ..< count).map {
            Date(timeIntervalSince1970: TimeInterval($0))
        }
    }
}
