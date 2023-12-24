        //
        //  Persistence.swift
        //  Jamlog
        //
        //  Created by Brian Ruff on 12/21/23.
        //

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Jamlog")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    
    
    /*

     Usage
     To fetch an attribute:

     if let imageURL: String = PersistenceController.fetchAttribute(entityName: "Post", attributeName: "imageURL", objectId: somePostId) {
         // Use imageURL here
     }

     */
    static func fetchAttribute<T>(entityName: String, attributeName: String, objectId: UUID) -> T? {
        let context = shared.container.viewContext
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "id == %@", objectId as CVarArg)
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = [attributeName]

        do {
            let results = try context.fetch(fetchRequest)
            if let result = results.first, let attributeValue = result[attributeName] as? T {
                return attributeValue
            }
        } catch {
            print("Error fetching attribute \(attributeName) for \(entityName): \(error)")
        }
        return nil
    }

    
    /*
     
     Usage
     To update an attribute:

     PersistenceController.updateAttribute(entityName: "Post", attributeName: "body", value: "New text description", objectId: somePostId)

     */
    static func updateAttribute<T>(entityName: String, attributeName: String, value: T, objectId: UUID) {
        let context = shared.container.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "id == %@", objectId as CVarArg)

        do {
            let results = try context.fetch(fetchRequest)
            if let objectToUpdate = results.first as? NSManagedObject {
                objectToUpdate.setValue(value, forKey: attributeName)
                try context.save()
            }
        } catch {
            print("Error updating attribute \(attributeName) for \(entityName): \(error)")
        }
    }
}
