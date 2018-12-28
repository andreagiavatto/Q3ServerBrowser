//
//  LogsWindowController.swift
//  Q3ServerBrowser
//
//  Created by Andrea on 16/06/2018.
//

import AppKit
import SQL_Mac

class LogsWindowController: NSWindowController {
    
    private var process: Process?
    private var outputPipe: Pipe?
    private var errorPipe: Pipe?
    
    weak var logsViewController: LogsViewController? {
        return contentViewController as? LogsViewController
    }
    
    func connect(to server: Server, forGame game: Game, atPath path: String) {
        
        guard process == nil else {
            return
        }
        
        let appBundle = Bundle(path: path)
        let executablePath = appBundle?.executablePath
        
        process = Process()
        outputPipe = Pipe()
        errorPipe = Pipe()
        
        process?.launchPath = executablePath
        process?.arguments = [game.launchArguments, "\(server.ip):\(server.port)"]
        process?.standardInput = Pipe()
        process?.standardOutput = outputPipe
        process?.standardError = errorPipe
        process?.terminationHandler = { [weak self] terminatedProcess in
            self?.process = nil
            self?.outputPipe = nil
            self?.errorPipe = nil
        }
        outputPipe?.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            self?.processLogData(data)
        }
        errorPipe?.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            self?.processLogData(data)
        }
        
        do {
            try process?.launch()
        } catch(let error) {
            displayAlert(message: NSLocalizedString("AlertAppNotLaunchedMessage", comment: ""), informativeText: error.localizedDescription)
            close()
        }
    }
    
    private func processLogData(_ data: Data) {
        
        guard data.count > 0, let outputString = String(data: data, encoding: .utf8) else {
            return
        }
        
        DispatchQueue.main.async(execute: {
            self.logsViewController?.append(outputString)
        })
    }
    
    private func writeToDisk() {
//        NSError *error;
//        NSURL *appSupportDir = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
//        
//        NSLog(@"%@", appSupportDir);
    }
}

