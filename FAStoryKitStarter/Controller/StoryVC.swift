//
//  ViewController.swift
//  FAStoryKitStarter
//
//  Created by Ferhat Abdullahoglu on 14.08.2019.
//  Copyright © 2019 Ferhat Abdullahoglu. All rights reserved.
//

import UIKit
import FAGlobalKit
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
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
      
        super.present(viewControllerToPresent, animated: flag, completion: completion)
        
        
        transitionCoordinator?.animate(alongsideTransition: { (_) in
            self.transparentTopView.isHidden = false
            self.transparentTopView.backgroundColor = .black
        })
        
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        
        transitionCoordinator?.animate(alongsideTransition: { (_) in
            self.transparentTopView.backgroundColor = .clear
        }, completion: { (_) in
            self.transparentTopView.isHidden = true
            self.storyVc = nil
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
        
        storyVc = FAStoryViewController()
        storyVc.delegate = self
        storyVc.story = _stories[idx]
        
        storyVc.modalPresentationStyle = .overFullScreen
        storyVc.modalPresentationCapturesStatusBarAppearance = true
        
        present(storyVc, animated: true)
    }


    // -----------------------------------
}


// ==================================================== //
// MARK: FAStoryDelegate, FAStoryViewControllerDelegate
// ==================================================== //
extension StoryVC: FAStoryDelegate, FAStoryViewControllerDelegate {
    
    var cellHeight: CGFloat {
        return kStoryViewHeight
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
    
}



// ==================================================== //
// MARK: FAStoryDataSource
// ==================================================== //
extension StoryVC: FAStoryDataSource {
    func stories() -> [FAStory]? {
        return storyHandler.stories
    }

}



