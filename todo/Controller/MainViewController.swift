//
//  ViewController.swift
//  todo
//
//  Created by 김지훈 on 2022/01/11.
//

import UIKit
import CoreData


//protocol SendUpdateProtocol: AnyObject{
//    func sendUpdated()
//}
class MainViewController: UIViewController,       UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate, SendUpdateProtocol{

    static var shared: MainViewController = MainViewController()
    // MARK: - Value
    
    @IBOutlet weak var startDate: UIDatePicker!
    @IBOutlet weak var endDate: UIDatePicker!
    @IBOutlet weak var scheduleText: UITextField!
    @IBOutlet weak var reitration: UISwitch! // 반복 구현해야함
    @IBOutlet weak var alarmSwitch: UISwitch!
    @IBOutlet weak var todoTable: UITableView!

    weak var delegate: SendUpdateProtocol?

    let pm = PersistenceManager.shared
//    let tm = MainTableViewController()
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
            let schedule = PersistenceManager.Schedule(start: startDate.date, end: endDate.date, todo: scheduleText.text!, re: [0,1,2,3], alarm: alarmSwitch.isOn)
            pm.insertSchedule(schedule)

            fetchAndReload()
        }
        resetCondition()

    }
    @IBAction func deleteTest(_ sender: UIButton){
        pm.deleteSchedule(nil)
        fetchAndReload()
    }
    @IBAction func touchUpResetConditionButton(_ sender: UIButton){
        resetCondition()
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
        resetCondition()
        fetchAndReload()
    }
    func resetCondition(){
        let nowDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let str = dateFormatter.string(from: nowDate)
        startDate.date = dateFormatter.date(from: str)!
        endDate.date = dateFormatter.date(from: str)!
        scheduleText.text = ""
        alarmSwitch.isOn = false
        
    }
    
    
    // MARK: - 테이블 뷰
    func fetchAndReload(){
        do{
            try pm.fetchResultController.performFetch()
            todoTable.reloadData()
            print("fetch success")
        }catch let err{
            print("Fatal error", err.localizedDescription)
        }
    }
    

    func sendUpdate() {
            fetchAndReload()
        }

        
    let dateFormatter: DateFormatter = {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter
    }()
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pm.fetchResultController.sections?[0].numberOfObjects ?? 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CustomTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        let row = pm.fetchResultController.object(at: indexPath)
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
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let complete = UIContextualAction(style: .normal, title: "완료", handler: {(action, view, completionHandler) in
            let alert = UIAlertController(title: "주의", message: "더이상 표시되지 않습니다. 계속하시겠습니까?", preferredStyle: UIAlertController.Style.alert)
            let alertCancel = UIAlertAction(title: "취소", style: UIAlertAction.Style.default)
            let alertOk = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: {
                (action) in
                print("complete")
            })
            alert.addAction(alertCancel)
            alert.addAction(alertOk)
        
    //        present(alert,animated: true, completion{})
            self.present(alert, animated: false)
        })
        let modify = UIContextualAction(style: .normal, title: "수정", handler: {(action, view, completionHandler) in
            print("modify")
        })
        let delete = UIContextualAction(style: .normal, title: "삭제", handler: {(action, view, completionHandler) in
            print("delete")
        })
        complete.backgroundColor = UIColor.green
        modify.backgroundColor = UIColor.blue
        delete.backgroundColor = UIColor.red
        return UISwipeActionsConfiguration(actions: [delete,modify,complete])
    }

    @objc func switchChanged(_ sender: UISwitch!){
        pm.modifySchedule(sender.tag, nil, nil, nil, nil, sender.isOn)
    }
    
    // MARK: - Navigation

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
        nextVC.alarmToSet = (cell.accessoryView as! UISwitch).isOn
        nextVC.delegate = self

    }
    func modifySchedule(_ id:Int, _ start:Date?, _ end:Date?, _ content: String?, _ re: [Int]?, _ alarm: Bool?){
        pm.modifySchedule(id, start, end, content, re, alarm)
    }

    
    
    
}

