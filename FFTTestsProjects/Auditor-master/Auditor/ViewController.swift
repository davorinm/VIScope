//
//  ViewController.swift
//  Auditor
//
//  Created by Lance Jabr on 6/21/18.
//  Copyright © 2018 Lance Jabr. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {
    
    var isRecording = false
    var audioEngine = AudioEngine()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTableSelection()
        
        AudioRoute.onDevicesChanged = {
            self.inputTable.reloadData()
            self.outputTable.reloadData()
            self.setTableSelection()
            self.audioEngine = AudioEngine()
        }
        

    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBOutlet var inputTable: NSTableView!
    @IBOutlet var outputTable: NSTableView!
    
    @IBOutlet var inputAudioView: SpectrogramView!
    @IBOutlet var outputAudioView: SpectrogramView!

    fileprivate func setTableSelection() {
        let inputI = AudioRoute.availableInputs.firstIndex(of: AudioRoute.currentInput)
        inputTable.selectRowIndexes(IndexSet(integer: inputI!), byExtendingSelection: false)
        
        let outputI = AudioRoute.availableOutputs.firstIndex(of: AudioRoute.currentOutput)
        outputTable.selectRowIndexes(IndexSet(integer: outputI!), byExtendingSelection: false)
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.characters {
        case " ":
            // start or stop recording
            self.audioEngine.playthroughVolume = self.audioEngine.playthroughVolume == 0 ? 1 : 0
            if self.audioEngine.playthroughVolume == 1 {
                self.audioEngine.inputNode.installTap(onBus: 0, bufferSize: AVAudioFrameCount(self.inputAudioView.internalFrameLength), format: nil) { buffer, time in
                    self.inputAudioView.addAudioData(buffer)
                }
            } else {
                self.audioEngine.inputNode.removeTap(onBus: 0)
            }
            break
        default:
            break
        }
    }
}

extension ViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        var table = tableView === inputTable ? AudioRoute.availableInputs : AudioRoute.availableOutputs
        table = table.filter({!$0.name.hasPrefix("CA") && !$0.name.hasPrefix("Instant")})
        return table.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor column: NSTableColumn?, row: Int) -> NSView? {
        var table = tableView === inputTable ? AudioRoute.availableInputs : AudioRoute.availableOutputs
        table = table.filter({!$0.name.hasPrefix("CA") && !$0.name.hasPrefix("Instant")})
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("MyView"), owner: self) as! NSTableCellView
        cell.textField!.stringValue = table[row].name
        return cell
    }
    
    func tableViewSelectionDidChange(_ aNotification: Notification) {
        let tableView: NSTableView = aNotification.object as! NSTableView
        let row = tableView.selectedRow
        if row < 0 { setTableSelection(); return }
        var table = tableView === inputTable ? AudioRoute.availableInputs : AudioRoute.availableOutputs
        table = table.filter({!$0.name.hasPrefix("CA") && !$0.name.hasPrefix("Instant")})

        if tableView === inputTable {
            AudioRoute.currentInput = table[row]
        }
        
        if tableView === outputTable {
            AudioRoute.currentOutput = table[row]
        }
    }
}
