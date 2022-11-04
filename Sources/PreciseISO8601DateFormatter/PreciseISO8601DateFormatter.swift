import Foundation
import Synchronized

public final class PreciseISO8601DateFormatter: Formatter, @unchecked
Sendable {
    private let calendar: Locked<Calendar>

    override public init() {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        calendar.locale = Locale(identifier: "en_US_POSIX")
        self.calendar = Locked(calendar)
        super.init()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func string(for obj: Any?) -> String? {
        guard let date = obj as? Date else { return nil }
        return string(from: date)
    }

    override public func getObjectValue(
        _ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?,
        for string: String,
        errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?
    ) -> Bool {
        if let date = date(from: string) {
            obj?.pointee = date as AnyObject
            return true
        } else {
            error?.pointee = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'" as NSString
            return false
        }
    }
}

public extension PreciseISO8601DateFormatter {
    func string(from date: Date) -> String {
        let components = calendar.access { calendar in
            calendar.dateComponents(iso8601Components, from: date)
        }

        let (quotient, remainder) = components
            .nanosecond!
            .quotientAndRemainder(dividingBy: nsecPerUsec)

        let microsecond = quotient + (remainder >= 500 ? 1 : 0)

        return String(
            format: "%04d-%02d-%02dT%02d:%02d:%02d.%06dZ",
            locale: nil,
            components.year!,
            components.month!,
            components.day!,
            components.hour!,
            components.minute!,
            components.second!,
            microsecond
        )
    }

    func date(from string: String) -> Date? {
        guard string.utf8.count == 27 else { return nil }

        let startIndex = string.startIndex
        let endIndex = string.endIndex

        func index(at offset: Int) throws -> String.Index {
            let i = string.index(
                startIndex,
                offsetBy: offset,
                limitedBy: endIndex
            )
            guard let i else { throw ParseError() }
            return i
        }

        func value(at range: Range<Int>) throws -> Int {
            let start = try index(at: range.lowerBound)
            let end = try index(at: range.upperBound)

            guard let value = Int(string[start ..< end])
            else { throw ParseError() }

            return value
        }

        func assertValue(at i: Int, equals expected: String) throws {
            let start = try index(at: i)
            let end = try index(at: i + 1)
            guard expected == string[start ..< end]
            else { throw ParseError() }
        }

        do {
            var components = DateComponents()
            components.year = try value(at: 0 ..< 4)
            try assertValue(at: 4, equals: "-")
            components.month = try value(at: 5 ..< 7)
            try assertValue(at: 7, equals: "-")
            components.day = try value(at: 8 ..< 10)
            try assertValue(at: 10, equals: "T")
            components.hour = try value(at: 11 ..< 13)
            try assertValue(at: 13, equals: ":")
            components.minute = try value(at: 14 ..< 16)
            try assertValue(at: 16, equals: ":")
            components.second = try value(at: 17 ..< 19)
            try assertValue(at: 19, equals: ".")
            components.nanosecond = nsecPerUsec * (try value(at: 20 ..< 26))
            try assertValue(at: 26, equals: "Z")

            return calendar.access { $0.date(from: components) }
        } catch {
            return nil
        }
    }
}

private struct ParseError: Error {}

private let nsecPerUsec = Int(NSEC_PER_USEC)

private let iso8601Components: Set<Calendar.Component> = [
    .year, .month, .day, .hour, .minute, .second, .nanosecond,
]
