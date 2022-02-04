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
        }
    }
    var dayOfWeek = 0 //월: 0  일: 6
    var selectedDayButton: UIButton?
    var i = 0
    // MARK: - Action
    
    @IBAction func touchUpAddButton(_ sender: UIButton){
        if endDate.date < startDate.date { // 제약조건
            showToast(message: "에러: 시작 > 종료") //ex
        }else{ //실행
            var re: [Int] = []
            for (i,button) in dayButtonArray!.enumerated(){
                if button.backgroundColor == UIColor.black{
                        re.append(i)
                }
            }
            let schedule = PersistenceManager.Schedule(start: startDate.date, end: endDate.date, todo: scheduleText.text!, re: re, alarm: alarmSwitch.isOn)
            pm.insertSchedule(schedule)
            fetchAndReload()
        }

    }
    @IBAction func touchUpWeekButton(_ sender: UIButton!){
        if sender.titleColor(for: .normal) == UIColor.black {
            setButtonColor(sender, UIColor.white)
            sender.backgroundColor = UIColor.black
        }else{
            setButtonColor(sender, UIColor.black)
            sender.backgroundColor = UIColor.white

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
        dropDown.textFont = UIFont(name: "SDMiSaeng", size: 15)!
        dropDown.anchorView = sender
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.show()
        dropDown.selectionAction = {[weak self](index: Int, item: String) in
            sender.setTitle("\(item)"+(type == "month" ? "월":"년"), for: .normal)
//            sender.titleLabel?.font = UIFont(name: "SDMiSaeng", size: 30)
            if type == "year" {
                self?.year = Int(item)!
            }else {
                self?.month = Int(item)!
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
        let nowDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        var str = dateFormatter.string(from: nowDate)
        str += ":\(yyyy):\(mm):\(dd)"
        dateFormatter.dateFormat = "HH:mm:yyyy:MM:dd"
        let result = dateFormatter.date(from: str)!
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
                button.setTitleColor(.white, for: .normal)
                selectedDayButton = button
                button.backgroundColor = .black
            }else{
                button.setTitleColor(.black, for: .normal)
                
            }
            button.layer.cornerRadius = 12
//            button.backgroundColor = UIColor.orange
            button.layer.borderWidth = 2
            button.layer.borderColor = UIColor.darkGray.cgColor
            button.setTitle(String(data), for: .normal)
            stackView.addArrangedSubview(button)
            button.titleLabel?.font = UIFont(name: "SDMiSaeng", size: 30)
            button.snp.makeConstraints{make in
                make.height.width.equalTo(30)
            }
            button.addTarget(self, action: #selector(touchUpDayButton(_:)), for: .touchUpInside)
            
        }
        
    }
    @objc func touchUpDayButton(_ sender:UIButton){
        
        selectedDayButton?.setTitleColor(.black, for: .normal)
        selectedDayButton?.backgroundColor = .white
        selectedDayButton = sender
        sender.setTitleColor(.white, for: .normal)
        sender.backgroundColor = .black
        day = Int(sender.titleLabel?.text ?? "1")!
        fetchAndReload()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        pm.delegate = self
        dayButtonArray = [mon,tue,wed,thi,fri,sat,sun]
        resetCondition()
        for button in dayButtonArray!{
            setButtonColor(button, UIColor.black)
            button.layer.cornerRadius = 9
            button.layer.borderColor = UIColor.darkGray.cgColor
            button.layer.borderWidth = 1
        }
        setButtonColor(monthButton, UIColor.black)
        monthButton.layer.cornerRadius = 9
        monthButton.layer.borderColor = UIColor.darkGray.cgColor
        monthButton.layer.borderWidth = 0.3

        setButtonColor(yearButton, UIColor.black)
        yearButton.layer.cornerRadius = 9
        yearButton.layer.borderColor = UIColor.darkGray.cgColor
        yearButton.layer.borderWidth = 0.3
        
        
        scheduleText.layer.cornerRadius = 3
        
        scheduleText.borderStyle = .roundedRect
        scheduleText.layer.borderColor = UIColor.darkGray.cgColor
        scheduleText.layer.borderWidth = 1
//        scheduleText.layer.borderWidth = 6
        
    }
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
        

        
    }
    func setButtonColor(_ button: UIButton, _ color: UIColor){
        button.setTitle(button.titleLabel?.text!, for: .normal)
        button.setTitleColor(color, for: .normal)
//        button.titleLabel?.font = UIFont(name: "SDMiSaeng", size: 30.0)
        
    }
    func setWeekDay(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
//        let stringMonth =
        let now = dateFormatter.date(from: "\(year)\(String(format: "%02d", month))\(String(format: "%02d", day))")
        dayOfWeek = Calendar.current.component(.weekday, from: now!)-2
        if dayOfWeek < 0 {
            dayOfWeek = 6
        }
        let weekdays = ["월","화","수","목","금","토","일"]
        dayOfWeekLabel.text = weekdays[dayOfWeek]+"요일"
        
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = pm.fetchResultController.object(at: indexPath)
//        print(dayOfWeek,row.re,row.re!.isEmpty,row.re!.contains(dayOfWeek-1))
        if ((row.re!.isEmpty) || ((row.re!.contains(dayOfWeek)))) {
            return tableView.rowHeight
        }else{
            return 0
        }
        
        //달력 구현 후 테스트
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

