//
//  DetailViewController.swift
//  Study-RxSwift
//
//  Created by GENKIFUJIMOTO on 2024/08/16.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var todoItemLabel: UILabel!
    var item: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        todoItemLabel.text = item
    }

}
