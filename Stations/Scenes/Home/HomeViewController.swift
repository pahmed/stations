//
//  HomeViewController.swift
//  Stations
//
//  Created by Ahmed Ibrahim on 10/3/18.
//  Copyright © 2018 Me. All rights reserved.
//

import UIKit
import GoogleMaps
import RxSwift

protocol HomeDisplayLogic {
    
}

class HomeViewController: UIViewController {

    private var mapView: GMSMapView!
    private var disposeBag = DisposeBag()
    
    lazy var interactor: HomeBusinessLogic = {
        return HomeInteractor(presenter: HomePresenter(displayer: self))
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupMapView()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case .some("lines"):
            (segue.destination as! LinesViewController).delegate = self
            
        default:
            fatalError("unhandled segue")
        }
    }
    
    // MARK: - Private
    
    private func setupMapView() {
        mapView = GMSMapView(frame: CGRect.zero)
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(mapView, at: 0)
        
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        mapView.delegate = self
    }

}

// MARK: - DisplayLogic

extension HomeViewController: HomeDisplayLogic {
    
}

// MARK: - GMSMapViewDelegate

extension HomeViewController: GMSMapViewDelegate {
    
}

// MARK: - LinesViewControllerDelegate

extension HomeViewController: LinesViewControllerDelegate {
    func linesViewController(_ linesViewController: LinesViewController, didSelect line: Line) {
        
    }
}
