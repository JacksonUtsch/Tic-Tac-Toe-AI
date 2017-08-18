//
//  ViewController.swift
//  Tic Tac Toe AI
//
//  Created by Jackson Utsch on 10/9/16.
//  Copyright © 2016 Jackson Utsch. All rights reserved.
//

import UIKit

public let screenSize = UIScreen.main.bounds

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let GameBoard = TTTBoard(frame: CGRect(x: screenSize.width/2, y: screenSize.height/2, width: screenSize.width, height: screenSize.width))
        view.addSubview(GameBoard)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
