# Every command in this repo runs through just; mise only pins tool versions.
# Recipes run under `mise exec`, so they always use the versions in mise.toml.

set shell := ["mise", "exec", "--", "bash", "-euo", "pipefail", "-c"]

workspace := "GaggiMatePlus.xcworkspace"
scheme := "GaggiMatePlus"

# List recipes.
default:
    @{{ just_executable() }} --list --unsorted

# Generate the Xcode workspace with Tuist.
project:
    tuist generate --no-open

# Build the app for the simulator.
build: project
    xcodebuild build -workspace {{ workspace }} -scheme {{ scheme }} -destination "generic/platform=iOS Simulator" 2>&1 | xcbeautify --disable-colored-output

# Unit tests on a simulator. Set IOS_DESTINATION or IOS_SIMULATOR to override.
test: project
    dest="$(scripts/ios-destination.sh)" && xcodebuild test -workspace {{ workspace }} -scheme {{ scheme }} -destination "$dest" 2>&1 | xcbeautify --disable-colored-output

# Local CI, the same command GitHub CI runs: generate the workspace, build the app and run the unit tests.
ci: test
