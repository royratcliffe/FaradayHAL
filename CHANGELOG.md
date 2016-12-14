# Change Log

## [0.3.2](https://github.com/royratcliffe/FaradayHAL/tree/0.3.2)

Various little fixes for passing tests in Travis CI environment.

- Merge branch 'feature/travis_ci' into develop
- Added comment about `id` destination
- Try using an ID to match the simulator
- Use default platform and OS
- Specify 10.2 SDK
- Still not building, trying iPhone SE
- Also specify platform: iOS Simulator
- Use iOS 10.2 simulator for Travis testing
- Use Travis Xcode 8.2 image
- Fixed type: `xcworkspace`
- Added workspace extension
- Added workspace to `xcodebuild` command line options
- Use workspace instead of project (Travis CI)
- Travis CI updates CocoaPods repo before installing

See [Full Change Log](https://github.com/royratcliffe/FaradayHAL/compare/0.3.1...0.3.2).

## [0.3.1](https://github.com/royratcliffe/FaradayHAL/tree/0.3.1)

- Trap JSON parsing failures by catching errors
- Cast response body to Data rather than NSData

See [Full Change Log](https://github.com/royratcliffe/FaradayHAL/compare/0.3.0...0.3.1).

## [0.3.0](https://github.com/royratcliffe/FaradayHAL/tree/0.3.0)

- Depends on Faraday 0.5.x
- Explicit `@escaping` for Xcode 8 GM

See [Full Change Log](https://github.com/royratcliffe/FaradayHAL/compare/0.2.4...0.3.0).

## [0.2.4](https://github.com/royratcliffe/FaradayHAL/tree/0.2.4)

- Update dependent pods

See [Full Change Log](https://github.com/royratcliffe/FaradayHAL/compare/0.2.3...0.2.4).

## [0.2.3](https://github.com/royratcliffe/FaradayHAL/tree/0.2.3)

- Link against HypertextApplicationLanguage 0.2.7 for fixes
- Response.onRepresentation escapes
- Update sub-pod dependencies
- Install dependent pods during Travis integration
- Fix Travis configuration

See [Full Change Log](https://github.com/royratcliffe/FaradayHAL/compare/0.2.2...0.2.3).

## [0.2.2](https://github.com/royratcliffe/FaradayHAL/tree/0.2.2)

- Sources in Sources folder; tests in Tests folder
- Let-underscore-equals replaced by underscore-equals
- Updated sub-pods

See [Full Change Log](https://github.com/royratcliffe/FaradayHAL/compare/0.2.1...0.2.2).

## [0.2.1](https://github.com/royratcliffe/FaradayHAL/tree/0.2.1)

- Use link(for:)
- Upgrade HypertextApplicationLanguage to patch level 3

See [Full Change Log](https://github.com/royratcliffe/FaradayHAL/compare/0.2.0...0.2.1).

## [0.2.0](https://github.com/royratcliffe/FaradayHAL/tree/0.2.0)

- Merge branch 'feature/swift_3_0' into develop
- Use "." path as default href
- Import Foundation, not UIKit
- Silence expected ',' joining multi-clause condition warnings
- Silence result of call unused warnings
- Convert sources to Swift 3.0
- Upgrade pod dependencies for Swift 3.0

See [Full Change Log](https://github.com/royratcliffe/FaradayHAL/compare/0.1.8...0.2.0).

## [0.1.8](https://github.com/royratcliffe/FaradayHAL/tree/0.1.8)

- Run SwiftLint
- Close-brace and else on same line
- Merge branch 'feature/swift_2_3' into develop
- Upgraded to recommended settings (Xcode 8.0 beta 4)

See [Full Change Log](https://github.com/royratcliffe/FaradayHAL/compare/0.1.7...0.1.8).
