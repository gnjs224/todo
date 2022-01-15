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
    
    @IBOutlet weak var startDate: UIDatePicker!
    @IBOutlet weak var endDate: UIDatePicker!
    @IBOutlet weak var scheduleText: UITextField!
    @IBOutlet weak var reitration: UISwitch! // 반복 구현해야함
    @IBOutlet weak var alarmSwitch: UISwitch!
    @IBOutlet weak var todoTable: UITableView!
    
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    lazy var fetchResultController: NSFetchedResultsController<TodoList> = {
        let fetchRequest: NSFetchRequest<TodoList> = TodoList.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "start",ascending: false)]
        let fetchResult = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        return fetchResult
    }()
    struct Schedule {
        var start: Date
        var end: Date
        var todo: String
        var re: [Int]
        var alarm: Bool
    }
    
    var i = 0
    // MARK: - Action
    @IBAction func touchUpAddButton(_ sender: UIButton){
        //유저디폴트로 문자로입력 on인지 off인지 확인
        
        print("시작:",startDate.date)
        print("종료:",endDate.date)
        print("내용: ",scheduleText.text!)
        print("반복: ", alarmSwitch.isOn)//?
        print("알람: ", alarmSwitch.isOn)
        //날짜 키워드
        //오늘, 내일, 모레, 년, 월, 일, 요일 이번주, 다음주, 다다음주, 3주뒤 4주뒤 요일, 다음달, 매달, 매일, 매주
        //우선 날짜선택하는거로 ?
        
        
        
        let schedule = Schedule(start: startDate.date, end: endDate.date, todo: scheduleText.text!, re: [0,1,2,3], alarm: false)
        insertSchedule(schedule)
        let result = getSchedule(nil)
        result.forEach{
            print($0.todo!)
        }
        print("------------")
        print(result)
        print("------------")
        
        do{
            try fetchResultController.performFetch()
            print("fetch success")
        }catch let err{
            print("Fatal error", err.localizedDescription)
        }
    }
    @IBAction func deleteTest(_ sender: UIButton){
        print("a")
        deleteSchedule(nil)
        let result = getSchedule(nil)
        print("----a--------")
        print(result)
        print("------a------")
    }
    // MARK: - Method
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    
    
    // MARK: - Persistence
    //등록, 조회, 삭제
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
    
    func formatSectionData(_ section: Int){
        deleteSchedule(nil)
    }
    
    //modify 구현예정
    
    // MARK: - 테이블 뷰
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchResultController.sections?[0].numberOfObjects ?? 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
//    unc reloadTodoTableAndShowData(){
//        self.tableView.reloadData()
//
//    }
}

