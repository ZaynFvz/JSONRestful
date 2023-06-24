//
//  ViewController.swift
//  JSONRESTful
//
//  Created by Gonzalo Vargas on 21/06/23.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var txtUsuario: UITextField!
    @IBOutlet weak var txtContraseña: UITextField!
    var users = [Users]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func validarUsuario(ruta:String, completed: @escaping() ->()){
        let url = URL(string: ruta)
        URLSession.shared.dataTask(with: url!) { (data,response,error) in
            if error == nil{
                do{
                    self.users = try JSONDecoder().decode([Users].self, from: data!)
                    DispatchQueue.main.async {
                        completed()
                    }
                }catch{
                    print("ERROR EN JSON")
                }
            }
        }.resume()
    }
    
    @IBAction func logear(_ sender: Any) {
        let ruta = "http://localhost:3000/usuarios?"
        let usuario = txtUsuario.text!
        let contraseña = txtContraseña.text!
        let url = ruta + "nombre=\(usuario)&clave=\(contraseña)"
        let crearURL = url.replacingOccurrences(of: " ", with: "%20")
        validarUsuario(ruta: crearURL){
            if self.users.count <= 0{
                print("Nombre de usuario y/o contraseña incorrectos")
            }else{
                print("LOGEO EXITOSO")
                
                let defaults = UserDefaults.standard
                let usuario = self.users[0]
                defaults.set(usuario.id, forKey: "userID")
                defaults.set(usuario.nombre, forKey: "nombre")
                defaults.set(usuario.clave, forKey: "clave")
                defaults.set(usuario.email, forKey: "email")
                
                self.performSegue(withIdentifier: "segueLogeo", sender: nil)
                for data in self.users{
                    print("id:\(data.id), nombre:\(data.nombre), email:\(data.email)")
                }
            }
        }
    }
}

