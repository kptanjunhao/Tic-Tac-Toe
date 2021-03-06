//
//  FirstViewController.swift
//  Tic Tac Toe
//
//  Created by 谭钧豪 on 16/4/11.
//  Copyright © 2016年 谭钧豪. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    
    var gamemode = 0
    
    var screen = UIScreen.main.bounds
    override func viewDidLoad() {
        super.viewDidLoad()
        let mutiplePlayerBtn = UIButton(type: .system)
        mutiplePlayerBtn.tag = 101
        mutiplePlayerBtn.addTarget(self, action: #selector(self.start(_:)), for: .touchUpInside)
        mutiplePlayerBtn.frame = CGRectMake(screen.width/2 - 50, screen.height/2 - 45, 100, 30)
        mutiplePlayerBtn.layer.cornerRadius = 8
        mutiplePlayerBtn.setTitle("多人游戏", for: .normal)
        mutiplePlayerBtn.setTitleColor(UIColor.white, for: .normal)
        mutiplePlayerBtn.backgroundColor = UIColor(red:0.05, green:0.60, blue:0.99, alpha:1.00)
        self.view.addSubview(mutiplePlayerBtn)
        let singlePlayerBtn = UIButton(type: .system)
        singlePlayerBtn.tag = 102
        singlePlayerBtn.addTarget(self, action: #selector(self.start(_:)), for: .touchUpInside)
        singlePlayerBtn.frame = CGRectMake(screen.width/2 - 50, screen.height/2 + 45, 100, 30)
        singlePlayerBtn.layer.cornerRadius = 8
        singlePlayerBtn.setTitle("单人游戏", for: .normal)
        singlePlayerBtn.setTitleColor(UIColor.white, for: .normal)
        singlePlayerBtn.backgroundColor = UIColor(red:0.05, green:0.60, blue:0.99, alpha:1.00)
        self.view.addSubview(singlePlayerBtn)
        // Do any additional setup after loading the view.
    }
    
    @objc func start(_ sender:UIButton) {
        gamemode = sender.tag
        self.performSegue(withIdentifier: "start", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "start"{
            if gamemode == 102{
                let desVC = segue.destination as! GameViewController
                desVC.robotMode = true
            }
        }
    }
    

}
