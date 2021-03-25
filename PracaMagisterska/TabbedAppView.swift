//
//  TabbedAppView.swift
//  PracaMagisterska
//
//  Created by Jan Ignasik on 04/03/2021.
//

import SwiftUI
import UIKit

struct TabbedAppView: View {

    var body: some View {
        NavigationView {
        TabView {
           UsersListView()
                .tabItem {
                    VStack() {
                        Image(systemName: "circle.fill")
                        Text("Users")
                    }
                }
                .tag(1)

            ReposView().navigationBarHidden(true)
                .tabItem {
                    VStack() {
                        Image(systemName: "circle.fill")
                        Text("Projects")
                    }
                }
                .tag(2)
        }.accentColor(Color("Primary"))
    }
        .accentColor(.white)
    }
}
