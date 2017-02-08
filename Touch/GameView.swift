//
//  GameView.swift
//  Touch
//
//  Created by sean on 08/02/2017.
//  Copyright © 2017 antfarm. All rights reserved.
//

import UIKit


class GameView: UIView {

    @IBOutlet var labelScoreA: UILabel!
    @IBOutlet var labelScoreB: UILabel!

    @IBOutlet var indicatorA: UIView!
    @IBOutlet var indicatorB: UIView!

    @IBOutlet var gridView: UIView!
    @IBOutlet var scoreView: UIView!
    

    func tileViewForTag(tag: Int) -> TileView {

        return viewWithTag(tag)!.superview as! TileView
    }


    func makeRoundedCorners() {

        for tag in (1...49) {
            tileViewForTag(tag: tag).layer.cornerRadius = 8
        }

        gridView.layer.cornerRadius = 8

        scoreView.layer.cornerRadius = 8

        labelScoreA.layer.masksToBounds = true
        labelScoreB.layer.masksToBounds = true

        labelScoreA.layer.cornerRadius = 6
        labelScoreB.layer.cornerRadius = 6

        indicatorA.layer.cornerRadius = 4
        indicatorB.layer.cornerRadius = 4
    }

    
    func setTurnIndicatorPlayerA() {

        indicatorA.alpha = 1
        indicatorB.alpha = 0
    }


    func setTurnIndicatorPlayerB() {

        indicatorA.alpha = 0
        indicatorB.alpha = 1
    }


    func setScore(playerA scoreA: Int, playerB scoreB: Int) {

        labelScoreA.text = "\(scoreA)"
        labelScoreB.text = "\(scoreB)"
    }
}
