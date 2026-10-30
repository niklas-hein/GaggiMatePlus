#!/usr/bin/env bash
# Prints the xcodebuild -destination for iOS builds and tests.
#
#   IOS_DESTINATION   full destination, used as is (e.g. "platform=iOS Simulator,name=iPhone 18 Pro")
#   IOS_SIMULATOR     simulator name to use or create (default: GaggiMatePlus)
#
# Without IOS_DESTINATION, this reuses the available simulator named $IOS_SIMULATOR,
# or creates it from the newest iOS runtime and iPhone model, so CI never takes over
# a simulator another session is driving. It boots the simulator and leaves it running:
# xcodebuild shuts down simulators it boots itself, which costs ~15 s on every test run.
set -euo pipefail

if [ -n "${IOS_DESTINATION:-}" ]; then
  echo "$IOS_DESTINATION"
  exit 0
fi

name="${IOS_SIMULATOR:-GaggiMatePlus}"
uuid_re='[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}'

# Last match wins, so the simulator on the newest runtime is picked.
udid="$(xcrun simctl list devices available |
  grep -E "^ +${name} \(${uuid_re}\)" |
  tail -n 1 | grep -oE "$uuid_re" || true)"

if [ -z "$udid" ]; then
  runtime="$(xcrun simctl list runtimes available |
    grep -oE 'com\.apple\.CoreSimulator\.SimRuntime\.iOS-[0-9-]+' |
    sort -t- -k2,2n -k3,3n | tail -n 1)"
  if [ -z "$runtime" ]; then
    echo "No iOS simulator runtime installed. Install one in Xcode > Settings > Components." >&2
    exit 1
  fi
  # simctl lists the newest models first; take the first one the runtime accepts.
  for devicetype in $(xcrun simctl list devicetypes |
    grep -E '^iPhone' | grep -oE 'com\.apple\.CoreSimulator\.SimDeviceType\.[A-Za-z0-9-]+'); do
    if udid="$(xcrun simctl create "$name" "$devicetype" "$runtime" 2>/dev/null)"; then
      echo "Created simulator '$name' ($devicetype, $runtime)." >&2
      break
    fi
    udid=""
  done
  if [ -z "$udid" ]; then
    echo "Could not create an iPhone simulator for $runtime." >&2
    exit 1
  fi
fi

xcrun simctl bootstatus "$udid" -b >/dev/null
echo "platform=iOS Simulator,id=$udid"
