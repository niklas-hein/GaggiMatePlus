# Every command in this repo runs through just; mise only pins tool versions.
# Recipes run under `mise exec`, so they always use the versions in mise.toml.

set shell := ["mise", "exec", "--", "bash", "-euo", "pipefail", "-c"]

workspace := "GaggiMatePlus.xcworkspace"
scheme := "GaggiMatePlus"

# List recipes.
default:
    @{{ just_executable() }} --list --unsorted

# SwiftLint in strict mode: every warning fails (config: .swiftlint.yml).
lint:
    swiftlint lint --strict --quiet

# Generate the Xcode workspace with Tuist.
project:
    tuist generate --no-open

# Build the app for the simulator.
build: project
    xcodebuild build -workspace {{ workspace }} -scheme {{ scheme }} -destination "generic/platform=iOS Simulator" 2>&1 | xcbeautify --disable-colored-output

# Unit tests on a simulator: every module's, or one module's with `just test <module>`. IOS_SIMULATOR or IOS_DESTINATION override the simulator.
test module="": project
    dest="$(scripts/ios-destination.sh)" && xcodebuild test -workspace {{ workspace }} -scheme {{ if module == "" { scheme } else { module } }} -destination "$dest" 2>&1 | xcbeautify --disable-colored-output

# Local CI, the same steps as GitHub CI's jobs: lint, build the app, then run every module's unit tests.
ci: lint build test
