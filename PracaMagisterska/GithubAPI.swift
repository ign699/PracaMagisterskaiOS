//
//  GithubAPI.swift
//  PracaMagisterska
//
//  Created by Jan Ignasik on 30/01/2021.
//

import Foundation


import Foundation
import Combine

func createRequest(url: URL, html: Bool? = false) -> URLRequest {
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    let loginString = String(format: "%@:%@", Bundle.main.object(forInfoDictionaryKey:"GITHUB_KEY") as! String, Bundle.main.object(forInfoDictionaryKey:"GITHUB_PASS") as! String)
    let loginData = loginString.data(using: String.Encoding.utf8)!
    let base64LoginString = loginData.base64EncodedString()
    request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
    
    if(html!) {
        request.setValue("application/vnd.github.v3.html", forHTTPHeaderField: "Accept")
    }

    
    return request
}

enum GithubAPI {
    static let pageSize = 99
    
    static func searchUsers(query: String, page: Int) -> AnyPublisher<GithubSearchResult<User>, Error> {
        let url: URL
        if query.isEmpty {
            url = URL(string: "https://api.github.com/search/users?q=followers:%3E1000&sort=followers&per_page=\(Self.pageSize)&page=\(page)")!
        } else {
            url = URL(string: "https://api.github.com/search/users?q=\(query)+in%3Alogin&sort=followers&per_page=\(Self.pageSize)&page=\(page)")!
        }
    
            
        
        return URLSession.shared
            .dataTaskPublisher(for: createRequest(url: url))
            .tryMap({ output in
                return try JSONDecoder().decode(GithubSearchResult<User>.self, from: output.data)
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    static func getUserRepos(login: String) -> AnyPublisher<[Repo], Error> {
        let url = URL(string: "https://api.github.com/users/\(login)/repos")!
        return URLSession.shared
            .dataTaskPublisher(for: createRequest(url: url))
            .tryMap({ output in
                do {
                    return try JSONDecoder().decode([Repo].self, from: output.data)
                } catch let jsonError as NSError {
                    print("JSON decode failed: \(jsonError)")
                    return []
              }
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    static func getUserSubscriptions(login: String) -> AnyPublisher<[Repo], Error> {
        let url = URL(string: "https://api.github.com/users/\(login)/starred")!
        return URLSession.shared
            .dataTaskPublisher(for: createRequest(url: url))
            .tryMap({ output in
                do {
                    return try JSONDecoder().decode([Repo].self, from: output.data)
                } catch let jsonError as NSError {
                    print("JSON decode failed: \(jsonError)")
                    return []
              }
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    static func getPopularRepos(page: Int) -> AnyPublisher<GithubSearchResult<Repo>, Error> {
        let url = URL(string: "https://api.github.com/search/repositories?q=stars:%3E1&sort=stars&per_page=\(Self.pageSize)&page=\(page)")!
        return URLSession.shared
            .dataTaskPublisher(for: createRequest(url: url))
            .tryMap({ output in
                return try JSONDecoder().decode(GithubSearchResult<Repo>.self, from: output.data)
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    static func getReadme(owner: String, repo: String) -> AnyPublisher<String?, Error> {
        let url = URL(string: "https://api.github.com/repos/\(owner)/\(repo)/readme")!
        return URLSession.shared
            .dataTaskPublisher(for: createRequest(url: url, html: true))
            .tryMap({ output in
                print(output)
                return String(data: output.data, encoding: String.Encoding.utf8)
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

struct GithubSearchResult<T: Codable>: Codable {
    let items: [T]
    let total_count: Int
}

struct User: Codable, Equatable, Identifiable, Hashable {
    var id: Int
    let login: String
    let avatar_url: String?
    //let followers: Int
}

struct Repo: Codable, Equatable, Identifiable, Hashable {
    var id: Int
    var name: String
    var stargazers_count: Int
    var html_url: String
    var owner: User
    var description: String?
}

