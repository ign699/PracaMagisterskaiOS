//
//  ReposView.swift
//  PracaMagisterska
//
//  Created by Jan Ignasik on 04/03/2021.
//


import SwiftUI
import Combine
import Foundation
import UIKit

struct ReposView: View {
    @StateObject var repos = ReposDataSource()
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(self.repos.repos, id: \.id) { repo in
                    NavigationLink(destination: RepoView(repo: repo)){
                        VStack (alignment: .leading) {
                            Text(repo.name).font(.system(size: 16)).fontWeight(.bold)
                                .padding(.bottom, 8)
                            if let repoDesc = repo.description {
                                Text(repoDesc).font(.system(size: 14))
                            }
                        }
                    }.buttonStyle(PlainButtonStyle())
                    .onAppear{
                        self.repos.loadMoreContentIfNeeded(repo: repo)
                        }
                    Divider()
                }
            }.padding(.horizontal, 16)
        }
    }
}


class ReposDataSource: ObservableObject {
    @Published var repos = [Repo]()
    @Published var isLoadingPage = false
    private var currentPage = 1
    private var canLoadMorePages = true
    private var size = -1
    
    init() {
        loadMoreContent()
    }
    
    func loadMoreContentIfNeeded(repo: Repo) {
        guard let repoIndex = self.repos.firstIndex(of: repo) else {
            return
        }
        if(repoIndex == repos.count - 5) {
            loadMoreContent()
        }
        
    }
    
    func loadMoreContent() -> Void {
        guard !isLoadingPage && canLoadMorePages else {
            return
        }
        isLoadingPage = true
        
        GithubAPI.getPopularRepos(page: self.currentPage)
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { response in
                self.isLoadingPage = false
                self.currentPage += 1
                self.canLoadMorePages = response.items.count + self.repos.count < response.total_count
            })
            .map({ response in
                return self.repos + response.items
            })
            .catch({ _ in Just(self.repos) })
            .assign(to: &$repos)
    }
}
