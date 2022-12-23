//
//  EditNoteViewController.swift
//  note_app
//
//  Created by Mateo Valencia on 22/12/22.
//

import UIKit

class EditNoteViewController: UIViewController {
    

    
    // MARK: IBOutlets
    @IBOutlet weak var noteTitleTextField: UITextField!
    @IBOutlet weak var noteDescriptionTextField: UITextField!
    
    // MARK: Variables de NoteViewController
    var note: NoteModel?
    var notePosition: Int?
    
    // MARK: Variables Delegadas
    var editNoteDelegate: EditNoteDelegate?
    
    // MARK: ViewModels
    var noteViewModel: NoteViewModel?
    
    // MARK: Ciclo de vida de la aplicación
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setDelegates()
        noteTitleTextField.text = note?.noteTitle ?? ""
        noteDescriptionTextField.text = note?.noteDescription ?? ""
    }
    
    // MARK: IBActions
    // Método para editar notas
    @IBAction func editNote(_ sender: Any) {
        // asignamos el títutlo de la nota
        let noteTitle = noteTitleTextField.text
        // asignamos la descripción de la nota
        let noteDescription = noteDescriptionTextField.text
        // creamos un nueva instancia de NoteModel
        let note = NoteModel(noteTitle: noteTitle, noteDescription: noteDescription)
        // eliminamos la nota editada
        noteViewModel?.noteModelList.remove(at: notePosition!)
        // añadimos nuestra nueva nota
        noteViewModel?.addNotes(noteModel: note)
        // Nos regresamos a nuestro NoteViewController
        self.navigationController?.popViewController(animated: true)
        
    }
    
    // MARK: Métodos para asignar delegados
    fileprivate func setDelegates() {
        editNoteDelegate = self
        noteViewModel = NoteViewModel(noteFlutterViewModelToViewBinding: nil, addNewNoteFlutterViewController: nil)
    }
}
    
// MARK: Métodos delegados de EditNoteViewController
extension EditNoteViewController: EditNoteDelegate{
    func noteFlutterViewModel(didGetNote value: NoteModel) {
        
    }
    
}
// MARK: Protocolos
protocol EditNoteDelegate: AnyObject {
    func noteFlutterViewModel(didGetNote value: NoteModel)
    
}

