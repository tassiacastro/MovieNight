//
//  MovieViewController.swift
//  MovieNight
//
//  Created by Tassia Serrao on 11/07/2017.
//  Copyright © 2017 Tassia Serrao. All rights reserved.
//

import UIKit

class MovieViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var movieTableView: UITableView!
    @IBOutlet weak var numberOfSelectedMoviesLabel: UILabel!
    var movies = [Movie]()
    var selectedMovies = [Int: Int]()
    let apiClient = Factory.createApiClient()
    var repository = Factory.createRepository()
    var page = 1
    var user = User.Fox
    var moviesSelectedCount = 0
    let moviesLimit = 2
    var selectedindexPaths = [Int]()
    var hasNextPage: Bool = true {
        didSet {
            self.page += 1
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        movieTableView.allowsSelection = false
        movieTableView.delegate = self
        movieTableView.dataSource = self
        
        loadData()
    }
    
    func loadData() {
        fetchMovies(with: page)
    }
    
    func fetchMovies(with page: Int) {
        
        apiClient.fetchMovies(page: page) { [weak self] (results) in
            switch results {
                case .failure(let error) :
                    print(error)
                case .success(let resource, let hasPage) :
                    self?.movies += resource
                    self?.hasNextPage = hasPage
                    self?.movieTableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if shouldFetchNextPage(indexPath: indexPath) {
            fetchMovies(with: page)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieIdCell", for: indexPath) as! MovieTableViewCell
        cell.titleLabel.text = movies[indexPath.row].title
        cell.id = movies[indexPath.row].id
        // Assign the indexPath to the button's tag so the movie selected can be retreived when the button is tapped
        cell.loveButton.tag = indexPath.row
        
        if selectedindexPaths.contains(indexPath.row) {
            selectImageButton(button: cell.loveButton)
        } else {
            deselectImageButton(button: cell.loveButton)
        }
        
        return cell
    }
    
    func selectImageButton(button: UIButton) {
        button.setImage(UIImage(named: "loveSelected"), for: .normal)
        button.isSelected = true
    }
    
    func deselectImageButton(button: UIButton) {
        button.setImage(UIImage(named: "loveDeselected"), for: .normal)
        button.isSelected = false
    }
    
    func shouldFetchNextPage(indexPath: IndexPath) -> Bool {
        return (movies.count - indexPath.row) == 5 && hasNextPage
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    @IBAction func didSelectMovie(_ sender: Any) {
        let loveButton = sender as! UIButton
        let indexPath = IndexPath(row: loveButton.tag, section: 0)
        
        if loveButton.isSelected {
            deselectImageButton(button: loveButton)
            removeSelectedMovie(with: indexPath)
        } else {
            
            //Show an alert in case the user have selected the limit amount of movies
            guard moviesSelectedCount < moviesLimit  else {
                let alert = Alert.create(alertTitle: "You've selected \(moviesLimit) movies", message: "Please, go to next page", actionTitle: "Ok")
                present(alert, animated: true, completion: nil)
                return
            }
            
            selectImageButton(button: loveButton)
            saveSelectedMovie(with: indexPath)
        }
    }
    
    func saveSelectedMovie(with indexPath: IndexPath) {
        selectedindexPaths.append(indexPath.row)
        moviesSelectedCount += 1
        updateNumberOfSelectedActorsLabel()
        selectedMovies[indexPath.row] = movies[indexPath.row].id
    }
    
    func removeSelectedMovie(with indexPAth: IndexPath) {
        selectedindexPaths = selectedindexPaths.filter { $0 != indexPAth.row }
        moviesSelectedCount -= 1
        updateNumberOfSelectedActorsLabel()
        selectedMovies.removeValue(forKey: indexPAth.row)
    }
    
    func updateNumberOfSelectedActorsLabel() {
        numberOfSelectedMoviesLabel.text = "\(moviesSelectedCount) of \(moviesLimit) selected"
    }
    
    // Called when the user taps the 'Done' button
    @IBAction func saveMoviesSelectedInDisk(_ sender: Any) {
        switch user {
        case .Fox :
            repository.save(dictionary: selectedMovies, for: UserKeys.FoxUserMovies.rawValue)
        case .Crab:
            repository.save(dictionary: selectedMovies, for: UserKeys.CrabUserMovies.rawValue)
        }
    }
    
    @IBAction func showHomeViewController(_ sender: Any) {
        let shouldPerformSegue = moviesSelectedCount == moviesLimit
        
        if shouldPerformSegue {
            performSegue(withIdentifier: "unwindSeguetoHomeVC", sender: self)
        } else {
            let alert = Alert.create(alertTitle: "Hey =)", message: "Please, select \(moviesLimit) movies before going to next page", actionTitle: "Ok")
            present(alert, animated: true, completion: nil)
        }
    }
}












