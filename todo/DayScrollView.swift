//
//  DayScrollView:.swift
//  todo
//
//  Created by 김지훈 on 2022/01/23.
//

import UIKit

class DayScrollView: UIScrollView {
    override init(frame:CGRect){
        super.init(frame: frame)
        
        configure()
    }
    @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("Not implemented xib init")
        }
    func configure(){}
    func bind(){}
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
