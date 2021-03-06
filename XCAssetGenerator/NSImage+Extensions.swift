//
//  NSImage+Extensions.swift
//  XCAssetGenerator
//
//  Created by Bader on 5/20/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Cocoa
import QuickLook

extension NSImage {
    static func systemImage(path: Path, size: NSSize = NSSize(width: 80, height: 80)) -> NSImage {
        let image = NSWorkspace.sharedWorkspace().iconForFile(path)
        image.size = size
        return image
    }
    
    static func systemImageForGroup(paths: [Path], size: NSSize = NSSize(width: 80, height: 80)) -> NSImage {
        let image = NSWorkspace.sharedWorkspace().iconForFiles(paths)!
        image.size = size
        return image
    }
}