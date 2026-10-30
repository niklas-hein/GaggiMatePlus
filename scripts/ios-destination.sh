#!/usr/bin/env bash
# Prints the xcodebuild -destination for iOS builds and tests.
#
#   IOS_DESTINATION   full destination, used as is (e.g. "platform=iOS Simulator,name=iPhone 18 Pro")
#   IOS_SIMULATOR     simulator name to use or create (default: GaggiMatePlus)
#
# Without IOS_DESTINATION, this reuses the available simulator named $IOS_SIMULATOR,
# or creates it as an iPhone 18 Pro on the newest iOS runtime, so CI never takes over
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
  # Without a runtime argument, simctl picks the newest runtime the device supports.
  if ! udid="$(xcrun simctl create "$name" "iPhone 18 Pro" 2>/dev/null)"; then
    echo "Could not create an iPhone 18 Pro simulator. Install the iOS 27 runtime in Xcode > Settings > Components." >&2
    exit 1
  fi
  echo "Created simulator '$name' (iPhone 18 Pro)." >&2
fi

xcrun simctl bootstatus "$udid" -b >/dev/null
echo "platform=iOS Simulator,id=$udid"
