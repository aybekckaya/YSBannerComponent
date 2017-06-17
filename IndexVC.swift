//
//  IndexVC.swift
//  YSBannerComponent
//
//  Created by aybek can kaya on 17/06/2017.
//  Copyright © 2017 aybek can kaya. All rights reserved.
//

import UIKit

class IndexVC: UIViewController, YSBannerViewDelegate , YSBannerViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        perform(#selector(setUpBannerView), with: nil, afterDelay: 0.1)
    }

    func setUpBannerView() {
        let bannerView = YSBannerView()
        bannerView.frame = CGRect(x: 0, y: 100, width: view.frame.size.width, height: 220)
        bannerView.datasourceBannerView = self
        bannerView.delegateBannerView = self
        bannerView.setUp()
        bannerView.reloadData()
        
        view.addSubview(bannerView)
    }
    
    func ysBannerNumberOfItems(bannerView: YSBannerView) -> Int {
        return 5
    }
    
    func ysBannerViewAtIndex(bannerView: YSBannerView, index: Int) -> UIView {
        let viewBase = UIView()
        viewBase.frame = CGRect(x: 0, y: 0, width: bannerView.frame.size.width, height: bannerView.frame.size.height)
        
        let imView = UIImageView()
        imView.frame = CGRect(x: 0, y: 0, width: viewBase.frame.size.width, height: viewBase.frame.size.height)
        let imageName = String(index+1)+".jpg"
        let image = UIImage(named: imageName)
        imView.image = image
        viewBase.addSubview(imView)
        
        return viewBase
    }
    
    func ysBannerViewDidSelectedAtIndex(bannerView: YSBannerView, index: Int) {
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
