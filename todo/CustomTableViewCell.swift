//
//  customTableViewCell.swift
//  todo
//
//  Created by 김지훈 on 2022/01/17.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var reLabel: UILabel!
    @IBOutlet weak var alarm: UISwitch!
    var startDate: Date?
    var endDate: Date?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
