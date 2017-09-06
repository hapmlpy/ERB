//
//  BinInfromationViewController.swift
//  Environment Behavior
//
//  Created by JIAN LI on 9/4/17.
//  Copyright © 2017 JIAN LI. All rights reserved.
//

import UIKit
import Hero
import SnapKit

class BinInfromationViewController: UIViewController {
  let pro = MapVCProperties()
  @IBOutlet weak var brandView: UIView!
  @IBOutlet weak var barView: UIView!
  @IBOutlet weak var postTable: UIView!
  @IBOutlet weak var profileView: UIImageView!
  
  var profileImage = UIImage()
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    setupHeader()
    
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
  
  func setupHeader(){
    setupHeaderConstrains()
    isHeroEnabled = true
    brandView.heroID = "brand"
    brandView.heroModifiers = [.duration(0)]
    brandView.backgroundColor = pro.color1
    brandView.alpha = 0
    
    profileView.image = UIImage(named: "binM")
    profileView?.heroID = "profile"
    
    barView.heroID = "bar"
    barView.heroModifiers = [.duration(0)]
    barView.backgroundColor = pro.color2
    
    //postTable.heroModifiers = [.delay(0)]
  }
  
  func setupHeaderConstrains(){
    brandView.snp.makeConstraints{ (make) in
      make.top.equalTo(self.view)
      make.left.equalTo(self.view)
      make.right.equalTo(self.view)
      make.height.equalTo(self.view.bounds.height*0.25)
    }
    profileView.snp.makeConstraints{ (make) in
      make.width.equalTo(pro.widthBig*0.2)
      make.height.equalTo(pro.widthBig*0.2)
      make.centerX.equalTo(brandView.snp.centerX)
      make.centerY.equalTo(brandView.snp.centerY).offset(-8)
    }
    barView.snp.makeConstraints{ (make) in
      make.top.equalTo(brandView.snp.bottom)
      make.width.equalTo(self.view)
      make.height.equalTo(self.view.bounds.height*0.18)
    }
//    postTable.snp.makeConstraints{ (make) in
//      make.top.equalTo(barView.snp.bottom)
//      make.width.equalTo(self.view)
//      make.height.equalTo(self.view.bounds.height*(0.57))
//    }
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
