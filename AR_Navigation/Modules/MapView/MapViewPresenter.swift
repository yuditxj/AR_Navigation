//
//  MapViewPresenter.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 10/1/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

class MapViewPresenter: NSObject, Presenter {
    typealias View = MapViewViewInput
    typealias Router = MapViewRouterInput
    typealias Interactor = MapViewInteractorInput
    
    var interactor: Interactor!
    var router: Router!
    weak var view: View!
    
    var state: MapState = .pin
    
}

extension MapViewPresenter: MapViewViewOutput {
    
    func viewDidLoad() {
        view.updateViews(for: state, animated: false)
        view.updateActions(with: MapState.actions(except: state))
        
        interactor.launchUpdatingLocationAndHeading()
    }
    
    func handleActionSelection(at index: Int) {
        state = MapState.actions(except: state)[index]
        view.updateViews(for: state, animated: true)
        view.updateActions(with: MapState.actions(except: state))
    }
    
    func handleGoAction() {
        view.endEditing()
    }
    
    func handleLocationAction() {
        guard let lastLocation = interactor.lastLocation else { return }
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: lastLocation.coordinate, span: span)
        
        view.mapView.setRegion(region, animated: true)
    }
}

extension MapViewPresenter: MapViewInteractorOutput {
    func handleLocationUpdate(newLocation: CLLocation, previous: CLLocation?) {
        if previous == nil {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: newLocation.coordinate, span: span)
            
            view.mapView.setRegion(region, animated: true)
        }
        
        //process with ar
    }
}

extension MapViewPresenter: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty { return }
        
        interactor.requestPlaces(for: searchText) { [weak self] (region, items) in
            guard let wSelf = self else { return }
            items.forEach { (item) in
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = item.placemark.coordinate
                annotation.title = item.placemark.name
                
                if let city = item.placemark.locality, let area = item.placemark.administrativeArea {
                    annotation.subtitle = city + ". " + area
                }
                
                wSelf.view.mapView.addAnnotation(annotation)
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
}


