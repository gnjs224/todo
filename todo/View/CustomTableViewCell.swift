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
    var id: Int?
    var startDate: Date?
    var endDate: Date?
    var content: String?
    var alarm: Bool?
    var re: [Int]?
    var state: Int?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
