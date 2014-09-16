//
//  AssetGeneratorViewController.swift
//  XCAssetGenerator
//
//  Created by Bader on 9/12/14.
//  Copyright (c) 2014 Bader. All rights reserved.
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

class AssetGeneratorViewController: NSViewController, FileDropControllerDelegate, AssetGeneratorDestinationProjectDelegate {

    @IBOutlet var generateButton: NSButton!
  
    var fileDropController: FileDropViewController! // Force unwrap since it doesnt make sense it this doesnt exist.
    let recentListManager: RecentlySelectedProjectManager
    var sourceDelegate: ScriptSourcePathDelegate?
    var destinationDelegate: ScriptDestinationPathDelegate?
    
    required init(coder: NSCoder!) {
//        panel = NSOpenPanel()
        recentListManager = RecentlySelectedProjectManager()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
       // TODO: Find better way to connect containerController to local var. sigh.
//      self.fileDropController = self.childViewControllers.first! as FileDropViewController
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.updateGenerateButton()
    }

    // MARK:- Convenience Functions.
    func updateGenerateButton() -> Void {
        // verbose much?
        switch (self.sourceDelegate, self.destinationDelegate) {
        case (.Some(let source), .Some(let destination)):
            self.generateButton.enabled = source.hasValidSourceProject() && destination.hasValidDestinationProject()
        case (_,_):
            self.generateButton.enabled = false
        }
       // self.generateButton.enabled = self.sourceDelegate?.hasValidSourceProject()
    }

    // MARK: - IBActions
    @IBAction func generateButtonPressed(sender: AnyObject!) {

        // We _CANNOT_ be in this function if our delegates are not set or if we dont have valid paths.
        var scriptManager: ScriptExecutor = ScriptExecutor()
        
        scriptManager.executeScript(source: self.sourceDelegate!.sourcePath()!,
            destination: self.destinationDelegate!.destinationPath()!,
            generate1x: false,
            extraArgs: nil)
    }
    
    // Is this better?
    // MARK: - Segues functions
    override func prepareForSegue(segue: NSStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "embeddedContainer" {
            self.fileDropController = segue.destinationController as FileDropViewController
            self.fileDropController.delegate = self
            
            // fileDrop is the source, so set it as delegate
            self.sourceDelegate = self.fileDropController
        }
    }
    
    
    // MARK: - FileDropController Delegate
    func fileDropControllerDidSetSourcePath(controller: FileDropViewController) {
        self.updateGenerateButton()
        
    }
    func fileDropControllerDidRemoveSourcePath(controller: FileDropViewController) {
        self.updateGenerateButton()
    }

    
    // MARK: - AssetGeneratorDestinationProject Delegate
    func destinationProjectDidChange(path: String?) {
        println("Destination Project Changed")
        self.updateGenerateButton()
    }
   
}