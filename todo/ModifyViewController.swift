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

    let ParentView: ViewController = ViewController()
    var startToSet: Date?
    var endToSet: Date?
    var contentToSet: String?
//    var reToSet:
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

        // Do any additional setup after loading the view.
    }
    @IBAction func touchUpSaveButton(_sender: UIButton){
        let alert = UIAlertController(title: "알림", message: "변경사항을 저장하시겠습니까 ?", preferredStyle: UIAlertController.Style.alert)
        let alertCancel = UIAlertAction(title: "cancel", style: UIAlertAction.Style.default)
        let alertOk = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {
            (action) in
            self.navigationController?.popViewController(animated: false)
            
            self.ParentView.modifySchedule(self.cellId!, self.ModifyStart.date, self.ModifyEnd.date, self.ModifyContent.text, [1,2,3], self.ModifyAlarm.isOn)
            self.dismiss(animated: true, completion: nil)
            self.delegate?.sendUpdate()
            
        })
        alert.addAction(alertCancel)
        alert.addAction(alertOk)
    
//        present(alert,animated: true, completion{})
        present(alert, animated: false)
        
    }
    @IBAction func touchUpDeleteButton(_sender: UIButton){
        dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
