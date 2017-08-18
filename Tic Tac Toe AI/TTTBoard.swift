//
//  TTTBoard.swift
//  Tic Tac Toe AI
//
//  Created by Jackson Utsch on 10/9/16.
//  Copyright © 2016 Jackson Utsch. All rights reserved.
//

import UIKit

/// Tic Tac Toe Board - Game board of tic tac toe with minimax based AI
/// - NOTE: User is always first (x)
/// - NOTE: Requires UIView extension of TTTPressX and TTTPressO
class TTTBoard:UIView {
    public enum enumBoardStatus {
        case incomplete
        case draw
        case xWin
        case oWin
    }
    var boardActive = true
    private let STATUS_EMPTY_VALUE = 0
    private let STATUS_X_VALUE = 1
    private let STATUS_O_VALUE = 2
    private let RESULT_TIE_VALUE = 0
    private let RESULT_WIN_VALUE = 10
    private let RESULT_LOSE_VALUE = -10
    /// - NOTE: Empty spaces are represented by 0, X by 1, O by 2
    private var boardStatus = [0,0,0,0,0,0,0,0,0] // 3x3
    /// solutions - All possible solutions to win the game
    /// - NOTE: NOT READ AS "boardStatus" IS
    /// - NOTE: The solutions are read left to right, top to bottom
    private let gameSolutions:[[Int]] = [[1,2,3], [1,5,9], [1,4,7], [2,5,8], [3,5,7], [3,6,9], [4,5,6], [7,8,9]]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUp() {
        center.x -= frame.width/2
        center.y -= frame.height/2
        backgroundColor = UIColor.white
        
        for x in 1...9 {
            let piece = TTTSquare(frame: CGRect(x: 0, y: 0, width: frame.width/3, height: frame.height/3))
            if x <= 3 { // Row 1
                piece.center.y += 0
            }
            if x > 3 && x <= 6 { // Row 2
                piece.center.y += frame.height/3
            }
            if x > 6 && x <= 9 { // Row 3
                piece.center.y += 2*frame.height/3
            }
            
            if x % 3 == 1 { // Column 1
                piece.center.x += 0
            }
            if x % 3 == 2 { // Column 2
                piece.center.x += frame.width/3
            }
            if x % 3 == 0 { // Column 3
                piece.center.x += 2*frame.width/3
            }
            
            piece.layer.borderColor = UIColor.lightGray.cgColor
            piece.layer.borderWidth = 2
            piece.layer.name = "\(x)"
            addSubview(piece)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if boardActive == true {
                for view in self.subviews {
                    if view.frame.contains(location) {
                        view.perform(#selector(TTTSquare.TTTPressX))
                        boardStatus[Int(view.layer.name!)! - 1] = STATUS_X_VALUE // Updates game status
                        Timer.scheduledTimer(timeInterval: 0.0, target: self, selector: #selector(TTTBoard.computeMove), userInfo: nil, repeats: false) // Delay for user experience
                    }
                }
            }
        }
    }
    
    /// - NOTE: Sender is optional, otherwise uses game's current board status
    func getBoardStatus(_ status:[Int]?) -> enumBoardStatus {
        var tempStatus:[Int] = []
        if status != nil {
            tempStatus = status!
        } else {
            tempStatus = boardStatus
        }
        /// Represents spaces occupied by X
        var xSpots:[Int] = []
        /// Represents spaces occupied by O
        var oSpots:[Int] = []
        for value in 0...8 { // Determines spots occupied by Xs and Os
            if tempStatus[value] == STATUS_X_VALUE {
                xSpots += [value + 1]
            }
            if tempStatus[value] == STATUS_O_VALUE {
                oSpots += [value + 1]
            }
        }
        
        for solution in gameSolutions { // Determines if a solution has been found
            // Checks Xs
            var xNumberCorrect = 0
            for value in xSpots {
                if solution.contains(value) {
                    xNumberCorrect += 1
                }
            }
            if xNumberCorrect == 3 {
                return .xWin
            }
            // Checks Os
            var oNumberCorrect = 0
            for value in oSpots {
                if solution.contains(value) {
                    oNumberCorrect += 1
                }
            }
            if oNumberCorrect == 3 {
                return .oWin
            }
        }
        
        var containsZero = false
        for value in tempStatus {
            if value == 0 {
                containsZero = true
            }
        }
        
        if containsZero == true {
            return .incomplete
        }
        return .draw
    }
    
    func gameOver(_ status:[Int]) -> Bool {
        if getBoardStatus(status) == .incomplete {
            return false
        }
        return true
    }
    
    func computeMove() -> Bool {
        // Determines if game has concluded
        switch getBoardStatus(nil) {
        case .incomplete: break
        case .draw:
            print("Tie Game!")
            boardActive = false
        case .xWin:
            print("X Wins!")
            boardActive = false
        case .oWin:
            print("O Wins!")
            boardActive = false
        }
        
        // Computes Move With Minimax
        var spacesAvaliable:[Int] = []
        for value in 0...8 {
            if boardStatus[value] == STATUS_EMPTY_VALUE {
                spacesAvaliable += [value + 1]
            }
        }

        /// - NOTE: Layout is [spaceNumber:score]
        var spaceScores:[(Int, Int)] = []
        for space in spacesAvaliable {
            spaceScores += [scoreMove(space, tempStatus: boardStatus, depth: 0)]
        }
        
        print(spaceScores)
        
        var highScore = 0
        
        for score in spaceScores {
            if score.1 > highScore {
                highScore = score.1
            }
        }
        
        var moveSpace = 0

        for score in spaceScores {
            if score.1 == highScore {
                moveSpace = score.0
            }
        }
        
        for case let subview as TTTSquare in subviews {
            if subview.layer.name == "\(moveSpace)" {
                subview.TTTPressO()
                boardStatus[moveSpace - 1] = STATUS_O_VALUE
            }
        }
        
        return true
    }
    
    func scoreMove(_ space:Int, tempStatus:[Int], depth:Int) -> (space:Int, score:Int) { // Assumes Os Turn (AI)
        // Determines all possible moves, adds together the scores
        
        var newStatus = tempStatus
        newStatus[space - 1] = STATUS_O_VALUE
        
        let newResult = getBoardStatus(newStatus)
        
        switch newResult {
        case .incomplete:
            var moveScore = 0 // Returned score for move
            var emptySpots:[Int] = [] // Avaliable spots for one's turn
            for value in 0...8 { // Determines empty spots
                if newStatus[value] == STATUS_EMPTY_VALUE {
                    emptySpots += [value + 1]
                }
            }
            
            var depth = depth
            for spot in emptySpots { // Xs Turn!
                depth += 1
                var tempStatus = newStatus
                tempStatus[spot - 1] = STATUS_X_VALUE
                let tempResult = getBoardStatus(tempStatus)
                switch tempResult {
                case .incomplete: moveScore += scoreMove(spot, tempStatus: tempStatus, depth: depth).1
                case .draw: moveScore += RESULT_TIE_VALUE
                case .xWin: moveScore += RESULT_LOSE_VALUE + depth
                case .oWin: moveScore += RESULT_WIN_VALUE - depth
                }
            }
            return (space, moveScore)
            
        case .draw: return (space, 0)
        case .xWin: return (space, -100 / (depth + 1))
        case .oWin: return (space, 100 / (depth + 1))
        }
    }
    
    func gameWon(_ newStatus:[Int]) -> Bool { // Determines if a solution would be found
        
        for solution in gameSolutions {
            /// Represents spaces occupied by X
            var xSpots:[Int] = []
            /// Represents spaces occupied by O
            var oSpots:[Int] = []
            for value in 0...8 { // Determines spots occupied by Xs and Os
                if newStatus[value] == STATUS_X_VALUE {
                    xSpots += [value + 1]
                }
                if newStatus[value] == STATUS_O_VALUE {
                    oSpots += [value + 1]
                }
            }
            
            var xNumberCorrect = 0
            for value in xSpots {
                if solution.contains(value) {
                    xNumberCorrect += 1
                }
            }
            if xNumberCorrect == 3 {
                return true
            }
            var oNumberCorrect = 0
            for value in oSpots {
                if solution.contains(value) {
                    oNumberCorrect += 1
                }
            }
            if oNumberCorrect == 3 {
                return true
            }
        }
        return false
    }
}

class TTTSquare:UIView {
    
    let squareName = "TTTSquare"
    
    /// Shows an X occupies view
    func TTTPressX() {
        var labelPresent = false
        if subviews.count > 0 {
            labelPresent = true
        }
        if labelPresent == false {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
            label.textAlignment = .center
            label.font = UIFont(name: "Avenir Next", size: frame.width/2)
            label.text = "X"
            addSubview(label)
        }
    }
    
    /// Shows an O occupies view
    func TTTPressO() {
        var labelPresent = false
        if subviews.count > 0 {
            labelPresent = true
        }
        if labelPresent == false {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
            label.textAlignment = .center
            label.font = UIFont(name: "Avenir Next", size: frame.width/2)
            label.text = "O"
            addSubview(label)
        }
    }
}
