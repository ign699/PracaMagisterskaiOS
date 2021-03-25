//
//  RepoView.swift
//  PracaMagisterska
//
//  Created by Jan Ignasik on 06/03/2021.
//

import SwiftUI
import MarkdownUI
import Combine
import UIKit
import WebKit

struct RepoView: View {
    let repo: Repo
    @StateObject var readmeState = ReadMeDataSource()
    
    func getString(data: String) -> String {
        print(data)
        
        guard let data = Data(base64Encoded: data) else { return "" }
        return String(data: data, encoding: .utf8)!
    }
    
    var body: some View {
        VStack {
            WebView(text: $readmeState.readMe).onAppear {
                readmeState.getPopularRepos(repo: self.repo)
            }
        }.navigationBarTitle(Text(""), displayMode: .inline)
    }
}


class ReadMeDataSource: ObservableObject {
    @Published var readMe: String? = nil
    
    func getPopularRepos(repo: Repo) -> Void {
        print(repo.owner.login, repo.name)
        GithubAPI.getReadme(owner: repo.owner.login, repo: repo.name)
            .receive(on: DispatchQueue.main)
            .catch({ _ in Just(self.readMe) })
            .assign(to: &$readMe)
    }
}

struct WebView: UIViewRepresentable {
  @Binding var text: String?
   
  func makeUIView(context: Context) -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration:webConfiguration)
    

       let source: String = "var meta = document.createElement('meta');" +
           "meta.name = 'viewport';" +
           "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
           "var head = document.getElementsByTagName('head')[0];" + "head.appendChild(meta);";

       let script: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
       webView.configuration.userContentController.addUserScript(script)
       webView.scrollView.bounces = false

       return webView
  }
   
  func updateUIView(_ uiView: WKWebView, context: Context) {
    if let text = text {
        uiView.loadHTMLString(text, baseURL: nil)
    } else {
        uiView.loadHTMLString("", baseURL: nil)
    }
  }
}
