# PreciseISO8601DateFormatter

`PreciseISO8601DateFormatter` is a precise and specific date formatter. Apple's built-in [DateFormatter](https://developer.apple.com/documentation/foundation/dateformatter) and [ISO8601DateFormatter](https://developer.apple.com/documentation/foundation/iso8601dateformatter) are only capable of parsing milliseconds. Many services return dates with nanosecond precision in the format `yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'`.  `PreciseISO8601DateFormatter` is able to parse those strings and encode dates into that format.

`PreciseISO8601DateFormatter` is intended to be a drop-in replacement for `DateFormatter` or `ISO8601DateFormatter`. It's a subclass of [Formatter](https://developer.apple.com/documentation/foundation/formatter). Like Apple's built-in date formatters, `PreciseISO8601DateFormatter` is thread-safe.

It's important to note, if you supply the formatter with a date with nanosecond precision, encode it into a string, and then decode that string back into a date, the original date and the decoded date will be different. The decoded date will have lost its nanosecond precision _(i.e., the date's nanosecond component would go from 448814988 to 448814000)_. This means, if you use `PreciseISO8601DateFormatter` to decode the date-time strings returned by your server, you should also use this formatter to store the encoded date-time strings locally.

## Usage

```swift
let formatter = PreciseISO8601DateFormatter()

let date = formatter.date(from: "2021-02-03T12:48:00.000123Z")
let string = formatter.string(from: date) // "2021-02-03T12:48:00.000123Z"
```

## Installation

To use PreciseISO8601DateFormatter with the Swift Package Manager, add a dependency to your Package.swift file:

```swift
let package = Package(
  dependencies: [
    .package(url: "https://github.com/shareup/precise-iso-8601-date-formatter.git", from: "1.0.2")
  ]
)
```

## License

The license for PreciseISO8601DateFormatter is the standard MIT licence. You can find it in the `LICENSE` file.
