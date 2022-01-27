//
//  ViewController.swift
//  todo
//
//  Created by 김지훈 on 2022/01/11.
//

import UIKit
import CoreData
import SnapKit
import DropDown
class MainViewController: UIViewController, UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate, SendUpdateProtocol, ChangeDateProtocol{
    
    static var shared: MainViewController = MainViewController()
    // MARK: - Outlet
    @IBOutlet weak var startDate: UIDatePicker!
    @IBOutlet weak var endDate: UIDatePicker!
    @IBOutlet weak var scheduleText: UITextField!
//    @IBOutlet weak var reitration: UISwitch! // 반복 구현해야함
    @IBOutlet weak var alarmSwitch: UISwitch!
    @IBOutlet weak var todoTable: UITableView!
    @IBOutlet weak var dayScroll: UIScrollView!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var yearButton: UIButton!
    @IBOutlet weak var dayOfWeekLabel: UILabel!
    @IBOutlet weak var mon: UIButton!
    @IBOutlet weak var tue: UIButton!
    @IBOutlet weak var wed: UIButton!
    @IBOutlet weak var thi: UIButton!
    @IBOutlet weak var fri: UIButton!
    @IBOutlet weak var sat: UIButton!
    @IBOutlet weak var sun: UIButton!
//    weak var delegate: SendUpdateProtocol?
    var monChecked: Bool! = false
    var tueChecked: Bool! = false
    var wedChecked: Bool! = false
    var thuChecked: Bool! = false
    var friChecked: Bool! = false
    var satChecked: Bool! = false
    var sunChecked: Bool! = false
    var dayButtonArray: [UIButton]?
    //MARK: - Value
    var pm: PersistenceManager = PersistenceManager.shared
    let daysOfMonth:[Int:Int]! = [1:31,2:28,3:31,4:30,5:31,6:30,7:31,8:31,9:30,10:31,11:30,12:31]
    var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 5
        return view
    }()
    var year: Int = 1 {
        didSet{
            pm.updateDate(year, "year")
        }
    }
    var days: [Int] = []
    var month: Int = 1 {
        didSet{
            days = []
            for i in 1...daysOfMonth[month]! {
                days.append(i)
            }
            if day > days.last!{
                day = days.last!
            }
            fetchAndReload()
            showScrollView()
            pm.updateDate(month, "month")
        }
    }
    var day: Int = 1{
        didSet{
            pm.updateDate(day, "day")
            print(dayScroll.contentOffset)
//            dayScroll.setContentOffset(CGPoint(x: (day <= 9 ? day * day * 2 : day * 20), y: 0), animated: true)
        }
    }
    var selectedDayButton: UIButton?
    var i = 0
    // MARK: - Action
    
    @IBAction func touchUpAddButton(_ sender: UIButton){
//        print("시작:", startDate.date)
//        print("종료:", endDate.date)
//        print("내용: ", scheduleText.text!)
//        print("반복: ", alarmSwitch.isOn)//?
//        print("알람: ", alarmSwitch.isOn)
        
    
        if endDate.date < startDate.date { // 제약조건
            showToast(message: "에러: 시작 > 종료")
        }else{ //실행
            var re: [Int] = []
            for (i,button) in dayButtonArray!.enumerated(){
                if button.titleColor(for: .normal) == UIColor.red{
                    re.append(i)
                }
            }
            let schedule = PersistenceManager.Schedule(start: startDate.date, end: endDate.date, todo: scheduleText.text!, re: re, alarm: alarmSwitch.isOn)
            pm.insertSchedule(schedule)
            fetchAndReload()
        }
//        resetCondition()

    }
    @IBAction func touchUpWeekButton(_ sender: UIButton!){
//        print(dayButtonArray)
//        print(sender.tintColor)
        if sender.titleColor(for: .normal) == UIColor.systemBlue {
            setButtonColor(sender, UIColor.red)
        }else{
            setButtonColor(sender, UIColor.systemBlue)

        }
    }
    @IBAction func deleteTest(_ sender: UIButton){
        pm.deleteSchedule(nil)
        fetchAndReload()
    }
    @IBAction func touchUpResetConditionButton(_ sender: UIButton){
        resetCondition()
    }
    @IBAction func touchUpYearButton(_ sender: UIButton){
        let dropDown = DropDown()
        dropDown.dataSource = ["2022","2023"]
        dropDownAndChangeButtonText(dropDown, sender,"year")
    }
    @IBAction func touchUpMonthButton(_ sender: UIButton){
        let dropDown = DropDown()
        dropDown.dataSource = {
            var temp: [String] = []
            for i in 1...12 {
                temp.append(String(i))
            }
            return temp
        }()
        dropDownAndChangeButtonText(dropDown, sender,"month")
        
    }
    
    
    // MARK: - Method
    func dropDownAndChangeButtonText(_ dropDown: DropDown, _ sender: UIButton, _ type:String){
        dropDown.anchorView = sender
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.show()
        dropDown.selectionAction = {[weak self](index: Int, item: String) in
            sender.setTitle("\(item)"+(type == "month" ? "월":"년"), for: .normal)
            sender.titleLabel?.font = UIFont.boldSystemFont(ofSize: 40)
            if type == "year" {
                self?.year = Int(item)!
            }else {
                self?.month = Int(item)!
                self?.days = [1,2]
            }
            self?.fetchAndReload()
        }
        
    }
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
    func changeDate(_ yyyy:Int, _ mm:String, _ dd: String){
        print("asd")
        let nowDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        var str = dateFormatter.string(from: nowDate)
        str += ":\(yyyy):\(mm):\(dd)"
        dateFormatter.dateFormat = "HH:mm:yyyy:MM:dd"
        let result = dateFormatter.date(from: str)!
        print(result,year,month,day)
        startDate?.date = result
        endDate?.date = result
    }
    override func viewWillAppear(_ animated: Bool) {
        fetchAndReload()
    }
    func showScrollView() {
        view.addSubview(dayScroll)
//        dayScroll.backgroundColor = UIColor.gray
        dayScroll.snp.makeConstraints { make in
            make.trailing.equalTo(-70)
            make.leading.equalTo(130)
            make.height.equalTo(35)
            make.top.equalTo(45)
        }
        dayScroll.showsHorizontalScrollIndicator = false

        stackView.arrangedSubviews.forEach { child in
            stackView.removeArrangedSubview(child)
            child.removeFromSuperview()
        }
        dayScroll.addSubview(stackView)
        stackView.snp.makeConstraints{ make in
            make.leading.trailing.equalToSuperview()
            make.height.equalToSuperview()
        }
        updateDays(stackView)

        
    }
    func updateDays(_ stackView: UIStackView ){
        days.forEach{ data in
            let button = UIButton()
            if data == day {
                button.setTitleColor(.red, for: .normal)
                selectedDayButton = button
            }else{
                button.setTitleColor(.blue, for: .normal)
            }
            button.layer.cornerRadius = 12
            button.backgroundColor = UIColor.orange
            button.setTitle(String(data), for: .normal)
            stackView.addArrangedSubview(button)
            
            button.snp.makeConstraints{make in
                make.height.width.equalTo(30)

//                make.left.equalTo(1)
            }
            button.addTarget(self, action: #selector(touchUpDayButton(_:)), for: .touchUpInside)
            
        }
        
    }
    @objc func touchUpDayButton(_ sender:UIButton){
        selectedDayButton?.setTitleColor(.blue, for: .normal)
        selectedDayButton = sender
        sender.setTitleColor(.red, for: .normal)
        day = Int(sender.titleLabel?.text ?? "1")!
        fetchAndReload()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        pm.delegate = self
        dayButtonArray = [mon,tue,wed,thi,fri,sat,sun]
//        startDate.
//        pm = PersistenceManager.shared
        resetCondition()
//        fetchWeekStackView()

        
    }
//    func fetchWeekStackView(){
//        view.addSubview(weekStackView)
//        dayScroll.backgroundColor = UIColor.gray
//        weekStackView.snp.makeConstraints { make in
//            make.trailing.equalTo(-70)
//            make.leading.equalTo(130)
//            make.height.equalTo(35)
//            make.top.equalTo(200)
//        }
//    }
    func resetCondition(){
        let nowDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        var str = dateFormatter.string(from: nowDate)
        let result = dateFormatter.date(from: str)!
        startDate.date = result
        endDate.date = result
        scheduleText.text = ""
        alarmSwitch.isOn = false
        dateFormatter.dateFormat = "yyyy:MM:dd"
        str = dateFormatter.string(from: nowDate)
        let arr = str.components(separatedBy: ":")
        
        year = Int(arr[0])!
        month = Int(arr[1])!
        day = Int(arr[2])!
        monthButton.setTitle(String(month)+"월", for: .normal)
        yearButton.setTitle(String(year)+"년", for: .normal)
        
        fetchAndReload()
        showScrollView()
        
        for button in dayButtonArray!{
            setButtonColor(button, UIColor.systemBlue)
        }
        
    }
    func setButtonColor(_ button: UIButton, _ color: UIColor){
        print(button)
        button.setTitle(button.titleLabel?.text!, for: .normal)
        button.setTitleColor(color, for: .normal)
        
    }
    func setWeekDay(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
//        let stringMonth =
        let now = dateFormatter.date(from: "\(year)\(String(format: "%02d", month))\(String(format: "%02d", day))")
        let dayIndex = Calendar.current.component(.weekday, from: now!)
        let weekdays = ["일","월","화","수","목","금","토"]
        dayOfWeekLabel.text = weekdays[dayIndex-1]+"요일"
        
    }
    
    // MARK: - TableView
    func fetchAndReload(){
        
        do{
            try  pm.fetchResultController.performFetch()
            todoTable.reloadData()
            setWeekDay()
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
        return pm.fetchResultController.sections?[0].numberOfObjects ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CustomTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        let row = pm.fetchResultController.object(at: indexPath)
        cell.startLabel.text = self.dateFormatter.string(from: row.start!)
        cell.endLabel.text = self.dateFormatter.string(from: row.end!)
        cell.contentLabel.text = row.todo
        var reString = ""
        for i in row.re!{
            var temp = ""
            switch i {
            case 0:
                temp = " 월"
            case 1:
                temp = " 화"
            case 2:
                temp = " 수"
            case 3:
                temp = " 목"
            case 4:
                temp = " 금"
            case 5:
                temp = " 토"
            case 6:
                temp = " 일"
            default:
                print("error")
            }
            reString += temp
        }
        cell.reLabel.text = "반복:" + (reString == "" ? " 없음" : reString)

        //        row.alarm
        cell.startDate = row.start
        cell.endDate = row.end

        
        let alarmTableSwitch = UISwitch(frame: .zero)
        alarmTableSwitch.setOn(row.alarm, animated: true)
        alarmTableSwitch.tag = NSInteger(row.id)
        
        alarmTableSwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = alarmTableSwitch
        
        if row.state == 1 {
//            cell.backgroundColor = UIColor.gray
            alarmTableSwitch.isEnabled = false
        }else{
            cell.backgroundColor = UIColor.white
        }
        return cell
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions: [UIContextualAction] = []

        let row = pm.fetchResultController.object(at: indexPath)
        let delete = UIContextualAction(style: .normal, title: "삭제", handler: {(action, view, completionHandler) in
            let alert = UIAlertController(title: "주의", message: "정말 삭제하시겠습니까?", preferredStyle: UIAlertController.Style.alert)
            let alertCancel = UIAlertAction(title: "취소", style: UIAlertAction.Style.default)
            let alertOk = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: {
                (action) in
                self.pm.deleteSchedule(NSInteger(row.id))
                self.fetchAndReload()
            })
            alert.addAction(alertCancel)
            alert.addAction(alertOk)
        
    //        present(alert,animated: true, completion{})
            self.present(alert, animated: false)
        })
        delete.backgroundColor = UIColor.red
        actions.append(delete)
        if row.state == 0{
            let complete = UIContextualAction(style: .normal, title: "완료", handler: {(action, view, completionHandler) in
                let alert = UIAlertController(title: "주의", message: "완료 후엔 수정할 수 없어요! 계속할까요?", preferredStyle: UIAlertController.Style.alert)
                let alertCancel = UIAlertAction(title: "취소", style: UIAlertAction.Style.default)
                let alertOk = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: {
                    (action) in
                    row.state = 1
                    row.alarm = false
                    self.fetchAndReload()
                })
                alert.addAction(alertCancel)
                alert.addAction(alertOk)

                self.present(alert, animated: false)
            })
            let modify = UIContextualAction(style: .normal, title: "수정", handler: {(action, view, completionHandler) in
                guard let nextVC: ModifyViewController = self.storyboard?.instantiateViewController(withIdentifier: "ModifyView") as? ModifyViewController else{
                    return
                }
                nextVC.startToSet = row.start
                nextVC.endToSet = row.end
                nextVC.contentToSet = row.todo
                nextVC.cellId = NSInteger(row.id)
                nextVC.alarmToSet = row.alarm
                nextVC.delegate = self
                nextVC.modalPresentationStyle = .automatic
                self.present(nextVC, animated: true, completion: nil)
            })
            complete.backgroundColor = UIColor.green
            modify.backgroundColor = UIColor.blue
            actions.append(modify)
            actions.append(complete)
            
        }
        return UISwipeActionsConfiguration(actions: actions)
    }

    @objc func switchChanged(_ sender: UISwitch!){
        pm.modifySchedule(sender.tag, nil, nil, nil, nil, sender.isOn,nil)
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
    func modifySchedule(_ id:Int, _ start:Date?, _ end:Date?, _ content: String?, _ re: [Int]?, _ alarm: Bool?, _ state:Int?){
        pm.modifySchedule(id, start, end, content, re, alarm,state)
    }

    
    
    
}

