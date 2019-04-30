//
//  CollageTableViewController.swift
//  PhotoCollage
//
//  Created by vit on 4/22/19.
//  Copyright © 2019 vit. All rights reserved.
//

import UIKit
import Netvit

// main table controller, with triple photo in a row
class CollageCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    private let photoStoreClass = PhotoStorage()
    private var pageNumber = 1
    private let resultsTableView = ResultsTableViewController()
    private var searchController: UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()
        // set up search controller
        setUpSearchController()
        // call refresh control
        refreshDataControl()
        // call getPhoto func
        getPhoto()
    }
    
    // define getPhoto func
    @objc private func getPhoto() {
        // if pages not over
        if pageNumber <= 10 {
            Netvit.getPhotos(onPage: pageNumber, withLimit: 30) { result in
                
                switch result {
                case .success(let receivedPhotos):
                    self.photoStoreClass.storagePhoto += receivedPhotos
                    self.pageNumber += 1
                case .failure( _ ):
                    // if data not received
                    self.alert(withTitle: "Data not received!", withMessage: "Try pull down to refresh.", titleForActionButton: "Ok")
                }
                
                // stop refresh control
                self.collectionView.refreshControl?.endRefreshing()
                self.collectionView.reloadData()
            }
        } else {
            // if pages is over
            alert(withTitle: "No more photos!", withMessage: "", titleForActionButton: "Ok")
        }
    }

    // receive new page
    private func receiveNewPage() {
        getPhoto()
    }
    
    // set up search controller
    private func setUpSearchController() {
        searchController = UISearchController(searchResultsController: resultsTableView)
        searchController.searchResultsUpdater = resultsTableView
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    // set up pull-to-refresh
    private func refreshDataControl() {
        // clearing old photos before refreshing
        photoStoreClass.clearStoragePhoto()
        // set refreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = #colorLiteral(red: 0.3098039329, green: 0.2039215714, blue: 0.03921568766, alpha: 1)
        refreshControl.addTarget(self, action: #selector(getPhoto), for: UIControl.Event.valueChanged)
        collectionView.refreshControl = refreshControl
    }

    // set up alert handler
    private func alert(withTitle title: String, withMessage message: String, titleForActionButton buttonTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Table view data source
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoStoreClass.storagePhoto.count
    }

    // cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let multiplier: CGFloat = UIDevice.current.modelName == "iPhone 5" ? 0.1 : 0.08
        let interSpacing = view.frame.width * multiplier
        let cellWidth = (view.frame.width - interSpacing * 2) / 3
        return .init(width: cellWidth, height: cellWidth + 20)
    }

    // cell paddings
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let leftRightPadding = view.frame.width * 0.05
        return .init(top: 10, left: leftRightPadding, bottom: 10, right: leftRightPadding)
    }
    
    // reuse cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollageCollectionViewCell
        cell.updateCollectionViewCell(withUrl: photoStoreClass.storagePhoto[indexPath.row].urls.small)
        cell.delegate = self
        return cell
    }

    // pagination pages
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == photoStoreClass.storagePhoto.count - 1 {
            receiveNewPage()
        }
    }

    
    // MARK: — ZOOM STAFF
    //----------------------------------------
    private var basicFrame: CGRect?
    private var grayBackgroundView: UIView?
    private var basicImageView: UIImageView?
    
    // realized zoom logic
    func performZoomForImageView(_ basicImageView: UIImageView) {
        
        self.basicImageView = basicImageView
        basicImageView.isHidden = true
        // determine photo size and position
        basicFrame = basicImageView.superview?.convert(basicImageView.frame, to: nil)
        
        // create and set up zoomingView from basicFrame
        let zoomingView = UIImageView(frame: basicFrame!)
        zoomingView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        zoomingView.image = basicImageView.image
        zoomingView.isUserInteractionEnabled = true
        zoomingView.contentMode = .scaleAspectFill
        zoomingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        // created and setting new window from main window
        if let keyWindow = UIApplication.shared.keyWindow {
            grayBackgroundView = UIView(frame: keyWindow.frame)
            grayBackgroundView?.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            grayBackgroundView?.alpha = 0
            keyWindow.addSubview(grayBackgroundView!)
            keyWindow.addSubview(zoomingView)
            
            // animete window under zoom photo
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.grayBackgroundView?.alpha = 1
                zoomingView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: self.basicFrame!.height)
                zoomingView.center = keyWindow.center
            }, completion: nil)
        }
    }
    
    // handling zoom out
    @objc private func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        
        if let zoomOutImageView = tapGesture.view {
            // animated zoom out
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                // zoom-frame reverse taked form-size of basic-frame
                zoomOutImageView.frame = self.basicFrame!
                self.grayBackgroundView?.alpha = 0
            }) { (completed: Bool) in
                // removed zoom-frame until next time
                zoomOutImageView.removeFromSuperview()
                self.basicImageView?.isHidden = false
            }
        }
    }
    

}
