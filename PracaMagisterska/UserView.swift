//
//  UserView.swift
//  PracaMagisterska
//
//  Created by Jan Ignasik on 10/02/2021.
//

import SwiftUI
import Combine
import Foundation
import UIKit

let coloredNavAppearance = UINavigationBarAppearance()


let colors = ["Projects", "Starred"]

struct ViewPicker: View {
    @Binding var selectedMode: String
    
    init(selectedMode: Binding<String>) {
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor:  UIColor(Color("Primary"))], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
        self._selectedMode = selectedMode
    }

    
    var body: some View {
        VStack {
            Picker("Please choose a color", selection: $selectedMode) {
                ForEach(colors, id: \.self) {
                    Text($0)
                }
            }.pickerStyle(SegmentedPickerStyle())
        }
    }
}


struct UserView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var status = true
    @StateObject var userData = UserDataSource()
    @State private var selectedMode = "Projects"
    let user: User
    
    
    init(user: User) {
        coloredNavAppearance.configureWithOpaqueBackground()
        coloredNavAppearance.backgroundColor = UIColor(Color("Primary"))
        coloredNavAppearance.shadowImage = UIImage()
        coloredNavAppearance.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = coloredNavAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredNavAppearance
        
        UIScrollView.appearance().bounces = false
        self.user = user
    }
    
    var body: some View {
        ScrollView {
        VStack {
            HStack(alignment: .center) {
                Spacer()
                UserImage(user: user).clipShape(Circle()).frame(width: 158, height: 158).overlay(Circle().stroke(Color.white, lineWidth: 4)).offset(y: 50).shadow(radius: 2, x: 0, y: 4)
                Spacer()
            }.padding().background(Color("Primary")).padding(.bottom, 40)
            Text(user.login).font(.system(size: 30))
            HStack {
                ViewPicker(selectedMode: $selectedMode)
            }.padding()
            
           
                if(userData.repos.count == 0) {
                    ProgressView()
                } else {
                    VStack(alignment: .leading) {
                        ForEach(selectedMode == "Projects" ? self.userData.repos : self.userData.subscriptions, id: \.id) { repo in
                            NavigationLink(destination: RepoView(repo: repo)) {
                                VStack(alignment: .leading) {
                                    Text(repo.name).font(.system(size: 16)).fontWeight(.bold)
                                        .padding(.bottom, 8)
                                    if let repoDesc = repo.description {
                                        Text(repoDesc).font(.system(size: 14))
                                    }
                                }
                            }.buttonStyle(PlainButtonStyle())
                            Divider()
                        }
                    }.padding(.horizontal, 16)
            
            }
        }.frame(minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity,
                alignment: .topLeading
        ).onAppear {
            self.userData.getUserRepos(userLogin: user.login)
            self.userData.getUserSubscriptions(userLogin: user.login)
        }
        }
    }
}


class UserDataSource: ObservableObject {
    @Published var repos = [Repo]()
    @Published var subscriptions = [Repo]()
    
    func getUserRepos(userLogin: String) -> Void {
        if(repos.count == 0) {
            GithubAPI.getUserRepos(login: userLogin)
                .receive(on: DispatchQueue.main)
                .catch({ _ in Just(self.repos) })
                .assign(to: &$repos)
        }
    }
    func getUserSubscriptions(userLogin: String) -> Void {
        if(subscriptions.count == 0) {
            GithubAPI.getUserSubscriptions(login: userLogin)
                .receive(on: DispatchQueue.main)
                .catch({ _ in Just(self.subscriptions) })
                .assign(to: &$subscriptions)
        }
    }
}
