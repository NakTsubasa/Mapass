//
//  ViewController.swift
//  Mapass
//
//  Created by mac2 on 09/11/21.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var manager = CLLocationManager()
    var latitud: CLLocationDegrees?
    var longitud: CLLocationDegrees?

    @IBOutlet weak var Mapa: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Delegados
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.stopUpdatingLocation()// comenzar a actualizar la ubicacion del GPS
        
    }
    
    
    @IBAction func verCoordenadasBtn(_ sender: UIBarButtonItem) {
        let alerta = UIAlertController(title: "Tus Coordenadas", message: "Estas son tus coordenadas XD: Lat:\(self.latitud) Long:\(self.longitud)", preferredStyle: .alert)
        let accionAceptar = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
        let accionMostrar = UIAlertAction(title: "Mostrar", style: .default){(_) in
            //acercar la vista del mapa
            let localización = CLLocationCoordinate2DMake(self.latitud!, self.latitud!)
            let spam = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: localización, span: spam)
            self.Mapa.setRegion(region, animated: true)
            self.Mapa.showsUserLocation	= true
        }
        alerta.addAction(accionAceptar)
        alerta.addAction(accionMostrar)
        present(alerta, animated: true, completion: nil)
    }
    
    //MARK: - Obtener las cordenadas del GPS
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            self.latitud = location.coordinate.latitude
            self.longitud = location.coordinate.longitude
            
        }
    }

}

