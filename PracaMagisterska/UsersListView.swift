//
//  UsersListView.swift
//  PracaMagisterska
//
//  Created by Jan Ignasik on 30/01/2021.
//

import SwiftUI
import URLImage
import Combine


struct ImageLoading: View {
    var body: some View {
        ActivityIndicator().frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity).aspectRatio(1, contentMode: .fit)
    }
}

struct ImageContentView<Image>: View where Image : View {
    var image: () -> Image
    var user: User
    
    init(user: User, @ViewBuilder image: @escaping () -> Image) {
        self.image = image
        self.user = user
    }
  
    var body: some View {
        image()
    }
}

struct UserImage: View {
    var url: URL
    var user: User

   
    init(user: User) {
        self.url = URL(string: user.avatar_url!)!
        self.user = user
    }
    
    var body: some View {
        URLImage(url: url,
             empty: {
                 Text("Nothing here")
              },
             inProgress: {_ in
                ImageLoading()
             },
              failure: { _, _ in
                Text("ERR")
              },
              content: { image in
                ImageContentView(user: user) {
                    image
                       .resizable()
                       .aspectRatio(contentMode: .fit)
                    .cornerRadius(10)
                   }
                }
        )
    }
}


struct ImagesList: View {
    @EnvironmentObject var dataSource: UsersDataSource

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack (alignment: .leading) {
                    ForEach(dataSource.items.chunked(into: 3), id: \.self) { items in
                        HStack (alignment: .top) {
                            ForEach(items, id: \.self) { item in
                                NavigationLink(destination: UserView(user: item)){
                                    UserImage(user: item)
                                }.buttonStyle(BorderlessButtonStyle())
                                .frame(maxWidth: geometry.size.width * 0.33333)
                                .padding(4)
                            }
                        }.onAppear {
                            dataSource.loadMoreContentIfNeeded(currentItem: items)
                        }
                    }
                }
            }
        }

    }
}


struct UsersListView: View {
    @StateObject var dataSource = UsersDataSource()
    @State var username: String = ""

  var body: some View {
   
 
        VStack {
            TextField("Enter username...", text: $username)
                .onChange(of: username) { username in
                    dataSource.loadNewNames(userName: username)
                }
                .accentColor(.blue)
                .font(.system(size: 18))
                .padding(8)
                .background(Color("LightGray"))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("DarkGray"), lineWidth: 1))
                .padding(.horizontal, 4)
            ImagesList()
                .navigationBarTitle("Users", displayMode: .inline)
                .navigationBarHidden(true)
                .environmentObject(dataSource)
        }    .padding(.horizontal, 4)

  }
}


