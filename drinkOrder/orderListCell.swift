//
//  orderListCell.swift
//  drinkOrder
//
//  Created by 方芸萱 on 2020/9/25.
//

import UIKit

class orderListCell: UITableViewCell {
    var drinkOrder:DrinkOrder?

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var drinkLabel: UILabel!
    @IBOutlet weak var drinkDetailLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func update(){
        nameLabel.text = drinkOrder?.name
        drinkLabel.text = drinkOrder?.drink
        priceLabel.text = "\(drinkOrder!.price)元"
        drinkDetailLabel.text = String("\(drinkOrder!.sugar) \(drinkOrder!.ice) \(drinkOrder!.volume) \(drinkOrder!.bubble)")
//        print(#function)
    }
    

}
