//
//  ViewControllerBuscar.swift
//  JSONRESTful
//
//  Created by Gonzalo Vargas on 21/06/23.
//

import UIKit

class ViewControllerBuscar: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var peliculas = [Peliculas]()
    
    @IBOutlet weak var txtBuscar: UITextField!
    @IBOutlet weak var tablaPeliculas: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tablaPeliculas.delegate = self
        tablaPeliculas.dataSource = self
        
        let ruta = "http://localhost:3000/peliculas"
        cargarPeliculas(ruta: ruta){
            self.tablaPeliculas.reloadData()
        }
    }
    
    @IBAction func btnSalir(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnBuscar(_ sender: Any) {
        let ruta = "http://localhost:3000/peliculas?"
        let nombre = txtBuscar.text!
        let url = ruta + "nombre_like=\(nombre)"
        let crearURL = url.replacingOccurrences(of: " ", with: "%20")
        
        if nombre.isEmpty{
            let ruta = "http://localhost:3000/peliculas"
            self.cargarPeliculas(ruta: ruta){
                self.tablaPeliculas.reloadData()
            }
        }else{
            cargarPeliculas(ruta: crearURL){
                if self.peliculas.count <= 0 {
                    self.mostrarAlerta(titulo: "Error", mensaje: "No se encontraron coincidencias para: \(nombre)", accion: "Cancelar")
                }else{
                    self.tablaPeliculas.reloadData()
                }
            }
        }
    }
    
    
    func cargarPeliculas(ruta:String, completed: @escaping()->()){
        let url = URL(string: ruta)
        URLSession.shared.dataTask(with: url!) { (data,response,error) in
            if error == nil {
                do{
                    self.peliculas = try JSONDecoder().decode([Peliculas].self, from: data!)
                    DispatchQueue.main.async {
                        completed()
                    }
                }catch{
                    print("ERROR EN JSON")
                }
            }
        }.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peliculas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "\(peliculas[indexPath.row].nombre)"
        cell.detailTextLabel?.text = "Genero:\(peliculas[indexPath.row].genero) Duracion:\(peliculas[indexPath.row].duracion)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pelicula = peliculas[indexPath.row]
        performSegue(withIdentifier: "segueEditar", sender: pelicula)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            mostrarAlertaEliminarPelicula(index: indexPath.row)
        }
    }
    
    func mostrarAlerta(titulo: String, mensaje:String, accion:String){
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let btnOK = UIAlertAction(title: accion, style: .default, handler: nil)
        alerta.addAction(btnOK)
        present(alerta, animated: true, completion: nil)
    }
    
    func mostrarAlertaEliminarPelicula(index: Int) {
        let pelicula = peliculas[index]
        let alerta = UIAlertController(title: "Eliminar Película", message: "¿Estás seguro de que deseas eliminar la película '\(pelicula.nombre)'?", preferredStyle: .alert)
        
        let eliminarAccion = UIAlertAction(title: "Si, estoy seguro", style: .destructive) { (_) in
            self.eliminarPelicula(index: index)
        }
        let cancelarAccion = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alerta.addAction(eliminarAccion)
        alerta.addAction(cancelarAccion)
        
        present(alerta, animated: true, completion: nil)
    }
    
    func eliminarPelicula(index: Int) {
        let pelicula = peliculas[index]
        let ruta = "http://localhost:3000/peliculas/\(pelicula.id)"
        
        guard let url = URL(string: ruta) else {
            print("URL inválida")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error al eliminar la película:", error.localizedDescription)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    self.peliculas.remove(at: index)
                    self.tablaPeliculas.reloadData()
                }
            } else {
                print("Error al eliminar la película. Código de respuesta HTTP inválido.")
            }
        }.resume()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        let ruta = "http://localhost:3000/peliculas"
        cargarPeliculas(ruta: ruta){
            self.tablaPeliculas.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueEditar"{
           let siguienteVC = segue.destination as! ViewControllerAgregar
           siguienteVC.pelicula = sender as? Peliculas
        }
    }
}
