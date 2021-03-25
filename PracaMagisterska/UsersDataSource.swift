//
//  UsersDataSource.swift
//  PracaMagisterska
//
//  Created by Jan Ignasik on 30/01/2021.
//

import Foundation
import Combine

class UsersDataSource: ObservableObject {
    @Published var items = [User]()
    @Published var isLoadingPage = false
    private var currentPage = 1
    private var canLoadMorePages = true
    private var size = -1
    var searchTask: DispatchWorkItem?
    
    init() {
        loadMoreContent(userName: "")
    }
    
    func loadMoreContentIfNeeded(currentItem row: [User]?) {
        guard let row = row else {
            loadMoreContent(userName: "")
            return
        }
        guard let item = row.last else {
            loadMoreContent(userName: "")
            return
        }
        
        let thresholdIndex = items.index(items.endIndex, offsetBy: -5)
        if items.firstIndex(where: { $0.id == item.id })! >= thresholdIndex {
            loadMoreContent(userName: "")
        }
    }
    
    
    func loadNewNames(userName: String) {
        self.searchTask?.cancel()
        
        let task = DispatchWorkItem { [weak self] in
            print("Executing delayed task")
            self?.currentPage = 1
            self?.canLoadMorePages = true
            self?.items = []
            self?.loadMoreContent(userName: userName)
        }
        self.searchTask = task
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: task)
        
    }
    
    private func loadMoreContent(userName: String) {
        guard !isLoadingPage && canLoadMorePages else {
            return
        }
    
        isLoadingPage = true
        
        GithubAPI.searchUsers(query: userName, page: currentPage)
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { response in
                self.isLoadingPage = false
                self.currentPage += 1
                self.size = response.total_count
                self.canLoadMorePages = response.items.count + self.items.count < response.total_count
            })
            .map({ response in
                return self.items + response.items
            })
            .catch({ _ in Just(self.items) })
            .assign(to: &$items)
    }
}
