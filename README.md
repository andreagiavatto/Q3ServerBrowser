AGServerBrowser
==============

A simple skeleton app to be used to create a game server browser. The initial versions implements the Quake 3 Arena 1.32 (protocol 68) game but the app is designed to make it easy to add new games.

Games supported:
- Quake 3 Arena ([protocol](http://src.gnu-darwin.org/ports/games/masterserver/work/masterserver-0.4.1/docs/PROTOCOLS))

![1](https://s3-us-west-2.amazonaws.com/andreagiavatto.github.io/AGServerBrowser/Screenshot.png)

## Usage
The project uses [CocoaPods](http://cocoapods.org/) to fetch a couple of external pods like [Reachability](https://github.com/tonymillion/Reachability) and [CocoaAsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket).

Simply download/clone the project and run
```pod install```

## System Requirements
The minimum system requirements are the ones needed by the 3rd party libraries used.
CocoaAsyncSocket requires MacOS X 10.7 to run.

## TO-DO
- add sorting/filtering
- support more games :-)
