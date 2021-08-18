//
//  ViewController.swift
//  FAStoryKitStarter
//
//  Created by Ferhat Abdullahoglu on 14.08.2019.
//  Copyright © 2019 Ferhat Abdullahoglu. All rights reserved.
//

import UIKit
import FAStoryKit

class StoryVC: UIViewController, TransitionTransparencyProxy {
    
    // ==================================================== //
    // MARK: IBOutlets
    // ==================================================== //
    
    
    // ==================================================== //
    // MARK: IBActions
    // ==================================================== //
    
    
    // ==================================================== //
    // MARK: Properties
    // ==================================================== //
    
    // -----------------------------------
    // Public properties
    // -----------------------------------
    /// Transparent top view that's used when presenting the stories
    var transparentTopView: UIView!
    
    // -----------------------------------
    
    
    // -----------------------------------
    // Private properties
    // -----------------------------------
    /// Main highlight container
    private var storyView: FAStoryView!
    
    /// StoryView height
    private let kStoryViewHeight: CGFloat = 100
    
    /// ViewController to display the story content
    private var storyVc: FAStoryViewController!
    
    /// Story container viewController
    private weak var storyContainerVc: FAStoryContainer!
    
    /// Story server
    private var storyHandler = StoryServer()
    // -----------------------------------
    
    
    // ==================================================== //
    // MARK: Init
    // ==================================================== //
    
    
    // ==================================================== //
    // MARK: VC lifecycle
    // ==================================================== //
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
 
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        
        transitionCoordinator?.animate(alongsideTransition: { (_) in
            self.transparentTopView.backgroundColor = .clear
        }, completion: { (_) in
            self.transparentTopView.isHidden = true
            self.storyVc = nil
            self.storyContainerVc = nil 
        })
    }
    
    // ==================================================== //
    // MARK: Methods
    // ==================================================== //
    
    // -----------------------------------
    // Public methods
    // -----------------------------------
    
    /// Protocol method from TransitionTransparencyProxy
    /// since here we don't need anything extra, I just call
    /// the method to satisfy the protocol
    func start() { }
    

    // -----------------------------------
    
    
    // -----------------------------------
    // Private methods
    // -----------------------------------
    /// method to carry out internal UI config
    private func setupUI() {
        //
        // storyView setup
        //
        storyView = FAStoryView(frame: .zero)
        storyView.backgroundColor = .clear
        storyView.isOpaque = false
        storyView.delegate = self
        storyView.dataSource = self
        storyView.setScrollIndicators(hidden: true)
        storyView.setContentInset(insets: .zero)
        
        view.addSubview(storyView)
        
        //
        // add the autolayout constraints
        //
        storyView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        storyView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        //
        if #available(iOS 11, *) {
            storyView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            storyView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        }
        //
        storyView.heightAnchor.constraint(equalToConstant: kStoryViewHeight).isActive = true
        
        //
        // configure the transparentTopView
        //
        config()
        
    }
    
    /// present story view controller with
    /// story index
    private func _presentStoryVc(at idx: Int) {
        guard let _stories = storyHandler.stories else {return}
        guard idx >= 0 && idx < _stories.count else {return}
        
        /// Alternative to show one highligh at a time
        /// without using the container
        
        /*
        storyVc = FAStoryViewController()
        storyVc.delegate = self
        storyVc.story = _stories[idx]
        
        storyVc.modalPresentationStyle = .overFullScreen
        storyVc.modalPresentationCapturesStatusBarAppearance = true
        
        present(storyVc, animated: true)
        */
        
        /// Alternative to show the container
        storyVc = FAStoryViewController()
        storyVc.delegate = self
        storyVc.story = _stories[idx]
        
        storyContainerVc = FAStoryContainer(storyController: storyVc)
        storyContainerVc.modalPresentationStyle = .overFullScreen
        storyContainerVc.transitioningDelegate  = self
        
        
        present(storyContainerVc, animated: true)
    
    }


    // -----------------------------------
}


// ==================================================== //
// MARK: FAStoryDelegate, FAStoryViewControllerDelegate
// ==================================================== //
extension StoryVC: FAStoryDelegate, FAStoryViewControllerDelegate {
    var borderColorUnseen: UIColor? {
        UIColor.blue.withAlphaComponent(0.5)
    }
    
    var borderColorSeen: UIColor? {
        .clear
    }
    
    
    var cellHeight: CGFloat {
        return kStoryViewHeight
    }
    
    var cellAspectRatio: CGFloat {
        return 0.75
    }
    
    var displayNameColor: UIColor {
        return .black
    }
    
    func didSelect(row: Int) {
        _presentStoryVc(at: row)
    }
    
    func dismissButtonImage() -> UIImage? {
        return UIImage(named: "dk_close")?.withRenderingMode(.alwaysTemplate)
    }
    
    var borderColor: UIColor? {
        return nil
    }
    
    var borderWidth: CGFloat? {
        return 0
    }
    
    var cellHorizontalSpacing: CGFloat {
        return 20
    }
    
}



// ==================================================== //
// MARK: FAStoryDataSource
// ==================================================== //
extension StoryVC: FAStoryDataSource {
    func stories() -> [FAStory]? {
        return storyHandler.stories
    }

}



// ==================================================== //
// MARK: UIViewControllerTransitioningDelegate
// ==================================================== //
extension StoryVC: UIViewControllerTransitioningDelegate, ModalPresentationAnimatorProtocol {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let t = ModalPresentationAnimator(duration: 0.8, dismiss: false, topDistance: 0, rasterizing: false)
        t.delegate = self
        return t
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let _transition = ModalPresentationAnimator(duration: 0.3, dismiss: true, topDistance: 0, rasterizing: false)
        
        _transition.delegate = self
        
        //
        // Check the interaction controller
        //
        if let _interactor = (dismissed as? FAStoryViewController)?.dismissInteractionController {
            _transition.dismissInteractionController = _interactor
        } else if let _interactor = (dismissed as? FAStoryContainer)?.dismissInteractionController {
            _transition.dismissInteractionController = _interactor
        }
        return _transition
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let animator = animator as? MainTransitionAnimator,
            let interactionController = animator.dismissInteractionController,
            interactionController.interactionInProgress
            else {
                return nil
        }
        return interactionController
    }

    
    func didComplete(_ completed: Bool, isDismissal: Bool) {
        if completed && isDismissal, storyVc != nil {
            storyVc = nil
        }
    }
    
}


