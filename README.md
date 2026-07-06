# Speedometer

[![CI](https://github.com/nschmeller/speedometer/actions/workflows/ci.yml/badge.svg)](https://github.com/nschmeller/speedometer/actions/workflows/ci.yml)

A dead-simple iOS speedometer. It shows your current GPS speed in mph or
km/h. Nothing else.

- No ads, no tracking, no network access — location data never leaves the
  device
- Speed comes straight from Core Location; invalid readings show as `––`
  instead of a guess

## Building

Requires Xcode 16+ and [XcodeGen](https://github.com/yonaskolb/XcodeGen):

```sh
xcodegen generate
open Speedometer.xcodeproj
```

## Testing

Any installed iPhone simulator works as the destination:

```sh
xcodebuild test -project Speedometer.xcodeproj -scheme Speedometer \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

## License

[MIT](LICENSE)
