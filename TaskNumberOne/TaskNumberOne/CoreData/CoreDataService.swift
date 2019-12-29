//
//  CoreDataManager.swift
//  TaskNumberOne
//
//  Created by Максим Егоров on 26/04/2019.
//  Copyright © 2019 Максим Егоров. All rights reserved.
//
import CoreData
import Foundation

class CoreDataService {
    static let instance = CoreDataService()
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as NSURL
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "TaskNumberOne", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        return coordinator
    }()
    
    private init() {}
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    func fetchData(entityName: String, keyForSort: String) -> NSFetchedResultsController<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let mainSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        let sortDescriptor = NSSortDescriptor(key: keyForSort, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor, mainSortDescriptor]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataService.instance.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }
    
    func getSomeTask(entityName: String, title: String) ->
        NSFetchedResultsController<NSFetchRequestResult> {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            let predicate = NSPredicate(format: "title == %@", title)
            fetchRequest.predicate = predicate
            let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataService.instance.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            return fetchedResultsController
    }
    
    func createTask(title: String, specification: String) {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Tasks", in: CoreDataService.instance.managedObjectContext)
        let managedObject = Tasks(entity: entityDescription!, insertInto: CoreDataService.instance.managedObjectContext)
        managedObject.title = title
        managedObject.date = Date()
        managedObject.specification = specification
        CoreDataService.instance.saveContext()
    }
    
    func editTask(oldTitle: String, newTitle: String, specification: String) {
        let fetchedResultsController = CoreDataService.instance.getSomeTask(entityName: "Tasks", title: oldTitle)
        try? fetchedResultsController.performFetch()
        guard let task = fetchedResultsController.fetchedObjects?.first as? Tasks else { return }
        task.title = newTitle
        task.specification = specification
        CoreDataService.instance.saveContext()
    }
    
    func getTaskWithIndexPath(indexPath: IndexPath) -> Tasks {
        let fetchedResultsController = CoreDataService.instance.fetchData(entityName: "Tasks", keyForSort: "isDone")
        try? fetchedResultsController.performFetch()
        guard let task = fetchedResultsController.object(at: indexPath) as? Tasks else {
            print("wfemlfkermfeklrmel")
            return Tasks()
        }
        return task
    }
    
    func getTaskWithTitle(title: String) -> Tasks {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let predicate = NSPredicate(format: "title == %@", title)
        fetchRequest.predicate = predicate
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataService.instance.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        try? fetchedResultsController.performFetch()
        guard let task = fetchedResultsController.fetchedObjects?.first as? Tasks else {return Tasks()}
        return task
    }
    
    func getDataBaseSize() -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataService.instance.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        try? fetchedResultsController.performFetch()
        guard  let sections = fetchedResultsController.sections else { return 0 }
        return sections[0].numberOfObjects
    }
}
