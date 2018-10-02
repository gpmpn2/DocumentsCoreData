//
//  DocumentsTableViewController.swift
//  Documents
//
//  Created by Grant Maloney on 8/26/18.
//  Copyright © 2018 Grant Maloney. All rights reserved.
//

import UIKit
import CoreData

class DocumentsTableViewController: UITableViewController {
    
    var notes = [Note]()
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Document")
    var documents = [NSManagedObject]()
    @IBAction func addButton(_ sender: Any) {
        self.performSegue(withIdentifier: "moveToNotepad", sender: nil)
    }
    @IBOutlet weak var addButtonItem: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadNotes()
        
        self.navigationItem.rightBarButtonItem = addButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadNotes()
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        if let cell = cell as? CustomTableViewCell {

            let note = notes[indexPath.row]

            cell.noteTitle.text = note.title
            cell.noteSize.text = note.sizeString
            cell.dateModified.text = note.dateModifiedString
        }

        return cell
    }
    
    func loadNotes(){
        //This should probably be set into a model object somewhere
        request.returnsObjectsAsFaults = false
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let (myNotes, myDocuments) = Note.loadNotes(request: request, context: managedContext)
        
        notes = myNotes
        documents = myDocuments
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? NotePadViewController {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let selectedRow = indexPath.row
                destination.viewingNote = self.notes[selectedRow]
                destination.viewingData = self.documents[selectedRow]
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "moveToNotepad", sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            managedContext.delete(documents[indexPath.row])
            
            notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            do {
                try managedContext.save()
            } catch {
                print("Failed to save!")
            }
        }
    }
}
