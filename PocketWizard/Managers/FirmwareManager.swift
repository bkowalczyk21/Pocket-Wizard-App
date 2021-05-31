//
//  FirmwareManager.swift
//  PocketWizard
//
//  Created by Bryce Kowalczyk on 11/14/20.
//  Copyright © 2020 Bryce Kowalczyk. All rights reserved.
//

import Foundation
import Amplify
import AmplifyPlugins

struct FirmwareUpdate {
    var device: String
    var version: String
    var imageKey: String
}

protocol FirmwareRetrievalDelegate {
    func didRetrieveNewFirmwareUpdate(firmwareUpdate: FirmwareUpdate, unupdatedPocketWizards: [String])
    func failedToRetrieveNewFirmware(userMessage: String)
}

protocol FirmwareDownloadDelegate {
    func didDownloadFirmware()
    func failedToDownloadFirmware(userMessage: String)
}

class FirmwareManager {
     
    static let instance = FirmwareManager()
    
    private var retrievalDelegate: FirmwareRetrievalDelegate?
    private var downloadDelegate: FirmwareDownloadDelegate?
    var latestAvailableFirmwareUpdate: FirmwareUpdate?
    var firmwareImage: Data?
    var deviceUUIDsToBeUpdated: [String] = []
    
    func checkForNewFirmware(delegate: FirmwareRetrievalDelegate) {
        retrievalDelegate = delegate
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSPinpointAnalyticsPlugin())
            try Amplify.add(plugin: AWSS3StoragePlugin())
            try Amplify.configure()
            print("Amplify S3 conifgured successfully")
        } catch {
            print("Failed Amplify configuration: \(error)")
            retrievalDelegate?.failedToRetrieveNewFirmware(userMessage: "Cannot reach sever to check for new firmware updates.")
            return
        }
        retrieveFirmwareList()
    }
    
    private func retrieveFirmwareList() {
        _ = Amplify.Storage.list(resultListener: { [self] (event) in
            switch event {
            case let .success(listResult):
                print("Retrieved Firmware List")
                if let jsonFileKey = parseFirmwareListForLatest(itemList: listResult.items) {
                    retrieveJSONFile(key: jsonFileKey)
                }
            case let .failure(storageError):
                print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
                retrievalDelegate?.failedToRetrieveNewFirmware(userMessage: "Unable to retrieve firmware form server.")
            }
        })
    }
    
    private func parseFirmwareListForLatest(itemList: [StorageListResult.Item]) -> String? {
        var latestVersion: Float = 0
        var latestVersionKey: String?
        itemList.forEach { (item) in
            print("Key: \(item.key)")
            var key = item.key
            if key.hasSuffix(".json") {
                key.removeLast(5)
                let splitKey = key.split(separator: "-")
                guard let version = Float(splitKey[1]) else {return}
                if version > latestVersion && version > 0 {
                    latestVersion = version
                    latestVersionKey = item.key
                }
            }
        }
        return latestVersionKey
    }
    
    private func retrieveJSONFile(key: String) {
        _ = Amplify.Storage.downloadData(key: key) { [self] (event) in
            switch event {
            case let .success(data):
                print("Completed: \(data)")
                if let firmwareUpdate = self.parseJSONFile(fileData: data) {
                    let unupdatedPocketWizards = unupdatedPocketWizardsAvailable(update: firmwareUpdate)
                    if unupdatedPocketWizards.count != 0 {
                        latestAvailableFirmwareUpdate = firmwareUpdate
                        retrievalDelegate?.didRetrieveNewFirmwareUpdate(firmwareUpdate: firmwareUpdate, unupdatedPocketWizards: unupdatedPocketWizards)
                    }
                }
            case let .failure(storageError):
                print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
                retrievalDelegate?.failedToRetrieveNewFirmware(userMessage: "Unable to retrieve firmware form server.")
            }
        }
    }
    
    private func parseJSONFile(fileData: Data) -> FirmwareUpdate? {
        var firmwareUpdate: FirmwareUpdate?
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: fileData, options: .mutableLeaves)
            if let jsonObject = jsonObject as? Dictionary<String, AnyObject>,
            let product = jsonObject["product"] as? String,
            let version = jsonObject["version"] as? String,
            let imageKey = jsonObject["filename"] as? String {
                firmwareUpdate = FirmwareUpdate(device: product, version: version, imageKey: imageKey)
                print("JSON parsing successful")
            }
        } catch {
            print("Error with JSON serialization: \(error)")
        }
        return firmwareUpdate
    }
    
    private func unupdatedPocketWizardsAvailable(update: FirmwareUpdate) -> [String] {
        guard let updateVersion = Float(update.version) else {return []}
        var unupdatedDevices: [String] = []
        if let savedNR1sData = CoreDataManager.instance.getSavedNR1s(context: CoreDataManager.instance.persistentContainer.viewContext) {
            for nr1Data in savedNR1sData {
                if let currentVersionString = nr1Data.firmwareRevision,
                   let currentVersion = Float(currentVersionString) {
                    if updateVersion > currentVersion {
                        unupdatedDevices.append(nr1Data.modelNumber ?? "")
                        if let uuid = nr1Data.uuid {
                            deviceUUIDsToBeUpdated.append(uuid)
                        }
                    }
                }
            }
            print(unupdatedDevices.description)
        }
        return unupdatedDevices
    }
    
    func fetchFirmwareImage(delegate: FirmwareDownloadDelegate) {
        downloadDelegate = delegate
        downloadFirmwareImage()
    }
    
    private func downloadFirmwareImage() {
        guard let key = latestAvailableFirmwareUpdate?.imageKey else {return}
        _ = Amplify.Storage.downloadData(key: key, resultListener: { [self] (event) in
            switch event {
            case let .success(data):
                print("Completed image download: \(data)")
                firmwareImage = data
                downloadDelegate?.didDownloadFirmware()
            case let .failure(storageError):
                print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
                downloadDelegate?.failedToDownloadFirmware(userMessage: "Firmware download failed. Please ensure you have a proper internet connection and try again")
            }
        })
    }
}
