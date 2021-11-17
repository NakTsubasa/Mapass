//
//  SearchBarViewController.swift
//  Mapass
//
//  Created by mac2 on 14/11/21.
//

import UIKit
import MapKit

class SearchBarViewController: UIViewController,MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var Buscador: UISearchBar!
    @IBOutlet weak var Mapa: MKMapView!
    // es un manager para hacer uso del GPS
    
    var manager = CLLocationManager()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Buscador.delegate = self
        manager.delegate = self
        
        Mapa.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
        
        
        //Mejorar la presicion de la ubicacion
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        //Monitorear la ubicacion
        manager.startUpdatingLocation()
        
        

        // Do any additional setup after loading the view.
    }
    
    @IBAction func typeMaps(_ sender: Any) {
        if (sender as AnyObject).selectedSegmentIndex == 0 {
            Mapa.mapType = MKMapType.hybrid
        } else if (sender as AnyObject).selectedSegmentIndex == 1 {
            Mapa.mapType = MKMapType.satellite
        } else if (sender as AnyObject).selectedSegmentIndex == 2 {
            Mapa.mapType = MKMapType.standard
        }
    }
    
    
    //MARK: - Trazar la ruta desde la ubicacion hasta el destino
    func trazarRuta(coordenadasDestino: CLLocationCoordinate2D){
        guard let coordOrigen = manager.location?.coordinate else {return}
        
        //Crear lugar de origen destino
        let origenPlaceMark = MKPlacemark(coordinate: coordOrigen)
        let destinoPlaceMark = MKPlacemark(coordinate: coordenadasDestino)
        
        //Crear un obj MapKit Item
        let origenItem = MKMapItem(placemark: origenPlaceMark)
        let destinoItem = MKMapItem(placemark: destinoPlaceMark)
        
        //solicitud de ruta
        let solicitudDestino = MKDirections.Request()
        solicitudDestino.source = origenItem
        solicitudDestino.destination = destinoItem
        
        //Como se va a viajar
        solicitudDestino.transportType = .walking
        solicitudDestino.requestsAlternateRoutes = true
        
        let direcciones = MKDirections(request: solicitudDestino)
        direcciones.calculate { (respuesta, error) in
            guard let respuestaSegura = respuesta else {
                if let error = error {
                    print("Error al calcular la ruta \(error.localizedDescription)")
                }
                return
            }
            //si se calculo la ruta
            print(respuestaSegura.routes.count)
            let ruta = respuestaSegura.routes[0]
            
            //agregar una supperposicion al mapa
            self.Mapa.addOverlay(ruta.polyline)
            self.Mapa.setVisibleMapRect(ruta.polyline.boundingMapRect, animated: true)
        }
    }//Fin de Trazar ruta
    
    //Metodo para mostrar la ruta encima del mapa
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderizado = MKPolylineRenderer(overlay: overlay as! MKMultiPolyline)
        renderizado.strokeColor = .cyan
        return renderizado
    }
    
    //MARK: - Metodos del CCLocationManager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Se obtuvo la ubicacion")
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error al obtener la ubicacion")
    }
}

extension SearchBarViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        Buscador.resignFirstResponder()
        
        let geocoder = CLGeocoder()
        
        if let direccion = Buscador.text{
            
            geocoder.geocodeAddressString(Buscador.text!) { (places: [CLPlacemark]?, error: Error?) in
                
                //Creamos el destino para la ruta
                guard let destinoRuta = places?.first?.location else {return}
                
                if error==nil{
                    //muestre la direccion
                    let place = places?.first
                    
                    let anotacion = MKPointAnnotation()
                    anotacion.coordinate = (place?.location?.coordinate)!
                    anotacion.title = self.Buscador.text
                    
                    let span = MKCoordinateSpan(latitudeDelta: 1.03, longitudeDelta: 1.01)
                    let region = MKCoordinateRegion (center: anotacion.coordinate, span: span)
                    self.Mapa.setRegion(region, animated: true)
                    self.Mapa.addAnnotation(anotacion)
                    self.Mapa.selectAnnotation(anotacion, animated: true)
                    
                    //MARK: - mandar a llamar a TrazarRuta
                    self.trazarRuta(coordenadasDestino: destinoRuta.coordinate)
                    
                }
                //muestre el e
                
            }
        }// fin de let direccion
        
        
    }
}
