//
//  OffersViewController.swift
//  Project
//
//  Created by Alex Kovalov on 2/8/17.
//  Copyright © 2017 Requestum. All rights reserved.
//

import Foundation
import UIKit

import MBProgressHUD

class OffersViewController: BaseViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var tableView: UITableView!
    
    var offers: [Offer] = []
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 14))
        
        let nib =  UINib(nibName: String(describing: OfferTableViewCell.self), bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: String(describing: OfferTableViewCell.self))
        
        getOffers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNavigationBarTheme(theme: .green)
    }
    
    
    // MARK: Actions
}


// MARK: UITableViewDelegate & UITableViewDataSource

extension OffersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return offers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: OfferTableViewCell.self)) as! OfferTableViewCell
        cell.showDate = false
        cell.offer = offers[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = UIStoryboard.instantiateViewControllerWithIdentifier(type: .offer, identifier: String(describing: OfferViewController.self)) as! OfferViewController
        vc.offer = offers[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: - API Call

extension OffersViewController {
    
    func getOffers() {
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        OfferManager.shared.getOffers { (offers, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            guard error == nil else {
                return MessagesManager.showErrorWithAlert(error: error)
            }
            
            self.offers = offers ?? []
            self.tableView.reloadData()
        }
    }
}
