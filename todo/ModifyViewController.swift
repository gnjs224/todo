//
//  ModifyViewController.swift
//  todo
//
//  Created by 김지훈 on 2022/01/20.
//

import UIKit

class ModifyViewController: UIViewController {
    var startToSet: Date?
    var endToSet: Date?
    var contentToSet: String?
//    var reToSet:
    var alarmToSet: Bool?
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
        
    }
    @IBAction func touchUpDeleteButton(_sender: UIButton){
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
