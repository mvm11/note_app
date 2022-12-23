//
//  ViewController.swift
//  note_app
//
//  Created by Mateo Valencia on 21/12/22.
//

import UIKit
import Flutter

class NoteViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var noteTableView: UITableView!
    
    // MARK: ViewModels
     var noteViewModel: NoteViewModel?
     
     // MARK: Flutter Variables
     var addNewNoteFlutterEngine: FlutterEngine?
     var addNewNoteFlutterViewController: FlutterViewController?
    
    // MARK: Ciclo de vida de la aplicación
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Actualizamos el valor de nuestra lista de notas cada vez que volvamos al controlador noteViewModel
        noteViewModel?.noteModelList = UserDefaults.standard.stringArray(forKey: "notes") ?? []
        
        // Asignamos el valor de nuestra addNewNoteFlutterEngine
        addNewNoteFlutterEngine = setAddNewNoteFlutterEngine()
        
        // Creamos una variable local para nuestra flutter engine
        guard let addNewNoteFlutterEngineLocal = addNewNoteFlutterEngine else {return}
        
        // Asignamos el valor de nuestro addNewNoteFlutterViewController
        addNewNoteFlutterViewController = setAddNewNoteFlutterViewController(addNewNoteFlutterEngineLocal)
        setDelegates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Actualizamos el valor de nuestra lista de notas cada vez que volvamos al controlador principal
        noteViewModel?.noteModelList = UserDefaults.standard.stringArray(forKey: "notes") ?? []
        // Actualizamos nuestra tabla
        noteTableView.reloadData()
    }
    
    // MARK: Métodos para asignar delegados
    
    fileprivate func setDelegates() {
        // Le indicamos al noteTableView.delegate que su delegado se encuentra en esta clase
        noteTableView.delegate = self
        // Le indicamos al noteTableView.dataSource que su delegado se encuentra en esta clase
        noteTableView.dataSource = self
        // Inicializamos el noteFlutterViewModel
        noteViewModel = NoteViewModel(noteFlutterViewModelToViewBinding: self, addNewNoteFlutterViewController: addNewNoteFlutterViewController)
    }
    
    // MARK: Métodos de configuración de Flutter
    
    // método para asignar el flutter engine
    fileprivate func setAddNewNoteFlutterEngine() -> FlutterEngine {
        return (UIApplication.shared.delegate as! AppDelegate).engines.makeEngine(withEntrypoint: "addNewNoteFlutter", libraryURI: nil)
    }
    
    // método para asignar el flutter controller
    fileprivate func setAddNewNoteFlutterViewController(_ addNewNoteFlutterEngineLocal: FlutterEngine) -> FlutterViewController {
        return FlutterViewController(engine: addNewNoteFlutterEngineLocal, nibName: nil, bundle: nil)
    }
    
    
    // MARK: IBActions
    @IBAction func addNote(_ sender: Any) {
        
        // Creamos una variable segura de nuestro addNewNoteFlutterViewController para no romper nuestra aplicación en caso tal de que llegue nula
        guard let addNewNoteFlutterViewControllerLocal = addNewNoteFlutterViewController else {return}
        
        // Abre nuestro addNewNoteFlutterViewController para crear una nueva nota desde flutter
        self.navigationController?.pushViewController(addNewNoteFlutterViewControllerLocal, animated: true)
    }
    
}

// MARK: Métodos delegados de TableView

extension NoteViewController: UITableViewDelegate, UITableViewDataSource{
    // Método para indicarle a nuestro TableView el tamaño de nuestra lista
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noteViewModel?.countData() ?? 0
    }
    
    // Método para pintar cada una de nuestras notas

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let noteCell = noteTableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath) as! NoteTableViewCell
        
        let note = noteViewModel?.readNotes()![indexPath.row]
        
        noteCell.noteTitle.text = note?.noteTitle
        noteCell.noteDescription.text = note?.noteDescription
        return noteCell
    }
    
    // Método para crear Swipe Actions en nuestra TableView
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // Creamos un nuevo botón para eleminar nuestras notas
        let deleteButton = UIContextualAction(style: .destructive, title: "Delete"){ (_, _, _) in
            
            // Eliminamos la nota
            self.noteViewModel?.noteModelList.remove(at: indexPath.row)
            // Actualizamos nuestra lista de notas
            UserDefaults.standard.set(self.noteViewModel?.noteModelList, forKey: "notes")
            // Actualizamos nuestra tabla
            tableView.reloadData()
        }
        
        // Retornamos la lista de botones que hemos creado
        return UISwipeActionsConfiguration(actions: [deleteButton])
    }
    
    // Método para editar notas
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        // Extraemos el json String con su respectiva posición en nuestra lista de notas
        let noteJSONString = noteViewModel?.noteModelList[indexPath.row]
        // Convertimos nuestro json String a una nota
        let note = noteViewModel?.convertToNote(noteJSONString: noteJSONString ?? "")
        
        // Creamos una instancia de nuestro editNoteViewController
        guard let editNoteViewController = storyboard?.instantiateViewController(withIdentifier: "EditNoteViewController") as? EditNoteViewController else { return  }
        
        // Le pasamos la nota a nuestro controlador
        editNoteViewController.note = note
        // Le pasamos la posición de la nota a nuestro controlador
        editNoteViewController.notePosition = indexPath.item
        
        // Nos dirigimos a nuestro editNoteViewController
        self.navigationController?.pushViewController(editNoteViewController, animated: true)
    
    }
    
    
}

// MARK: Métodos delegados de NoteFlutterViewModelToViewBinding
extension NoteViewController: NoteFlutterViewModelToViewBinding {
    
    // Método para devolvernos desde nuestro addNewNoteFlutterViewController a nuestro NoteViewcontroller
    func noteFlutterViewModel(didBackPressed value: Bool) {
        // Cuando el parámetro value sea verdadero volveremos a nuestro NoteViewcontroller
        self.navigationController?.popViewController(animated: true)
    }
    
}

