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


    private func tileViewForTag(tag: Int) -> TileView {

        return viewWithTag(tag)!.superview as! TileView
    }


    func setTileEmpty(tag: Int) {

        tileViewForTag(tag: tag).setEmpty()
    }


    func setTileOwnedByPlayerA(tag: Int) {

        tileViewForTag(tag: tag).setOwnedByPlayerA()
    }


    func setTileOwnedByPlayerB(tag: Int) {

        tileViewForTag(tag: tag).setOwnedByPlayerB()
    }


    func setTileDestroyed(tag: Int) {

        tileViewForTag(tag: tag).setDestroyed()
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
