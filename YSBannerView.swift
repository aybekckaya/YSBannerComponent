//
//  YSBannerView.swift
//  YSBannerComponent
//
//  Created by aybek can kaya on 17/06/2017.
//  Copyright © 2017 aybek can kaya. All rights reserved.
//

import UIKit

protocol YSBannerViewDataSource {
    func ysBannerViewAtIndex(bannerView:YSBannerView , index:Int)->UIView
    func ysBannerNumberOfItems(bannerView:YSBannerView)->Int
}

protocol YSBannerViewDelegate {
    func ysBannerViewDidSelectedAtIndex(bannerView:YSBannerView , index:Int)
}


class YSBannerView: UIView {

    // options
    var showsPageControl:Bool = false {
        didSet {
            pageController.isHidden = !showsPageControl
        }
    }
    
    var duration:Double = 3.0 {
        didSet {
            
        }
    }
    
    var pageControllerTintColor:UIColor = UIColor.white
    var pageControllerSelectedTintColor:UIColor = UIColor.red
    var pageControllerBackgroundColor:UIColor = UIColor.black
    
    var delegateBannerView:YSBannerViewDelegate?
    var datasourceBannerView:YSBannerViewDataSource?
    
    fileprivate var scrollViewComponent:UIScrollView = UIScrollView()
    fileprivate var pageController:UIPageControl = UIPageControl()
    
    fileprivate var numberOfItems:Int = 0
    fileprivate var timerScroll:Timer?

}

// MARK : -Set up
extension YSBannerView {
    func setUp() {
        guard let dataSource = datasourceBannerView else { return }
        scrollViewComponent.removeFromSuperview()
        pageController.removeFromSuperview()
        
        scrollViewComponent = UIScrollView()
        scrollViewComponent.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        scrollViewComponent.delegate = self
        scrollViewComponent.showsHorizontalScrollIndicator = false
        addSubview(scrollViewComponent)
        
        pageController = UIPageControl()
        pageController.frame = CGRect(x: 0, y: frame.height - 50 , width: frame.width, height: 40)
        pageController.currentPage = 0
        pageController.numberOfPages = dataSource.ysBannerNumberOfItems(bannerView: self)
        pageController.pageIndicatorTintColor = pageControllerTintColor
        pageController.currentPageIndicatorTintColor = pageControllerSelectedTintColor
        pageController.tintColor = pageControllerBackgroundColor
        addSubview(pageController)
        
    }
    
    func reloadData() {
        guard let dataSource = datasourceBannerView else { return }
        stopTimer()
        numberOfItems = dataSource.ysBannerNumberOfItems(bannerView: self)
        
        for i in 0...numberOfItems-1 {
            let item = viewItemAtIndex(index: i)
            scrollViewComponent.addSubview(item)
        }
        
        scrollViewComponent.delegate = self
        scrollViewComponent.isPagingEnabled = true
        scrollViewComponent.addSubview(leftHolderView())
        scrollViewComponent.addSubview(rightHolderView())
        
        scrollViewComponent.contentSize = CGSize(width: CGFloat(numberOfItems+2)*frame.width, height: scrollViewComponent.contentSize.height)
        scrollViewComponent.contentOffset = CGPoint(x: frame.width, y: scrollViewComponent.contentOffset.y)
        startTimer()
    }
    
    
    private func leftHolderView()->UIView {
        let item = viewItemAtIndex(index: numberOfItems-1)
        item.frame = CGRect(x: 0, y: 0, width: item.frame.size.width, height: item.frame.size.height)
        return item
    }
    
    private func rightHolderView()->UIView {
        let item = viewItemAtIndex(index: 0)
        item.frame = CGRect(x: CGFloat(numberOfItems+1)*frame.size.width, y: 0, width: item.frame.size.width, height: item.frame.size.height)
        return item
    }
    
    private func viewItemAtIndex(index:Int)->UIView {
        guard let dataSource = datasourceBannerView else { return UIView() }
        let view = dataSource.ysBannerViewAtIndex(bannerView: self, index: index)
        view.frame = CGRect(x: CGFloat(index+1)*frame.width, y: 0, width: frame.width, height: frame.height)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(gesture:)) )
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        view.addGestureRecognizer(tapGesture)
        
        return view
    }
    
}

// MARK : - TapGestures
extension YSBannerView {
    func viewTapped(gesture:UITapGestureRecognizer) {
        guard let delegate = delegateBannerView else { return }
        
        delegate.ysBannerViewDidSelectedAtIndex(bannerView: self, index: pageController.currentPage)
    }
}


// MARK : - Timers
extension YSBannerView {
    func startTimer() {
        timerScroll = Timer.scheduledTimer(withTimeInterval: duration, repeats: true, block: { theTimer in
            self.scrollToNextItem()
        })
    }
    
    func stopTimer() {
        timerScroll?.invalidate()
        timerScroll = nil
    }
    
    fileprivate func scrollToNextItem() {
        let nextOffset = CGPoint(x: scrollViewComponent.contentOffset.x+frame.width, y: scrollViewComponent.contentOffset.y)
        scrollViewComponent.setContentOffset(nextOffset, animated: true)
    }

}



extension YSBannerView:UIScrollViewDelegate {
 
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
       updateContentOffsetIfNeeded(scrollView: scrollView)
       updatePageControl(scrollView: scrollView)
    }
    
    private func updateContentOffsetIfNeeded(scrollView:UIScrollView) {
        if scrollView.contentOffset.x <= 0 {
            let offset = CGPoint(x: CGFloat(numberOfItems)*scrollView.frame.width, y: 0)
            scrollView.setContentOffset(offset, animated: false)
        }
        else if scrollView.contentOffset.x >= CGFloat(numberOfItems+1)*scrollView.frame.width {
            let offset = CGPoint(x: frame.width, y: 0)
            scrollView.setContentOffset(offset, animated: false)
        }
    }
    
    private func updatePageControl(scrollView:UIScrollView) {
        if scrollView.contentOffset.x <= 0 {
           pageController.currentPage = numberOfItems - 1
           return
        }
        else if scrollView.contentOffset.x >= CGFloat(numberOfItems+1)*scrollView.frame.width {
           pageController.currentPage = 0
           return
        }
        let realContentOffset = scrollView.contentOffset.x - scrollView.frame.size.width
        pageController.currentPage = Int(realContentOffset / scrollView.frame.size.width)
        
    }
    
    func goToPage(index:Int , animated:Bool) {
        guard index >= 0 , index < numberOfItems else { return }
        let point = CGPoint(x: scrollViewComponent.frame.size.width * CGFloat(index+1), y: scrollViewComponent.contentOffset.y)
        scrollViewComponent.setContentOffset(point, animated: animated)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopTimer()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        startTimer()
    }
}





