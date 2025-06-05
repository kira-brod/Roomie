//
//  AddChoreViewController.swift
//  Roomie
//
//  Created by Mor Vered on 6/1/25.
//

import UIKit


struct Chore {
    let title: String
    let date: Date
    let assignedTo: String
    let color: UIColor
    let notes: String?
}

protocol AddChoreDelegate: AnyObject {
    func didAddChore(_ chore: Chore)
}

class AddChoreViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    let roommates = ["Roomie 1", "Roomie 2", "Roomie 3", "Roomie 4", "Roomie 5"]

    let roommateColors: [String: UIColor] = [
        "Roomie 1": .red,
        "Roomie 2": .blue,
        "Roomie 3": .green,
        "Roomie 4": .yellow,
        "Roomie 5": .purple
    ]


    @IBOutlet weak var choreName: UITextField!
    @IBOutlet weak var choreDate: UIDatePicker!
    override func viewDidLoad() {
        super.viewDidLoad()
        Roomie.delegate = self
        Roomie.dataSource = self

        // Do any additional setup after loading the view.
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return roommates.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return roommates[row]
    }

    @IBOutlet weak var Roomie: UIPickerView!
    
   
    @IBOutlet weak var choreNotes: UITextField!
    
    weak var delegate: AddChoreDelegate?

    
    @IBAction func add(_ sender: Any) {
        print("Add button tapped")

        let title = choreName.text ?? ""
        
        let date = choreDate.date
            
        let selectedRow = Roomie.selectedRow(inComponent: 0)
        let assignedTo = roommates[selectedRow]
        let color = roommateColors[assignedTo] ?? UIColor.gray
            
        let notes = choreNotes.text

        let chore = Chore(title: title, date: date, assignedTo: assignedTo, color: color, notes: notes)
            
        delegate?.didAddChore(chore)
            
        dismiss(animated: true)
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
