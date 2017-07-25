//
//  ViewController.swift
//  MovieNight
//
//  Created by Tassia Serrao on 05/07/2017.
//  Copyright © 2017 Tassia Serrao. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
   
    @IBAction func selectCrabPreferences(_ sender: Any) {
        if Reachability.isConnectedToNetwork() {
            showGenreViewController(with: User.Crab)
        } else {
            showOfflineError()
        }
    }
    
    @IBAction func selectFoxPreferences(_ sender: Any) {
        if Reachability.isConnectedToNetwork() {
            showGenreViewController(with: User.Fox)
        } else {
            showOfflineError()
        }
    }
    
    func showGenreViewController(with user: User) {
        let genreVC = self.storyboard?.instantiateViewController(withIdentifier: "genreVC") as! GenreViewController
        genreVC.user = user
        self.present(genreVC, animated: true, completion: nil)
    }
    
    func showOfflineError() {
        let alert = UIAlertController(title: "You're offline", message: "Please connect to the internet and try again", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

