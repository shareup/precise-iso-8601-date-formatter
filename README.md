# PreciseISO8601DateFormatter

`PreciseISO8601DateFormatter` is a precise and specific date formatter. Apple's built-in [DateFormatter](https://developer.apple.com/documentation/foundation/dateformatter) and [ISO8601DateFormatter](https://developer.apple.com/documentation/foundation/iso8601dateformatter) are only capable of parsing milliseconds. Many services return dates with nanosecond precision in the format `yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'`.  `PreciseISO8601DateFormatter` is able to parse those strings and encode dates into that format.

`PreciseISO8601DateFormatter` is intended to be a drop-in replacement for `DateFormatter` or `ISO8601DateFormatter`. It's a subclass of [Formatter](https://developer.apple.com/documentation/foundation/formatter). Like Apple's built-in date formatters, `PreciseISO8601DateFormatter` is thread-safe.

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
    .package(url: "https://github.com/shareup/precise-iso-8601-date-formatter.git", from: "1.0.0")
  ]
)
```

## License

The license for PreciseISO8601DateFormatter is the standard MIT licence. You can find it in the `LICENSE` file.
