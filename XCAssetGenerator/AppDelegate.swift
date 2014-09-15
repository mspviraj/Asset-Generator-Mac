//
//  AppDelegate.swift
//  XCAssetGenerator
//
//  Created by Pranav Shah on 7/30/14.
//  Copyright (c) 2014 Bader. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var windowController: NSWindowController!
    @IBOutlet var window: NSWindow!
    
    @IBOutlet var recentlyUsedProjectsDropdownList: NSPopUpButton!
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication!) -> Bool {
        return true;
    }
    
    func applicationShouldTerminate(sender: NSApplication!) -> NSApplicationTerminateReply {
        return NSApplicationTerminateReply.TerminateNow
    }

}

