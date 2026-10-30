# GaggiMate+

A native iOS client for [GaggiMate](https://github.com/jniebuhr/gaggimate), the ESP32-based espresso machine controller. It talks to the controller over its local WebSocket API.

**Status:** WIP. This is a scaffold and has no features yet.

## Building

The Xcode workspace is generated with [Tuist](https://tuist.dev). Tools are pinned with [mise](https://mise.jdx.dev), and every command runs through [just](https://just.systems):

```sh
mise install
just project
```

Run `just` to list the other recipes. Run `just ci` before opening a pull request.

Requires Xcode 27.2 or later. The app targets iOS 27.
