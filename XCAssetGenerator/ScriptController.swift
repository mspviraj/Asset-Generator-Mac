//
//  ScriptController.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/25/14.
//  Copyright (c) 2014 Pranav Shah. All rights reserved.
//

import Cocoa

// TODO: hmm to functionally-identical protocols.... You know what to do.
protocol ScriptSourcePathDelegate {
    func sourcePath() -> String?
    func hasValidSourceProject() -> Bool
}

protocol ScriptDestinationPathDelegate {
    func destinationPath() -> String?
    func hasValidDestinationProject() -> Bool
}

class ScriptController: NSObject {

    var sourceDelegate: ScriptSourcePathDelegate?
    var destinationDelegate: ScriptDestinationPathDelegate?
    var progressDelegate: ScriptProgessDelegate? {
        set {
            self.scriptManager.progressDelegate = newValue
        }
        
        get {
            return self.scriptManager.progressDelegate
        }
    }
    
    let scriptManager: ScriptExecutor
    
    override init() {
        scriptManager = ScriptExecutor()
        super.init()
    }
    
    func setProgressDelegate(delegate: ScriptProgessDelegate?) {
        self.scriptManager.progressDelegate = delegate
    }
    
    func canExecuteScript() -> Bool {
        switch (self.sourceDelegate, self.destinationDelegate) {
        case (.Some(let source), .Some(let destination)):
            return source.hasValidSourceProject() && destination.hasValidDestinationProject() && !self.scriptManager.executing()
        case (_,_):
            return false
        }
    }
    
    func executeScript() {
//        let dest = createNewAsset(project: self.destinationDelegate!.destinationPath()!)
//        self.scriptManager.executeScript(source: self.sourceDelegate!.sourcePath()!, destination: dest, generate1x: false, extraArgs: nil)
        self.scriptManager.executeScript(source: self.sourceDelegate!.sourcePath()!, destination: self.destinationDelegate!.destinationPath()!, generate1x: false, extraArgs: nil)
    }
    
    func executeScript(#generate1x: Bool, extraArgs args: [String]?) {
        self.scriptManager.executeScript(source: self.sourceDelegate!.sourcePath()!, destination: self.destinationDelegate!.destinationPath()!, generate1x: generate1x, extraArgs: args)
    }
    
    
    // MARK:- For future usages, maybe.
    private func createNewAsset(#project: String) -> String {
        return project.stringByDeletingPathExtension + "/Images.xcassets"
    }
}