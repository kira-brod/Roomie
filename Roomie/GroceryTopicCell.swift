//
//  GroceryTopicCell.swift
//  Roomie
//
//  Created by whosyihan on 5/28/25.
//

import UIKit

struct GroceryTopic {
    let title: String
    let desc: String
    let questions: [String]
    let iconImageName: String
    let datePoster: String?
}

class GroceryTopicCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
      @IBOutlet weak var titleLabel:    UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var datePosterLabel: UILabel!
}
