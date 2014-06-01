CocoaMobileDevice
=================

A Cocoa based wrapper around the libimobiledevice library.

Current release: 0.0.


**Features:**
- Connection notifications via `NSNotificationCenter`
- Connecting to devices
- Ability to parse native values (NSString, NSDate, NSDictionary, NSArray, NSData) and read/write values.
- Getting a device screenshot (to NSData).

I haven't documented the headers yet either but its not too complicated.. Check out the source code and demo project to get an idea on what is going on.


Future:
----
I'm not sure how useful this is going to be for people but I would like to implement all features if possible however on its own it should give you a good idea on how to get libimobiledevice working on a mac.


Usage
----

This is the first framework that I have compiled so I'm not sure if I have done it the right way or not so this is subject to change.

1) Grab a copy of the compiled framework from the `/Builds` directory.
2) Drag the framework into the framework group of your xcode project.
3) In the **Build Phases** section, tap the + in the top right and add a "New Copy Files Build Phase".
4) In the new phase, set the Destination to "Frameworks" and then add the framework to this phase.

You should then be able to compile and use the framework.


Note: It was a pain creating the original dylibs and I had some issues with hardocoded dependancies although I think I have fixed them now. If you're still having issues then let me know and I'll see what I can do.
