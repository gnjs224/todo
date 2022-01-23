//
//  PersistenceManager.swift
//  todo
//
//  Created by 김지훈 on 2022/01/13.
//

import UIKit
import CoreData
class PersistenceManager: NSManagedObject,NSFetchedResultsControllerDelegate {
    
    static var shared: PersistenceManager = PersistenceManager()
    struct Schedule {
        var start: Date
        var end: Date
        var todo: String
        var re: [Int]
        var alarm: Bool
    }
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TodoList")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in if let error = error as NSError? {
            fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
        
    }()
    var context: NSManagedObjectContext {
        return self.persistentContainer.viewContext
        
    }

    lazy var fetchResultController: NSFetchedResultsController<TodoList> = {
        let fetchRequest: NSFetchRequest<TodoList> = TodoList.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "start",ascending: false)]
        let fetchResult = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchResult.delegate = self
        return fetchResult
    }()
    func insertSchedule(_ schedule: Schedule){
        let entity = NSEntityDescription.entity(forEntityName: "TodoList", in: context)
        let info = getSchedule(nil)
        var id = 0
        if info.count != 0 {
            id = Int(info.last!.id + 1)
        }
        if let entity = entity {
            let managedObject = NSManagedObject(entity: entity, insertInto: context)
            managedObject.setValue(id, forKey: "id")
            managedObject.setValue(schedule.start, forKey: "start")
            managedObject.setValue(schedule.end, forKey: "end")
            managedObject.setValue(schedule.todo, forKey: "todo")
            managedObject.setValue(schedule.alarm, forKey: "alarm")
            managedObject.setValue(schedule.re, forKey: "re")
            managedObject.setValue(0, forKey: "state")
            do{
                try context.save()
            } catch{
                print(error.localizedDescription)
            }
        }
     
        
    }
    func getSchedule( _ id:Int?) -> [TodoList]{
        let request: NSFetchRequest<TodoList> = TodoList.fetchRequest()

        if id != nil {
            request.predicate = NSPredicate(format: " id = %@", String(id!))
        }
        do{
            let result = try context.fetch(request)
            return result
        }catch{
            print(error.localizedDescription)
            return []
        }
    }

    func deleteSchedule(_ id:Int?) {
        let result = getSchedule(id)
        if result.count < 1 {
            return
        }
        for i in 0...result.count-1 {
            context.delete(result[i])
        }
        do{
            try context.save()
        } catch{
            print(error.localizedDescription)
        }
    }
    
    func formatAllData(){
        deleteSchedule(nil)
    }
    func modifySchedule(_ id:Int, _ start:Date?, _ end:Date?, _ content: String?, _ re: [Int]?, _ alarm: Bool?,_ state: Int?){
        let targetList = getSchedule(id)
        print("modify func: ",targetList)
        if targetList.count != 0 {
            let target = targetList[0]
            if start != nil{
                target.start = start!
            }
            if end != nil{
                target.end = end!
            }
            if content != nil{
                target.todo = content!
            }
//            if re != nil{
//                target.re = re!
//            }
            if alarm != nil{
                target.alarm = alarm!
            }
            if state != nil{
                target.state = Int16(NSInteger(state!))
            }
        }
        do{
            try context.save()
            
        } catch{
            print(error.localizedDescription)
        }
    }

}
