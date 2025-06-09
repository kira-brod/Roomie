import UIKit
import Firebase
import FirebaseFirestore

class GroceryTopicCell: UITableViewCell {
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var checkBox: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        contentLabel.isUserInteractionEnabled = false
    }
}

struct GroceryItem {
    var id: String?
    var name: String
    var quantity: Int
    var isChecked: Bool
    var assignedRoomie: String
    var createdAt: Date
    
    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "quantity": quantity,
            "isChecked": isChecked,
            "assignedRoomie": assignedRoomie,
            "createdAt": Timestamp(date: createdAt)
        ]
    }
    
    static func fromDictionary(_ data: [String: Any], id: String) -> GroceryItem? {
        guard let name = data["name"] as? String,
              let quantity = data["quantity"] as? Int,
              let isChecked = data["isChecked"] as? Bool,
              let assignedRoomie = data["assignedRoomie"] as? String else {
            return nil
        }
        

        let createdAt: Date
        if let timestamp = data["createdAt"] as? Timestamp {
            createdAt = timestamp.dateValue()
        } else {
            createdAt = Date()
        }
        
        return GroceryItem(id: id, name: name, quantity: quantity, isChecked: isChecked, assignedRoomie: assignedRoomie, createdAt: createdAt)
    }
}
