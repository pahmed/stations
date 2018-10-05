//
//  LinesViewController.swift
//  Stations
//
//  Created by Ahmed Ibrahim on 10/3/18.
//  Copyright © 2018 Me. All rights reserved.
//

import UIKit

/// A protocol the defines the display logic abilities for a displayer.
/// A displayer is responsible for displaying the view models it gets from
/// a presenter, also responsible for passing the user events in form of command
/// to the interactor to run the business logic
protocol LinesDisplayLogic {
    
    /// Displays a horizontal list of bus lines
    ///
    /// - Parameter lines: The lines to be presented
    func display(lines: [Line])
    
    /// Displays an alert with the given title and message
    ///
    /// - Parameters:
    ///   - title: The alert title
    ///   - message: The alert body
    func displayAlert(title: String, message: String)
}


/// The delegate of LinesViewController must conform to LinesViewControllerDelegate.
/// The LinesViewController call the delegate to inform it about some updates the delegate object is
/// interested in
protocol LinesViewControllerDelegate: class {
    
    /// The method that is called on selecing a specific line
    ///
    /// - Parameters:
    ///   - linesViewController: The delegating object
    ///   - line: The selected line
    func linesViewController(_ linesViewController: LinesViewController, didSelect line: Line)
    
    /// A method that is called on loading the list of line from an API
    ///
    /// - Parameter linesViewController: The delegating object
    func linesViewControllerDidLoadLines(_ linesViewController: LinesViewController)
}

/// A class that is responsible for rendering the list of Lines
class LinesViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var delegate: LinesViewControllerDelegate?
    
    lazy var interactor: LinesBusinessLogic = {
        return LinesInteractor(presenter: LinesPresenter(displayer: self))
    }()
    
    private var lines: [Line] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        interactor.loadLines()
    }

}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension LinesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lines.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! LineCollectionViewCell
        
        let line = lines[indexPath.row]
        cell.configureWith(title: line.name, description: "Smart Village description")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.linesViewController(self, didSelect: lines[indexPath.row])
    }
}

// MARK: - DisplayLogic
extension LinesViewController: LinesDisplayLogic {
    func display(lines: [Line]) {
        self.delegate?.linesViewControllerDidLoadLines(self)
        self.lines = lines
        collectionView.reloadData()
    }
    
    func displayAlert(title: String, message: String) {
        Alert(title: title, message: message)
            .addCancelAction()
            .show(in: self)
    }
}
