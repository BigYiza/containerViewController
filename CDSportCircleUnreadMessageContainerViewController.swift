//
//  CDSportCircleUnreadMessageContainerViewController.swift
//  CodoonSport
//
//  Created by ZhangYi on 2019/3/8.
//  Copyright © 2019 Codoon. All rights reserved.
//

import Foundation

@objc class CDSportCircleUnreadMessageContainerViewController: CDViewController, UIScrollViewDelegate {
    
    let kNormalTapTitleColorHexString = "0x808080"
    let kSelectedTapTitleColorHexString = "0x222222"
    
    @IBOutlet weak var allMessageButton: UIButton!
    @IBOutlet weak var commentMessageButton: UIButton!
    @IBOutlet weak var mentionMeMessageButton: UIButton!
    @IBOutlet weak var praiseMessageButton: UIButton!
    @IBOutlet weak var tagContrainerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    var bottomIndexView: UIView?
    var viewControllersDataSource: [CDSportCircleUnreadMessagesViewController] = []
    var tapButtonsCollection: [UIButton] = []
    var pageIndex: NSInteger = 0
    
    override func viewDidLoad() {
        self.title = "新消息"
        self.initDataSource()
        self.initSubviews()
    }
    
    //MARK: handle event
    
    @IBAction func allMessageIndexButtonDidClick(_ sender: Any) {
        pageIndex = 0
        self.tapButtonDidSelected(allMessageButton)
    }
    
    @IBAction func commentMessageIndexButtonDidClick(_ sender: Any) {
        pageIndex = 1
        self.tapButtonDidSelected(commentMessageButton)
    }
    
    @IBAction func mentionMeMessageIndexButtonDidClick(_ sender: Any) {
        pageIndex = 2
        self.tapButtonDidSelected(mentionMeMessageButton)
    }
    
    @IBAction func praiseMessageIndexButtonDidClick(_ sender: Any) {
        pageIndex = 3
        self.tapButtonDidSelected(praiseMessageButton)
    }
    
    //MARK: UIScrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.bottomIndexViewMoveTo(scrollView.contentOffset.x)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.doSomethingAfterEndScrollEvent()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.doSomethingAfterEndScrollEvent()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            self.doSomethingAfterEndScrollEvent()
        }
    }
    
    //MARK: private method
    
    func initDataSource() {
        viewControllersDataSource.append(self.creatChildUnreadMessageViewController(CDSportCircleMessageType.all))
        viewControllersDataSource.append(self.creatChildUnreadMessageViewController(CDSportCircleMessageType.comment))
        viewControllersDataSource.append(self.creatChildUnreadMessageViewController(CDSportCircleMessageType.mention))
        viewControllersDataSource.append(self.creatChildUnreadMessageViewController(CDSportCircleMessageType.praise))
        
        tapButtonsCollection = [allMessageButton, commentMessageButton, mentionMeMessageButton, praiseMessageButton]
    }
    
    func initSubviews() {
        
        bottomIndexView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 20, height: 3))
        bottomIndexView?.backgroundColor = UIColor.init(red: 42 / 255.0, green: 221 / 255.0, blue: 149 / 255.0, alpha: 1)
        bottomIndexView?.layer.cornerRadius = 1.5
        tagContrainerView.addSubview(bottomIndexView!)
        bottomIndexView?.center = CGPoint.init(x: allMessageButton.centerX, y: allMessageButton.centerY + 15)
        
        scrollView.contentSize = CGSize.init(width: self.view.width * 4, height: 0);
        for (index, childVc) in viewControllersDataSource.enumerated() {
            childVc.view.frame = CGRect.init(x: scrollView.width * CGFloat(index), y: 0, width: scrollView.width, height: scrollView.height)
            scrollView.addSubview(childVc.view);
            self.addChildViewController(childVc)
        }
    }
    
    func creatChildUnreadMessageViewController(_ messageType: CDSportCircleMessageType) -> CDSportCircleUnreadMessagesViewController {
        let childVc = UIStoryboard.init(name: "SportCircle", bundle: nil).instantiateViewController(withIdentifier: "CDSportCircleUnreadMessagesViewController") as! CDSportCircleUnreadMessagesViewController
        childVc.messageType = messageType
        weak var weakSelf = self
        childVc.viewControllerTransform = { (viewControllerObj) in
            guard let strongSelf = weakSelf else {
                return
            }
            strongSelf.navigationController?.pushViewController(viewControllerObj!, animated: true)
        }
        return childVc
    }
    
    func doSomethingAfterEndScrollEvent() {
        let currentIndex = NSInteger((scrollView.width/2 + scrollView.contentOffset.x)/scrollView.width)
        if pageIndex != currentIndex {
            pageIndex = currentIndex
            self.tapButtonDidSelected(tapButtonsCollection[pageIndex])
        }
    }
    
    func tapButtonDidSelected(_ selectedButton: UIButton?) {
        guard let validButton = selectedButton else {
            return
        }
        
        for buttonObj in tapButtonsCollection {
            if buttonObj == validButton {
                buttonObj.setTitleColor(UIColor.init(hexString: kSelectedTapTitleColorHexString), for: UIControlState.normal)
                buttonObj.setTitleColor(UIColor.init(hexString: kSelectedTapTitleColorHexString), for: UIControlState.selected)
                buttonObj.setTitleColor(UIColor.init(hexString: kSelectedTapTitleColorHexString), for: UIControlState.highlighted)
                
                buttonObj.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
            } else {
                buttonObj.setTitleColor(UIColor.init(hexString: kNormalTapTitleColorHexString), for: UIControlState.normal)
                buttonObj.setTitleColor(UIColor.init(hexString: kNormalTapTitleColorHexString), for: UIControlState.selected)
                buttonObj.setTitleColor(UIColor.init(hexString: kNormalTapTitleColorHexString), for: UIControlState.highlighted)
                
                buttonObj.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
            }
        }
        
        let point = CGPoint.init(x: CGFloat(pageIndex) * scrollView.width, y: 0)
        scrollView.setContentOffset(point, animated: true)
    }
    
    func bottomIndexViewMoveTo(_ offset: CGFloat) {
        let offsetPercent = offset / (scrollView.contentSize.width - scrollView.width)
        let moveRange = praiseMessageButton.centerX - allMessageButton.centerX
        bottomIndexView?.centerX = allMessageButton.centerX + moveRange * offsetPercent
    }
}
