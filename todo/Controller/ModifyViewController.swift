//
//  ModifyViewController.swift
//  todo
//
//  Created by 김지훈 on 2022/01/20.
//

import UIKit
import CoreData
protocol SendUpdateProtocol : AnyObject{
    func sendUpdate()
}
class ModifyViewController: UIViewController, NSFetchedResultsControllerDelegate {
    weak var delegate: SendUpdateProtocol?
    var startToSet: Date?
    var endToSet: Date?
    var contentToSet: String?
    var alarmToSet: Bool?
    var cellId: Int!
    @IBOutlet weak var ModifyStart: UIDatePicker!
    @IBOutlet weak var ModifyEnd: UIDatePicker!
    @IBOutlet weak var ModifyContent: UITextField!
    @IBOutlet weak var ModifyRe: UIDatePicker!
    @IBOutlet weak var ModifyAlarm: UISwitch!


    override func viewWillAppear(_ animated: Bool) {
        ModifyStart.date = startToSet!
        ModifyEnd.date = endToSet!
        ModifyContent.text = contentToSet!
        ModifyAlarm.isOn = alarmToSet!
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func touchUpSaveButton(_sender: UIButton){
        let alert = UIAlertController(title: "알림", message: "변경사항을 저장하시겠습니까 ?", preferredStyle: UIAlertController.Style.alert)
        let alertCancel = UIAlertAction(title: "취소", style: UIAlertAction.Style.default)
        let alertOk = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: {
            (action) in
            self.navigationController?.popViewController(animated: false)
            
            MainViewController.shared.modifySchedule(self.cellId!, self.ModifyStart.date, self.ModifyEnd.date, self.ModifyContent.text, [1,2,3], self.ModifyAlarm.isOn,0)
            self.dismiss(animated: true, completion: nil)
            self.delegate?.sendUpdate()
            
        })
        alert.addAction(alertCancel)
        alert.addAction(alertOk)
        present(alert, animated: false)
        
    }
    @IBAction func touchUpDeleteButton(_sender: UIButton){
        dismiss(animated: true, completion: nil)
    }
}
