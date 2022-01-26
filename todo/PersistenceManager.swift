//
//  PersistenceManager.swift
//  todo
//
//  Created by 김지훈 on 2022/01/13.
//

import UIKit
import CoreData
protocol ChangeDateProtocol : AnyObject{
    func changeDate(_ yyyy:Int, _ mm:String, _ dd: String)
}
class PersistenceManager: NSManagedObject,NSFetchedResultsControllerDelegate {
    static var shared: PersistenceManager = PersistenceManager()
    weak var delegate: ChangeDateProtocol?
    struct Schedule {
        var start: Date
        var end: Date
        var todo: String
        var re: [Int]
        var alarm: Bool
    }
    lazy var year: Int = 1111
    lazy var day: Int = 11
    lazy var month: Int = 1
    
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
    lazy var fetchResultController: NSFetchedResultsController<TodoList> = initFetchResultController()
    func initFetchResultController() -> NSFetchedResultsController<TodoList>{
        let fetchRequest: NSFetchRequest<TodoList> = TodoList.fetchRequest()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy:MM:dd:HH:mm"
        let stringMonth = String(format: "%02d", month)
        let stringDay = String(format: "%02d", day)
        print(stringMonth,stringDay,year)
        let date1 = dateFormatter.date(from: "\(year):\(stringMonth):\(stringDay):\(23):\(59)")! as NSDate
        let date2 = dateFormatter.date(from: "\(year):\(stringMonth):\(stringDay):\(00):\(00)")! as NSDate
        let predicate1 = NSPredicate(format: "start<=%@",date1)
        let predicate2 = NSPredicate(format: "end>=%@",date2)
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [predicate1, predicate2])
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "start",ascending: false)]
        
        let fetchResult = NSFetchedResultsController<TodoList>(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchResult.delegate = self
        return fetchResult
    }
    func updateDate(_ value:Int, _ type:String){
        if type == "year" {
            year = value
        }
        if type == "month" {
            month = value
        }
        if type == "day" {
            day = value
        }
        let stringMonth = String(format: "%02d", month)
        let stringDay = String(format: "%02d", day)
        fetchResultController = initFetchResultController()
        delegate?.changeDate(year,stringMonth,stringDay)
        
    }
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
