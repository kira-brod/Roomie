

import UIKit
import Darwin
import FirebaseFirestore

protocol EventCreationDelegate: AnyObject {
    func didCreateEvent(_ event: Event)
}

class AddEventViewController: UIViewController {
    
    let db = Firestore.firestore()

    weak var delegate: EventCreationDelegate?

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var Notes: UITextField!
    
    @IBOutlet weak var Roomie: UITextField!
    var events: [DateComponents: [Event]] = [:]

    @IBOutlet weak var H1: UILabel!
    @IBOutlet weak var H2: UILabel!
    
    @IBOutlet weak var H2CreatedBy: UILabel!
    
    var selectedDate: DateComponents?

    override func viewDidLoad() {
        super.viewDidLoad()

        H1.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        H2.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        H2CreatedBy.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        
        if let selectedDate = selectedDate,
           let date = Calendar.current.date(from: selectedDate) {
            datePicker.date = date
        }
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let title = titleTextField.text, !title.isEmpty else { return }
        
        guard let notes = Notes.text, !notes.isEmpty else { return }
        
        guard let roomie = Roomie.text, !roomie.isEmpty else { return }

        let date = datePicker.date
        let event = Event(id: "", title: title, date: date, note: notes, roomie: roomie)

        delegate?.didCreateEvent(event)
    
//  navigationController?.popViewController(animated: true)
        
        let dateComp = Calendar.current.dateComponents([.year, .month, .day], from: date)
                
//        events[dateComp] = [event]
        
        if events[dateComp] != nil {
            events[dateComp]?.append(event)
        } else {
            events[dateComp] = [event]
        }
        
        NSLog("event added: \(events)")
//        sleep(2)
//        dismiss(animated: true)
        
        let db = Firestore.firestore()
        let docRef = db.collection("events").document()
        
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
                
//                self.dismiss(animated: true)
            }
        }
        
    }
    
    //save is not unwinded - currently testing because event took longer to add and would only appear in events dict after segue happened
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CancelBack" || segue.identifier == "CancelUnwind" || segue.identifier == "AddUnwind" || segue.identifier == "AddBack" {
                let controller = segue.destination as? ViewController
                controller?.events = events
            }
    }
}
