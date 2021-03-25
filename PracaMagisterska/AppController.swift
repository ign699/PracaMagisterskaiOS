//
//  AppController.swift
//  PracaMagisterska
//
//  Created by Jan Ignasik on 29/01/2021.
//

import UIKit
import Alamofire
import SwiftUI

class AppController: UIViewController {

    let content = UIHostingController(rootView: TabbedAppView())
    
    @IBOutlet weak var myView: UIView!
    override func viewDidLoad() {
        
//        content.rootView.present = {
//            let destination = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "login") as! ViewController
//            destination.modalPresentationStyle = .fullScreen
//            self.content.present(destination, animated: true, completion: nil)
//        }

        
        super.viewDidLoad()
        addChild(content)
        myView.addSubview(content.view)
        setupConstraints()
        // Do any additional setup after loading the view.
    }
    
    fileprivate func setupConstraints() {
        content.view.translatesAutoresizingMaskIntoConstraints = false
        content.view.topAnchor.constraint(equalTo: myView.topAnchor).isActive = true
        content.view.bottomAnchor.constraint(equalTo: myView.bottomAnchor).isActive = true
        content.view.leftAnchor.constraint(equalTo: myView.leftAnchor).isActive = true
        content.view.rightAnchor.constraint(equalTo: myView.rightAnchor).isActive = true
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
