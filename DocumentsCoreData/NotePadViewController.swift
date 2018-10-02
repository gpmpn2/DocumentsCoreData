//
//  NotePadViewController.swift
//  Documents
//
//  Created by Grant Maloney on 8/26/18.
//  Copyright © 2018 Grant Maloney. All rights reserved.
//

import UIKit
import CoreData

class NotePadViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    var viewingNote: Note?
    var isEdited: Bool = false
    var viewingData: NSManagedObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let note = viewingNote {
            contentTextView.text = note.content
            titleTextField.text = note.title
            self.navigationItem.title = note.title
            isEdited = true
        } else {
            contentTextView.text = ""
            titleTextField.text = ""
            isEdited = false
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(self.saveNote))
        
        titleTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc
    func saveNote() {
        if titleTextField.text == "" {
            print("Error, empty text field!")
            return
        }
        
        if contentTextView.text == "" {
            print("Error, empty text view!")
            return
        }
        
        if let title = titleTextField.text {
            let note: Note = Note(title: title, size: contentTextView.text.utf8.count, dateModified: Date(), content: contentTextView.text)
            note.saveNote(isEdited: isEdited, viewingData: viewingData)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc
    func textFieldDidChange() {
        self.navigationItem.title = titleTextField.text
    }
}
