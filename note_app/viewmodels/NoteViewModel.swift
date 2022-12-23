//
//  NoteViewModel.swift
//  note_app
//
//  Created by Mateo Valencia on 22/12/22.
//

import Foundation
import Flutter

class NoteViewModel{
   
    
    // Declaración de la variable delegada
    weak var noteFlutterViewModelToViewBinding: NoteFlutterViewModelToViewBinding?
    
    // Declaración del FlutterMethodChannel
    private var addNewNoteFlutterMethodChannel: FlutterMethodChannel?
    
    // Declaración del addNewNoteFlutterViewController
    private var addNewNoteFlutterViewController: FlutterViewController?
    
    // Le asignamos a nuestra lista de notas el valor de UserDefaults
    var  noteModelList: [String] = UserDefaults.standard.stringArray(forKey: "notes") ?? []
    
    // inyectamos las depedencias de noteFlutterViewModelToViewBinding y addNewNoteFlutterViewController en el método init
    init(noteFlutterViewModelToViewBinding : NoteFlutterViewModelToViewBinding? = nil,
         addNewNoteFlutterViewController: FlutterViewController?){
        self.noteFlutterViewModelToViewBinding = noteFlutterViewModelToViewBinding
        self.addNewNoteFlutterViewController = addNewNoteFlutterViewController
        // registramos nuestro FlutterMethodChannel
         registerFlutterMethodChannel()
     }
    
    // Método para registrar nuestro FlutterMethodChannel
    private func registerFlutterMethodChannel(){
        
        guard let addNewNoteFlutterControllerBinaryMessenger = self.addNewNoteFlutterViewController?.binaryMessenger else {return}
        
        self.addNewNoteFlutterMethodChannel = FlutterMethodChannel(name: "notes", binaryMessenger: addNewNoteFlutterControllerBinaryMessenger)

        self.getMethodHandlerForAddNewNoteFlutterViewController()
        
    }
    
    // Convertimos nuestra nota a un JSON
    private func convertNoteModelToJson(_ noteModel: NoteModel) -> Data {
        return try! JSONEncoder().encode(noteModel)
        
    }
    
    // Convertimos nuestro Nota JSON a un Nota JSON String
    func convertJSONToString(_ noteModelJSON: Data) -> String {
        return String(decoding: noteModelJSON, as: UTF8.self)
        
    }
    
    // Convertimos nuestra Nota JSON String a Nota JSON
    func convertStringToJSON(_ noteModelString: String) -> Data {
        return noteModelString.data(using: .utf8)!
        
    }
    
    // Convertimos nuestra Nota JSON a una lista de NoteModel
    func convertJSONToNotes(json: Data) -> [NoteModel]? {
      let decoder = JSONDecoder()
        do {
        let notes = try decoder.decode([NoteModel].self, from: json)
        return notes
      } catch {
        print("Error converting JSON to notes: \(error.localizedDescription)")
        return nil
      }
    }
    
    // Añadimos nuestra nota a nuestra lista de notas
    func addNotes(noteModel: NoteModel) -> Void {
        let noteModelJSON = convertNoteModelToJson(noteModel)
        let noteModelJSONString = convertJSONToString(noteModelJSON)
        noteModelList.append(noteModelJSONString)
        (UIApplication.shared.delegate as! AppDelegate).defaults.set(noteModelList, forKey: "notes")
        
    }
    
    // Convertimos nuestra lista de notas json String a un arreglo de nota JSON
    func convertToJSONArray(_ jsonStrings: [String]) -> [Any] {
        return try! jsonStrings.map { jsonString in
            let jsonData = jsonString.data(using: .utf8)!
            return try JSONSerialization.jsonObject(with: jsonData, options: [])
            
        }
    }
    
    // Convertimos nuestro arreglo de nota JSON a NotaModel
    func convertToNoteModelArray(_ jsonArray: [Any]) -> [NoteModel] {
        return jsonArray.map { json in
           guard
             let jsonDict = json as? [String: Any],
             let title = jsonDict["noteTitle"] as? String,
             let description = jsonDict["noteDescription"] as? String
           else {
             // Tratamos el error
               return NoteModel(noteTitle: "", noteDescription: "")
           }

            return NoteModel(noteTitle: title, noteDescription: description)
         }
    }
    
    // Leamos nuestra lista de notas
    func readNotes() -> [NoteModel]? {
        let notesJSON = convertToJSONArray(noteModelList)
        return convertToNoteModelArray(notesJSON)
    }
    
    // Contamos la cantidad de notas
    func countData() -> Int? {
        if let data = readNotes() {
            return data.count
        }
        return 0
    }
    
    // Convertimos nuestra nota json String a NoteModel
    func convertToNote(noteJSONString: String) -> NoteModel? {
        if let noteJSON = noteJSONString.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: noteJSON, options: [])
                if let jsonDict = json as? [String: String] {
                    let title = jsonDict["noteTitle"]
                    let description = jsonDict["noteDescription"]
                    return NoteModel(noteTitle: title, noteDescription: description)
                }
            } catch {
                print("Error converting JSON to a dictionary")
            }
        }
        return nil
    }
    
    // Método para tratar los diferentes métodos del flutter method channel
    private func getMethodHandlerForAddNewNoteFlutterViewController(){
        // Obtenemos el setMethodCallHandler de nuestro Flutter Controller
        self.addNewNoteFlutterMethodChannel?.setMethodCallHandler({
            // El resultado de la llamada al método lo tratamos dependiendo el método que se invoque
            (flutterMethodCall:FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            switch flutterMethodCall.method {
                // Invocamos al método sendNote
            case "sendNote":
                // tomamos el resultado
                guard let result = flutterMethodCall.arguments else {return}
                // valor del diccionario que llega en el resultado
                let noteDict = result as? [String: Any]
                // convertimos a note json String
                let noteJSONString = noteDict?["text"] as? String
                // convertimos a NoteModel
                let note = self.convertToNote(noteJSONString: noteJSONString ?? "")
                // añadimos la nota a nuestra lista de notas
                self.addNotes(noteModel: note ?? NoteModel(noteTitle: "", noteDescription: ""))
                // llamamos a nuestro delegado para regresar a NoteViewController
                self.noteFlutterViewModelToViewBinding?.noteFlutterViewModel(didBackPressed: true)
            default:
                // en caso de no existir ningún método retornamos FlutterMethodNotImplemented
                result(FlutterMethodNotImplemented)
                
            }
        })
    }
    
}

// MARK: Protocolos
protocol NoteFlutterViewModelToViewBinding: AnyObject {
    
    // Método para regresar a NoteViewController
    func noteFlutterViewModel(didBackPressed value: Bool)
}

