import UIKit
import Firebase
import FirebaseFirestore

class GroceryTopicCell: UITableViewCell {
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var checkBox: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var lineImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentLabel.isUserInteractionEnabled = false
        lineImageView.isHidden = true
    }
}

// MARK: - GroceryItem Struct
struct GroceryItem {
    var id: String?
    var name: String
    var quantity: Int
    var isChecked: Bool
    var assignedRoomie: String
    
    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "quantity": quantity,
            "isChecked": isChecked,
            "assignedRoomie": assignedRoomie
        ]
    }
    
    static func fromDictionary(_ data: [String: Any], id: String) -> GroceryItem? {
        guard let name = data["name"] as? String,
              let quantity = data["quantity"] as? Int,
              let isChecked = data["isChecked"] as? Bool,
              let assignedRoomie = data["assignedRoomie"] as? String else {
            return nil
        }
        
        return GroceryItem(id: id, name: name, quantity: quantity, isChecked: isChecked, assignedRoomie: assignedRoomie)
    }
}
