//
//  SWApiCllient.swift
//  TheApiAwakens
//
//  Created by Tassia Serrao on 19/01/2017.
//  Copyright © 2017 Tassia Serrao. All rights reserved.
//

import Foundation

protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var parameters: [String: String] { get }
}

extension Endpoint {
    var queryItems: [URLQueryItem] {
        var queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            queryItems.append(queryItem)
        }
        return queryItems
    }
    
    var request: URLRequest {
        let components = NSURLComponents(string: baseURL)!
        components.path = path
        components.queryItems = queryItems // the URL is percent encoded here
        
        let url = components.url!
        return URLRequest(url: url)
    }
}

enum MovieNightEndpoint: Endpoint {
    case Genre
    case Actor
    
    var baseURL: String {
        return "https://api.themoviedb.org"
    }
    var path: String {
        switch self {
            case .Genre:
                return "/3/genre/movie/list"
            case .Actor:
                return "/3/person/popular"
        }
    }
    
    var parameters: [String : String] {
        var parameters = [String : String]()
        switch self {
        default:
            parameters["api_key"] = "57b213eb9d700e45c3f1ddaa754d7134"
            parameters["page"] = "1"
            return parameters
        }
    }
}

final class MovieNightApiClient: APIClient {
    var configuration: URLSessionConfiguration
    lazy var session: URLSession = {
        return URLSession(configuration: self.configuration)
    }()
    
    init(configuration: URLSessionConfiguration) {
        self.configuration = configuration
    }
    
    convenience init() {
        self.init(configuration: .default)
    }
    
    func fetchForGenre(completion: @escaping (APIResult<[Genre]>) -> Void) {
        let endpoint = MovieNightEndpoint.Genre
        let request = endpoint.request
        
        fetch(request: request, parse: { (json) -> [Genre]? in
            guard let genres = json["genres"] as? [[String:AnyObject]] else {
                return nil
            }
            return genres.flatMap {
                return Genre(JSON: $0)
            }
        }, completion: completion)
    }
    
    func fetchForActor(completion: @escaping (APIResult<[Actor]>) -> Void) {
        let endpoint = MovieNightEndpoint.Actor
        let request = endpoint.request
        
        fetch(request: request, parse: { (json) -> [Actor]? in
            guard let popularActors = json["results"] as? [[String:AnyObject]] else {
                return nil
            }
            return popularActors.flatMap {
                return Actor(JSON: $0)
            }
        }, completion: completion)
    }

    
}








