

import UIKit
import Darwin
import FirebaseFirestore


protocol EventCreationDelegate: AnyObject {
    func didCreateEvent(_ event: Event)
}

class AddEventViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let db = Firestore.firestore()
    let colors: [String] = ["red", "blue", "green", "yellow", "purple"]
    

    weak var delegate: EventCreationDelegate?

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var Notes: UITextField!
    
    @IBOutlet weak var Roomie: UITextField!
    var events: [DateComponents: [Event]] = [:]

    @IBOutlet weak var H1: UILabel!
    @IBOutlet weak var H2: UILabel!
    
    @IBOutlet weak var H2CreatedBy: UILabel!
    
    @IBOutlet weak var picker: UIPickerView!
    var selectedDate: DateComponents?
    var roommates : [String] = []
    var indexSelected = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        H1.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        H2.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        H2CreatedBy.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        
        if let selectedDate = selectedDate,
           let date = Calendar.current.date(from: selectedDate) {
            datePicker.date = date
        }
        
        self.picker.delegate = self
        self.picker.dataSource = self
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let title = titleTextField.text, !title.isEmpty else { return }
        
        guard let notes = Notes.text, !notes.isEmpty else { return }
        
//        guard let roomie = Roomie.text, !roomie.isEmpty else { return }
        
        let roomie = roommates[indexSelected]

        let date = datePicker.date
        let event = Event(id: "", title: title, date: date, note: notes, roomie: roomie)

        delegate?.didCreateEvent(event)
    
//  navigationController?.popViewController(animated: true)
        
        let dateComp = Calendar.current.dateComponents([.year, .month, .day], from: date)
                
//        events[dateComp] = [event]
        
        
        
        NSLog("event added: \(events)")
//        sleep(2)
//        dismiss(animated: true)
        
        let db = Firestore.firestore()
        let docRef = db.collection("households").document(UserDefaults.standard.string(forKey: "householdID")!).collection("events").document()
        
        let eventData: [String: Any] = [
            "title": title,
            "date": date,
            "note": notes,
            "roomie": roomie
        ]
        
        docRef.setData(eventData) { error in
            if let error = error {
                print("Error adding chore: \(error.localizedDescription)")
            } else {
                print("Event added to Firestore.")
                let event = Event(id: docRef.documentID, title: title, date: date, note: notes, roomie: roomie)
                
                if self.events[dateComp] != nil {
                    self.events[dateComp]?.append(event)
                } else {
                    self.events[dateComp] = [event]
                }
                
//                self.dismiss(animated: true)
            }
        }
        
//        if events[dateComp] != nil {
//            events[dateComp]?.append(event)
//        } else {
//            events[dateComp] = [event]
//        }
        
    }
    
    //save is not unwinded - currently testing because event took longer to add and would only appear in events dict after segue happened
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CancelBack" || segue.identifier == "CancelUnwind" || segue.identifier == "AddUnwind" || segue.identifier == "AddBack" {
                let controller = segue.destination as? ViewController
                controller?.events = events
            }
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        indexSelected = row
    }
}
