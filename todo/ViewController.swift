//
//  ViewController.swift
//  todo
//
//  Created by 김지훈 on 2022/01/11.
//

import UIKit
import CoreData


protocol SendUpdateProtocol: AnyObject{
    func sendUpdated()
}
class ViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate{
    // MARK: - Value
    
    @IBOutlet weak var startDate: UIDatePicker!
    @IBOutlet weak var endDate: UIDatePicker!
    @IBOutlet weak var scheduleText: UITextField!
    @IBOutlet weak var reitration: UISwitch! // 반복 구현해야함
    @IBOutlet weak var alarmSwitch: UISwitch!
    @IBOutlet weak var todoTable: UITableView!

//    @IBOutlet weak var alarmTableSwitch: UISwitch!

    weak var delegate: SendUpdateProtocol?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    lazy var fetchResultController: NSFetchedResultsController<TodoList> = {
        let fetchRequest: NSFetchRequest<TodoList> = TodoList.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: " start = %@", currentDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "start",ascending: false)]
        let fetchResult = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchResult.delegate = self
        return fetchResult
    }()
    let dateFormatter: DateFormatter = {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter
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
        
        print("시작:", startDate.date)
        print("종료:", endDate.date)
        print("내용: ", scheduleText.text!)
        print("반복: ", alarmSwitch.isOn)//?
        print("알람: ", alarmSwitch.isOn)
        //날짜 키워드
        //오늘, 내일, 모레, 년, 월, 일, 요일 이번주, 다음주, 다다음주, 3주뒤 4주뒤 요일, 다음달, 매달, 매일, 매주
        //우선 날짜선택하는거로 ?
        if endDate.date < startDate.date {
            showToast(message: "에러: 시작 > 종료")
        }else{
            let schedule = Schedule(start: startDate.date, end: endDate.date, todo: scheduleText.text!, re: [0,1,2,3], alarm: alarmSwitch.isOn)
            insertSchedule(schedule)
            let result = getSchedule(nil)
            result.forEach{
                print($0.todo!)
            }
            print("------------")
            print(result)
            print("------------")
            fetchAndReload()
        }

    }
    @IBAction func deleteTest(_ sender: UIButton){
        print("a")
        deleteSchedule(nil)
        let result = getSchedule(nil)
        print("----a--------")
        print(result)
        print("------a------")
        fetchAndReload()
    }
    @IBAction func touchUpAlarmTableSwitch(_ sender: UISwitch){
        print(sender.isOn)
//        print(tableView.indexPath)
//        print(tableView.in)
    }
    // MARK: - Method
    func showToast(message : String, font: UIFont = UIFont.systemFont(ofSize: 14.0)) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 10.0, delay: 0.1, options: .curveEaseOut, animations: { toastLabel.alpha = 0.0 }, completion: {(isCompleted) in toastLabel.removeFromSuperview() })
        
    }
    override func viewWillAppear(_ animated: Bool) {
        fetchAndReload()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let nowDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let str = dateFormatter.string(from: nowDate)
        startDate.date = dateFormatter.date(from: str)!
        endDate.date = dateFormatter.date(from: str)!
        print("start,end",startDate.date,endDate.date)
        print(str)
//        date.dateFormat(fromTemplate: <#T##String#>, options: <#T##Int#>, locale: <#T##Locale?#>)
        print("start",startDate.date)
        fetchAndReload()
        // Do any additional setup after loading the view.
    }
    func fetchAndReload(){
        do{
            try fetchResultController.performFetch()
            todoTable.reloadData()
            print("fetch success")
        }catch let err{
            print("Fatal error", err.localizedDescription)
        }
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
    
    func formatAllData(){
        deleteSchedule(nil)
    }
    func modifySchedule(_ id:Int, _ start:Date?, _ end:Date?, _ content: String?, _ re: [Int]?, _ alarm: Bool?){
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
        }
        do{
            try context.save()
            
        } catch{
            print(error.localizedDescription)
        }
        
//        print(id,start,end,content,re,alarm)
    }
    //modify 구현예정
    
    // MARK: - 테이블 뷰
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchResultController.sections?[0].numberOfObjects ?? 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CustomTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        let row = fetchResultController.object(at: indexPath)
        cell.startLabel.text = self.dateFormatter.string(from: row.start!)
        cell.endLabel.text = self.dateFormatter.string(from: row.end!)
        cell.contentLabel.text = row.todo
        cell.reLabel.text = "구현예정"
//        row.alarm
        cell.startDate = row.start
        cell.endDate = row.end
        let alarmTableSwitch = UISwitch(frame: .zero)
        alarmTableSwitch.setOn(row.alarm, animated: true)
        alarmTableSwitch.tag = NSInteger(row.id)
        alarmTableSwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = alarmTableSwitch
        return cell
    }
    @objc func switchChanged(_ sender: UISwitch!){
        modifySchedule(sender.tag, nil, nil, nil, nil, sender.isOn)
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nextVC: ModifyViewController = segue.destination as? ModifyViewController else{
            return
        }
        guard let cell: CustomTableViewCell = sender as? CustomTableViewCell else{
            return
        }
        nextVC.startToSet = cell.startDate
        nextVC.endToSet = cell.endDate
        nextVC.contentToSet = cell.contentLabel.text
        nextVC.cellId = cell.accessoryView?.tag
//        print(cell)
//        nextVC.reToSet
        nextVC.alarmToSet = (cell.accessoryView as! UISwitch).isOn
//        print("asd",cell.accessoryView?.tag)
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        if type == .insert{
//            print("asd")
//            delegate?.sendUpdated()
////            blockOperations.append(BlockOperation(block: {s}))
//        }
//    }
    
}

