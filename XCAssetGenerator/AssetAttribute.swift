//
//  AssetAttributeProcessor.swift
//  XCAssetGenerator
//
//  Created by Bader on 6/17/15.
//  Copyright (c) 2015 Bader Alabdulrazzaq. All rights reserved.
//

import Cocoa

/// A JSON representation of the values in an individual Asset Catalog JSON.
/// Will always contains a minimum of the following keys: .Scale and .Idiom
/// Other available keys as specified in XCAssetsJSONKeys.
typealias XCAssetsJSON = [String: AnyObject]

/// Represents the outer JSON of the XCAssetsJSON values.
/// Will always contain the following keys: "info", "images".
typealias XCAssetsJSONWrapper = [String: AnyObject]


func sanitizeJSON(json: [XCAssetsJSON]) -> [XCAssetsJSON] {
    func removeUnwanted(dict: [String: AnyObject]) -> XCAssetsJSON {
        var clean = dict
        clean.removeValueForKey(XCAssetsJSONKeys.Unassigned)
        return clean
    }
    
    return json.map(removeUnwanted)
}

struct AssetAttribute: Serializable {
    var filename: String?
    let scale: String
    let idiom: String
    let size: String?
    let extent: String?
    let subtype: String?
    let orientation: String?
    let minimumSystemVersion: String?
    
    // MARK: - Initializers
    
    private init (filename: String?, scale: String, idiom: String, size: String? = nil, subtype: String? = nil, orientation: String? = nil, minimumSystemVersion: String? = nil, extent: String? = nil) {
        self.filename = filename
        self.scale = scale
        self.idiom = idiom
        self.size = size
        self.extent = extent
        self.subtype = subtype
        self.orientation = orientation
        self.minimumSystemVersion = minimumSystemVersion
    }
    
    // MARK: - Serializable
    
    typealias Serialized = XCAssetsJSON
    var serialized: Serialized {
        var s = [XCAssetsJSONKeys.Scale: scale, XCAssetsJSONKeys.Idiom: idiom]
        if let filename = filename {
            s[XCAssetsJSONKeys.Filename] = filename
        }
        if let size = size {
            s[XCAssetsJSONKeys.Size] = size
        }
        if let extent = extent {
            s[XCAssetsJSONKeys.Extent] = extent
        }
        if let subtype = subtype {
            s[XCAssetsJSONKeys.Subtype] = subtype
        }
        if let orientation = orientation {
            s[XCAssetsJSONKeys.Orientation] = orientation
        }
        if let minimumSystemVersion = minimumSystemVersion {
            s[XCAssetsJSONKeys.MinimumSystemVersion] = minimumSystemVersion
        }
        return s
    }
}

struct AssetAttributeProcessor {
    
    static func withAsset(path: Path) -> AssetAttribute {
        let name = path.lastPathComponent
        
        let is2x = name.contains(GenerationKeywords.PPI2x)
        let is3x = name.contains(GenerationKeywords.PPI3x)
        let scale = is2x ? "2x" : is3x ? "3x" : "1x"

        let isiPhone = name.contains(GenerationKeywords.iPhone)
        let isiPad = name.contains(GenerationKeywords.iPad)
        let isMac = name.contains(GenerationKeywords.Mac)
        let idiom = isiPhone ? "iphone" : isiPad ? "ipad" : isMac ? "mac" : "universal"
        
        return AssetAttribute(filename: name, scale: scale, idiom: idiom)
    }
    
    static func withMacIcon(path: Path) -> AssetAttribute {
        let imgURL = NSURL(fileURLWithPath: path)
        let src = CGImageSourceCreateWithURL(imgURL, nil)
        let result = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as NSDictionary
        
        let name = path.lastPathComponent
        let width = result[kCGImagePropertyPixelWidth as String]! as! Int
        
        let is2x = name.contains("@2x")
        let idiom = "mac"
        var scale = is2x ? "2x" : "1x"
        var size = "16x16"
        
        switch width {
        case 16:
            break
        case 32:
            size = is2x ? "16x16" : "32x32"
        case 64:
            scale = "2x"
            size = "32x32"
        case 128:
            scale = "1x"
            size = "128x128"
        case 256:
            size = is2x ? "128x128" : "256x256"
        case 512:
            size = is2x ? "256x256" : "512x512"
        case 1024:
            scale = "2x"
            size = "512x512"
        default:
            break
            
        }
        
        return AssetAttribute(filename: name, scale: scale, idiom: idiom, size: size)
    }
    
    static func withIcon(path: Path) -> AssetAttribute {
        let name = path.lastPathComponent
        
        if AssetType.isMacIcon(name) {
            return AssetAttributeProcessor.withMacIcon(path)
        }
        
        let imgURL = NSURL(fileURLWithPath: path)
        let src = CGImageSourceCreateWithURL(imgURL, nil)
        let result = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as NSDictionary
        
        
        let width = result[kCGImagePropertyPixelWidth as String]! as! Int
        
        var idiom = "iphone"
        var scale = "1x"
        var size = "60x60"
        
        switch width {
        case 60:
            break
        case 120:
            idiom = "iphone"
            let spotlight = name.contains("@3x") || name.contains("Icon-Small") // Spotlight 40@3x or iPhone icon 60@2x
            scale = spotlight ? "3x" : "2x"
            size = spotlight ? "40x40" : "60x60"
        case 180:
            scale = "3x"
        case 76:
            idiom = "ipad"
            size = "76x76"
        case 152:
            idiom = "ipad"
            scale = "2x"
            size = "76x76"
        case 40:
            idiom = "ipad"
            scale = "1x"
            size = "40x40"
        case 80:
            idiom = name.contains(GenerationKeywords.iPad) ? "ipad" : "iphone"
            scale = "2x"
            size = "40x40"
        case 29:
            idiom = "ipad"
            scale = "1x"
            size = "29x29"
        case 58:
            idiom = name.contains(GenerationKeywords.iPad) ? "ipad" : "iphone"
            scale = "2x"
            size = "29x29"
        case 87:
            idiom = "iphone"
            scale = "3x"
            size = "29x29"
        default:
            break
        }
        
        return AssetAttribute(filename: name, scale: scale, idiom: idiom, size: size)
    }
    
    static func withLaunchImage(path: Path) -> AssetAttribute {
        let imgURL = NSURL(fileURLWithPath: path)
        let src = CGImageSourceCreateWithURL(imgURL, nil)
        let result = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as NSDictionary
        
        let name = path.lastPathComponent
        let width = result[kCGImagePropertyPixelWidth as String]! as! Float
        
        var idiom = "iphone"
        var scale = "1x"
        var subtype = ""
        var orientation = "portrait"
        var minimumVersion = "7.0"
        let extent = "full-screen"
        
        switch width {
        case 320:
            break
        case 640:
            scale = "2x"
            let height = result[kCGImagePropertyPixelHeight as String]! as! Float
            if (height == 1136) { subtype = "retina4" }
        case 1242:
            scale = "3x"
            subtype = "736h"
            minimumVersion = "8.0"
        case 750:
            scale = "2x"
            subtype = "667h"
            minimumVersion = "8.0"
        case 2208:
            scale = "3x"
            subtype = "736h"
            minimumVersion = "8.0"
        case 768:
            idiom = "ipad"
        case 1536:
            idiom = "ipad"
            scale = "2x"
        case 1024:
            idiom = "ipad"
            orientation = "landscape"
        case 2048:
            idiom = "ipad"
            scale = "2x"
            orientation = "landscape"
        default:
            break
        }
        
        return AssetAttribute(filename: name, scale: scale, idiom: idiom, extent: extent, subtype: subtype, orientation: orientation, minimumSystemVersion: minimumVersion)
    }
}
