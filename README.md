# GaggiMate+

A native iOS client for [GaggiMate](https://github.com/jniebuhr/gaggimate), the ESP32-based espresso machine controller. It talks to the controller over its local WebSocket API.

**Status:** WIP. This is a scaffold and has no features yet.

## Building

The Xcode workspace is generated with [Tuist](https://tuist.dev), pinned with [mise](https://mise.jdx.dev):

```sh
mise install
tuist generate
```

Requires Xcode with the iOS 18+ SDK.
