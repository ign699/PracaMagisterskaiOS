//
//  HostingViewController.swift
//  PracaMagisterska
//
//  Created by Jan Ignasik on 31/01/2021.
//

import UIKit
import SwiftUI

class HostingViewController: UIHostingController<UsersListView> {

    required init?(coder aDecoder: NSCoder) {
          super.init(coder: aDecoder, rootView: UsersListView())
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
