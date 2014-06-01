CocoaMobileDevice
=================

A Cocoa based wrapper around the libimobiledevice library.

Current release: 0.0.1

**Features:**
- Connection notifications via `NSNotificationCenter`
- Connecting to devices
- Ability to parse native values (NSString, NSDate, NSDictionary, NSArray, NSData) and read/write values.
- Getting a device screenshot (to NSData).

I haven't documented the headers yet either but its not too complicated.. Check out the source code and demo project to get an idea on what is going on.


Future:
----
I'm not sure how useful this is going to be for people but I would like to implement all features if possible however on its own it should give you a good idea on how to get libimobiledevice working on a mac.


Installation:
----

**Option 1:** Clone the repo and compile the source code yourself (make any changes you want as well).

**Option 2:** Take a pre-comiled build from the `/Builds` dir and copy it into `/Library/Frameworks/` on your build machine. You can then reference this file in your project and everything should work.
