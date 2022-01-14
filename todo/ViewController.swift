//
//  ViewController.swift
//  todo
//
//  Created by 김지훈 on 2022/01/11.
//

import UIKit
import CoreData



class ViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{
    // MARK: - Value
    
    @IBOutlet weak var date: UITextField!
    @IBOutlet weak var scheduleText: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var timeText: UITextField!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    struct Schedule {
        var section: Int?
        var id: Int?
        var date: Date
        var todo: String
        var time: Int?
        var alarm: Bool
    }
    
    var i = 0
    // MARK: - Action
    @IBAction func touchUpAddButton(_ sender: UIButton){
        
        
        
        
        let schedule = Schedule(section: 0, id: 0, date: Date(), todo: scheduleText.text!, alarm: false)
        insertSchedule(schedule)
        let result = getSchedule(0, 0)
        result.forEach{
            print($0.todo!)
        }
        print("------------")
        print(result)
        print("------------")
    }
    @IBAction func deleteTest(_ sender: UIButton){
        print("a")
        deleteSchedule(0, 0)
        let result = getSchedule(0, 3)
        print("----a--------")
        print(result)
        print("------a------")
    }
    // MARK: - Method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
    // MARK: - Persistence
    //등록, 조회, 삭제

    func insertSchedule(_ schedule: Schedule){
        let entity = NSEntityDescription.entity(forEntityName: "TodoList", in: context)
        if let entity = entity {
            let managedObject = NSManagedObject(entity: entity, insertInto: context)
            managedObject.setValue(schedule.section, forKey: "section")
            managedObject.setValue(schedule.id, forKey: "id")
            managedObject.setValue(schedule.date, forKey: "date")
            managedObject.setValue(schedule.todo, forKey: "todo")
            managedObject.setValue(schedule.alarm, forKey: "alarm")

            do{
                try context.save()
            } catch{
                print(error.localizedDescription)
            }
        }
     
        
    }
    func getSchedule(_ section: Int, _ id:Int?) -> [TodoList]{
        let request: NSFetchRequest<TodoList> = TodoList.fetchRequest()

        if id != nil {
            request.predicate = NSPredicate(format: "section = %@ && id = %@", String(section), String(id!))
        }else{
            request.predicate = NSPredicate(format: "section = %@", String(section))
        }
        do{
            let result = try context.fetch(request)
            return result
        }catch{
            print(error.localizedDescription)
            return []
        }
    }

    func deleteSchedule(_ section: Int, _ id:Int?) {
        let result = getSchedule(section, id)
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
    
    func formatSectionData(_ section: Int){
        deleteSchedule(section, nil)
    }
    
    //modify 구현예정
}

