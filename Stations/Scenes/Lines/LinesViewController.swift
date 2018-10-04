//
//  LinesViewController.swift
//  Stations
//
//  Created by Ahmed Ibrahim on 10/3/18.
//  Copyright © 2018 Me. All rights reserved.
//

import UIKit

protocol LinesDisplayLogic {
    func display(lines: [Line])
}

protocol LinesViewControllerDelegate: class {
    func linesViewController(_ linesViewController: LinesViewController, didSelect line: Line)
    func linesViewControllerDidLoadLines(_ linesViewController: LinesViewController)
}

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
}
