//
//  homeObVC.swift
//  SmartInterphone
//
//  Created by Ladjemi Kais on 5/5/19.
//  Copyright © 2019 iof. All rights reserved.
//

import UIKit
import Instructions

extension DevicesVC :  CoachMarksControllerDataSource {
    
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 4
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              coachMarkAt index: Int) -> CoachMark {
        var coachMark : CoachMark
        let cutoutPathMaker = { (frame: CGRect) -> UIBezierPath in
            return UIBezierPath(ovalIn: frame.insetBy(dx: -4, dy: -4))
        }
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = deviceCollection!.cellForItem(at: indexPath) as! DeviceCell
        switch(index) {
        case 0:
            return coachMarksController.helper.makeCoachMark(for: cell)
        case 1:
            return coachMarksController.helper.makeCoachMark(for: cell.infoButton,
                                                             cutoutPathMaker: cutoutPathMaker)
        case 2:
            return coachMarksController.helper.makeCoachMark(for: cell.addMessageButton,
                                                             cutoutPathMaker: cutoutPathMaker)
        case 3:
            return coachMarksController.helper.makeCoachMark(for:  refreshBtn,  cutoutPathMaker: cutoutPathMaker)
        default:
            coachMark = coachMarksController.helper.makeCoachMark()
        }
        coachMark.gapBetweenCoachMarkAndCutoutPath = 6.0
        return coachMark
    }
    
    func coachMarksController(
        _ coachMarksController: CoachMarksController,
        coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark
        ) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(
            withArrow: true,
            arrowOrientation: coachMark.arrowOrientation
        )
        coachViews.bodyView.hintLabel.text = txts[index]
        coachViews.bodyView.nextLabel.text = nextButtonText[index]
        coachViews.bodyView.nextLabel.textColor = UIColor.orange
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
}


// MARK: - Protocol Conformance | CoachMarksControllerAnimationDelegate
extension DevicesVC : CoachMarksControllerAnimationDelegate {
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              fetchAppearanceTransitionOfCoachMark coachMarkView: UIView,
                              at index: Int,
                              using manager: CoachMarkTransitionManager) {
        manager.parameters.options = [.beginFromCurrentState]
        manager.animate(.regular, animations: { _ in
            coachMarkView.transform = .identity
            coachMarkView.alpha = 1
        }, fromInitialState: {
            coachMarkView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            coachMarkView.alpha = 0
        })
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              fetchDisappearanceTransitionOfCoachMark coachMarkView: UIView,
                              at index: Int,
                              using manager: CoachMarkTransitionManager) {
        manager.parameters.keyframeOptions = [.beginFromCurrentState]
        manager.animate(.keyframe, animations: { _ in
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0, animations: {
                coachMarkView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: {
                coachMarkView.alpha = 0
            })
        })
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              fetchIdleAnimationOfCoachMark coachMarkView: UIView,
                              at index: Int,
                              using manager: CoachMarkAnimationManager) {
        manager.parameters.options = [.repeat, .autoreverse, .allowUserInteraction]
        manager.parameters.duration = 0.7
        
        manager.animate(.regular, animations: { context in
            let offset: CGFloat = context.coachMark.arrowOrientation == .top ? 10 : -10
            coachMarkView.transform = CGAffineTransform(translationX: 0, y: offset)
        })
    }
}
