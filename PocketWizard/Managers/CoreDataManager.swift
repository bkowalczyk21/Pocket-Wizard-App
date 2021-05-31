//
//  CoreDataManager.swift
//  PocketWizard
//
//  Created by Bryce Kowalczyk on 7/20/20.
//  Copyright © 2020 Bryce Kowalczyk. All rights reserved.
//

import Foundation
import CoreData
import CoreBluetooth

class CoreDataManager {
    
    static let instance = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PocketWizard")
        container.loadPersistentStores { (description, error) in
            if let error = error as NSError? {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    private init() {
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                fatalError("Unable to save changes: \(error)")
            }
        }
    }
    
    func createNR1WithPeripheral(_ peripheral: CBPeripheral) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NR1> = NR1.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid = %@", peripheral.identifier.uuidString)
        if let existingNR1s = try? context.fetch(fetchRequest), existingNR1s.count != 0 {
            return
        }
        let entity = NSEntityDescription.entity(forEntityName: "NR1", in: context)!
        let nr1 = NSManagedObject(entity: entity, insertInto: context) as? NR1
        nr1?.uuid = peripheral.identifier.uuidString
        try? context.save()
    }
    
    func removeNR1WithUUID(_ uuid: UUID) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NR1> = NR1.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid = %@", uuid.uuidString)
        guard let existingNR1s = try? context.fetch(fetchRequest),
        existingNR1s.count == 0,
            let nr1ToRemove = existingNR1s.first else {
                return
        }
        context.delete(nr1ToRemove)
        try? context.save()
    }
    
    func getSavedNR1s(context: NSManagedObjectContext) -> [NR1]? {
        let fetchRequest: NSFetchRequest<NR1> = NR1.fetchRequest()
        let existingNR1s = try? context.fetch(fetchRequest) 
        return existingNR1s
        
    }
    
    func getNR1WithUUID(uuid: UUID, context: NSManagedObjectContext) -> NR1? {
        let fetchRequest: NSFetchRequest<NR1> = NR1.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid = %@", uuid.uuidString)
        let existingNR1s = try? context.fetch(fetchRequest)
        return existingNR1s?.first
    }
    
    func updateManufacturerNameFor(_ uuid: UUID, manufacturerName: String) {
        let context = persistentContainer.viewContext
        let nr1 = getNR1WithUUID(uuid: uuid, context: context)
        nr1?.manufacturerName = manufacturerName
        try? context.save()
    }
    
    func updateModelNumberFor(_ uuid: UUID, modelNumber: String) {
        let context = persistentContainer.viewContext
        let nr1 = getNR1WithUUID(uuid: uuid, context: context)
        nr1?.modelNumber = modelNumber
        try? context.save()
    }
    
    func updateFirmwareRevisionFor(_ uuid: UUID, firmwareRevision: String) {
        let context = persistentContainer.viewContext
        let nr1 = getNR1WithUUID(uuid: uuid, context: context)
        nr1?.firmwareRevision = firmwareRevision
        try? context.save()
    }
    
    func updateChannelFor(_ uuid: UUID, channel: Int16) {
        let context = persistentContainer.viewContext
        let nr1 = getNR1WithUUID(uuid: uuid, context: context)
        nr1?.channel = channel
        try? context.save()
    }
    
    func updateZonesFor(_ uuid: UUID, zones: String) {
        let context = persistentContainer.viewContext
        let nr1 = getNR1WithUUID(uuid: uuid, context: context)
        nr1?.zones = zones
        try? context.save()
    }
    
    func updateModeFor(_ uuid: UUID, mode: Int16) {
        let context = persistentContainer.viewContext
        let nr1 = getNR1WithUUID(uuid: uuid, context: context)
        nr1?.mode = mode
        try? context.save()
    }
    
    func updateTamperStateFor(_ uuid: UUID, tamperState: Int16) {
        let context = persistentContainer.viewContext
        let nr1 = getNR1WithUUID(uuid: uuid, context: context)
        nr1?.tamperState = tamperState
        try? context.save()
    }
    
    func updateTamperSettingFor(_ uuid: UUID, tamperSetting: Int16) {
        let context = persistentContainer.viewContext
        let nr1 = getNR1WithUUID(uuid: uuid, context: context)
        nr1?.tamperSetting = tamperSetting
        try? context.save()
    }
    
    func updateFirmwareUpdateAvailableFor(_ uuid: UUID, available: Bool) {
        let context = persistentContainer.viewContext
        let nr1 = getNR1WithUUID(uuid: uuid, context: context)
        nr1?.firmwareUpdateAvailable = available
        try? context.save()
    }
    
    func updateFirmwareUpdateNameFor(_ uuid: UUID, name: String) {
        let context = persistentContainer.viewContext
        let nr1 = getNR1WithUUID(uuid: uuid, context: context)
        nr1?.firmwareUpdateName = name
        try? context.save()
    }
}
