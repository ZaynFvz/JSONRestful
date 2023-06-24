//
//  ViewControllerEditarPerfil.swift
//  JSONRESTful
//
//  Created by Gonzalo Vargas on 23/06/23.
//

import UIKit

class EditarPerfilViewController: UIViewController {
    
    @IBOutlet weak var txtNombre: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtClave: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        if let nombre = defaults.string(forKey: "nombre"),
           let clave = defaults.string(forKey: "clave"),
           let email = defaults.string(forKey: "email"){
            txtNombre.text = nombre
            txtEmail.text = email
            txtClave.text = clave
        }
    }
    
    @IBAction func btnGuardarCambios(_ sender: Any) {
        
        guard let userID = UserDefaults.standard.string(forKey: "userID") else {
            return
        }
        
        guard let nombre = txtNombre.text,
              let email = txtEmail.text,
              let clave = txtClave.text else{
                  return
              }
        
        let datos = ["nombre": nombre, "clave": clave, "email": email] as [String: Any]
        let ruta = "http://localhost:3000/usuarios/\(userID)"
        metodoPUT(ruta: ruta, datos: datos)
        navigationController?.popViewController(animated: true)
    }
    
    func metodoPUT(ruta: String, datos: [String: Any]) {
        guard let url = URL(string: ruta) else {
            print("URL inválida: \(ruta)")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: datos, options: [])
        } catch {
            print("Error al serializar los datos: \(error)")
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error al realizar la solicitud: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Respuesta HTTP inválida")
                return
            }
            
            if httpResponse.statusCode == 200 {
                print("Datos actualizados con éxito !!")
            } else {
                print("Error al actualizar los datos del usuario. Código de respuesta HTTP: \(httpResponse.statusCode)")
            }
        }
        
        task.resume()
    }

    
}
