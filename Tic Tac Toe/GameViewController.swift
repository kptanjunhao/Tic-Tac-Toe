//
//  ViewController.swift
//  Tic Tac Toe
//
//  Created by 谭钧豪 on 16/4/10.
//  Copyright © 2016年 谭钧豪. All rights reserved.
//

import UIKit

enum LineType: Int {
    case vertical1 = 0
    case vertical2 = 1
    case horizontal1 = 2
    case horizontal2 = 3
}

class Line: UIView {
    init(screenFrame: CGRect,lineType:LineType) {
        var frame:CGRect!
        let playAreaLength = screenFrame.width - 40
        switch lineType {
        case LineType.vertical1:
            frame = CGRectMake(20 + playAreaLength/3,
                                   screenFrame.height/2 - playAreaLength/2,
                                   2,
                                   playAreaLength)
        case LineType.vertical2:
            frame = CGRectMake(20 + 2*playAreaLength/3,
                               screenFrame.height/2 - playAreaLength/2,
                               2,
                               playAreaLength)
        case LineType.horizontal1:
            frame = CGRectMake(20,
                               screenFrame.height/2 - playAreaLength/6,
                               playAreaLength,
                               2)
        case LineType.horizontal2:
            frame = CGRectMake(20,
                               screenFrame.height/2 + playAreaLength/6,
                               playAreaLength,
                               2)
        }
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class GameViewController: UIViewController {
    
    var screen = UIScreen.mainScreen().bounds
    var isCircle:Bool = false
    var posHasView = [Int:Bool]()
    var posIsCircle = [Int:Bool]()
    var gameOverStatu = false
    var playerWillNotWin = false
    
    var robotMode = false
    var robotshape = "circle"
    var robotFirst = true
    var robotNext:Int?
    var robotPos = [Int]()
    
    
    var circlePos = [Int]()
    var crossPos = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.grayColor()
        self.addBoard()
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func resetGame(){
        for view in self.view.subviews{
            if view.tag == 9{
                view.removeFromSuperview()
            }
        }
        for i in 0...8{
            posHasView[i] = false
        }
        isCircle = false
        posIsCircle = [Int:Bool]()
        gameOverStatu = false
        
        robotFirst = true
        robotNext = nil
        robotPos = [Int]()
        preventDetectedPos = [Int]()
        
        circlePos = [Int]()
        crossPos = [Int]()
        gameInit()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        gameInit()
        
    }
    
    func gameInit(){
        let offensiveAlert = UIAlertController(title: "提示", message: "谁先手", preferredStyle: UIAlertControllerStyle.Alert)
        let robotStart = UIAlertAction(title: "机器先手", style: UIAlertActionStyle.Default) { (robotStart) in
            self.addRobotPos()
            self.robotshape = "cross"
            let playerWillNotWinAlert = UIAlertController(title: "选择模式", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            playerWillNotWinAlert.addAction(UIAlertAction(title: "你不可能赢模式", style: UIAlertActionStyle.Destructive, handler: { (alert) in
                self.playerWillNotWin = true
            }))
            playerWillNotWinAlert.addAction(UIAlertAction(title: "呆瓜电脑模式", style: UIAlertActionStyle.Default, handler: { (action) in
                self.playerWillNotWin = false
            }))
            self.presentViewController(playerWillNotWinAlert, animated: true, completion: nil)
            
        }
        let playerStart = UIAlertAction(title: "玩家先手", style: UIAlertActionStyle.Default, handler: {(robotStart) in
            self.robotshape = "circle"
            let playerWillNotWinAlert = UIAlertController(title: "选择模式", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            playerWillNotWinAlert.addAction(UIAlertAction(title: "聪明电脑模式", style: UIAlertActionStyle.Destructive, handler: { (alert) in
                self.playerWillNotWin = true
            }))
            playerWillNotWinAlert.addAction(UIAlertAction(title: "呆瓜电脑模式", style: UIAlertActionStyle.Default, handler: { (action) in
                self.playerWillNotWin = false
            }))
            self.presentViewController(playerWillNotWinAlert, animated: true, completion: nil)

        })
        offensiveAlert.addAction(robotStart)
        offensiveAlert.addAction(playerStart)
        if robotMode{self.presentViewController(offensiveAlert, animated: true, completion: nil)}
    }
    
    func addBoard(){
        let boardLength = screen.width - 20
        let backgroundView = UIImageView(frame: CGRectMake(10,
            screen.height/2 - boardLength/2,
            boardLength,
            boardLength))
        backgroundView.image = UIImage(named: "boardBackground")
        self.view.addSubview(backgroundView)
        for i in 0...3{
            let line = Line(screenFrame: screen, lineType: LineType(rawValue: i)!)
            self.view.addSubview(line)
        }
        for i in 0...8{
            posHasView[i] = false
        }
        
    }
    
    func circle(position:Int){
        let x: CGFloat = 24 + CGFloat(position%3) * (screen.width - 40)/3
        let y: CGFloat = (screen.height/2 - (screen.width - 40)/2) + 4 + CGFloat(position/3) * (screen.width - 40)/3
        let length = (screen.width - 40)/3 - 10
        let view = UIView(frame: CGRectMake(x + length/2,y + length/2,0,0))
        view.tag = 9
        view.layer.borderColor = UIColor.whiteColor().CGColor
        view.layer.borderWidth = 10
        UIView.animateWithDuration(0.4, animations: {
            view.frame = CGRectMake(x, y, length, length)
            view.layer.cornerRadius = length/2
            }) { (complete) in
                
        }
        self.view.addSubview(view)
    }
    
    func cross(position:Int){
        let x: CGFloat = 24 + CGFloat(position%3) * (screen.width - 40)/3
        let y: CGFloat = (screen.height/2 - (screen.width - 40)/2) + 4 + CGFloat(position/3) * (screen.width - 40)/3
        let length = (screen.width - 40)/3 - 10
        let view = UIView(frame: CGRectMake(x,y,length,length))
        view.tag = 9
        view.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
        let line1 = UIView(frame: CGRectMake(length/2-5,0,10,0))
        line1.backgroundColor = UIColor.whiteColor()
        view.addSubview(line1)
        let line2 = UIView(frame: CGRectMake(0,length/2-5,0,10))
        line2.backgroundColor = UIColor.whiteColor()
        view.addSubview(line2)
        UIView.animateWithDuration(0.2, animations: {
            line1.frame.size = CGSizeMake(10, length)
            }) { (complete) in
                UIView.animateWithDuration(0.2, animations: {
                    line2.frame.size = CGSizeMake(length, 10)
                })
        }
        self.view.addSubview(view)
    }
    
    func calcPostion(location:CGPoint) -> Int{
        let x = Int((location.x-20)/((screen.width - 40)/3))
        let y = Int((location.y-(screen.height/2-(screen.width - 40)/2))/((screen.width - 40)/3))
        return (x+y*3 >= 0 && x+y*3 <= 8) && !posHasView[x+y*3]! ? x+y*3 : -1
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var location:CGPoint!
        for touch in touches{
            location = touch.locationInView(self.view)
        }
        let position = calcPostion(location)
        if position == -1{return}
        addPos(position)
        if robotMode && circlePos.count + crossPos.count != 9 && !gameOverStatu{
            addRobotPos()
        }
    }
    
    
    var preventDetectedPos = [Int]()
    func addRobotPos(){
        if robotFirst{
            robotFirst = false
            if !posHasView[4]!{
                addPos(4)
                robotPos.append(4)
            }else{
                while true{
                    let randomPos = Int(arc4random()%9)
                    if !posHasView[randomPos]!{
                        addPos(randomPos)
                        robotPos.append(randomPos)
                        break
                    }
                }
            }
        }else{
            if playerWillNotWin{
                    let playArray = robotshape == "cross" ? circlePos : crossPos
                    for i in 0..<playArray.count{
                        for j in i..<playArray.count{
                            let iPosArry = self.possibilityArray(playArray[i])
                            for pos in iPosArry {
                                if playArray[j] == pos{
                                    var preventPos = 0
                                    let index = iPosArry.indexOf(pos)!.advancedBy(0)
                                    if index%2 == 0{
                                        preventPos = iPosArry[index + 1]
                                        var detectedStatu = true
                                        for preventedPos in preventDetectedPos{
                                            if preventPos == preventedPos{
                                                detectedStatu = false
                                            }
                                        }
                                        if detectedStatu == false{continue}
                                        else if posHasView[preventPos]!{
                                            makeRandomRobotPos()
                                            return
                                        }
                                        addPos(preventPos)
                                        robotPos.append(preventPos)
                                    }else{
                                        preventPos = iPosArry[index - 1]
                                        var detectedStatu = true
                                        for preventedPos in preventDetectedPos{
                                            if preventPos == preventedPos{
                                                detectedStatu = false
                                            }
                                        }
                                        if detectedStatu == false{continue}
                                        else if posHasView[preventPos]!{
                                            makeRandomRobotPos()
                                            return
                                        }
                                        addPos(preventPos)
                                        robotPos.append(preventPos)
                                    }
                                    preventDetectedPos.append(preventPos)
                                    return
                                }
                            }
                        }
                    }
            }

            if robotNext == nil{
                
                let array = self.possibilityArray(robotPos.last!)
                var canMakeCondition = false
                for i in 1...(array.count/2){
                    let curSearch1 = array[i*2 - 2]
                    let curSearch2 = array[i*2 - 1]
                    if !posHasView[curSearch1]! && !posHasView[curSearch2]!{
                        canMakeCondition = true
                    }
                }
                if canMakeCondition{
                    while true {
                        let random = Int(arc4random()%UInt32(array.count/2)) + 1
                        let cur = array[random*2 - 2]
                        let next = array[random*2 - 1]
                        if !posHasView[cur]! && !posHasView[next]!{
                            addPos(cur)
                            robotPos.append(cur)
                            robotNext = next
                            break
                        }
                    }
                }else{
                    makeRandomRobotPos()
                }
                
            }else{
                if !posHasView[robotNext!]!{
                    addPos(robotNext!)
                    robotPos.append(robotNext!)
                }else{
                    makeRandomRobotPos()
                }
                
                
                robotNext = nil
            }
            
        }
    }
    
    func makeRandomRobotPos(){
        while true{
            let randomPos = Int(arc4random()%9)
            if !posHasView[randomPos]!{
                addPos(randomPos)
                robotPos.append(randomPos)
                break
            }
        }
    }
    
    func addPos(position:Int){
        if isCircle{
            circle(position)
            circlePos.append(position)
            posIsCircle[position] = true
        }else{
            cross(position)
            crossPos.append(position)
            posIsCircle[position] = false
        }
        posHasView[position] = true
        isCircle = !isCircle
        detectGameStatu()
    }
    
    func detectGameStatu(){
        var shape = ""
        for pos in posHasView.keys{
            if posHasView[pos]!{
                let array = possibilityArray(pos)
                for i in 1...(array.count/2){
                    let curSearch1 = array[i*2 - 2]
                    let curSearch2 = array[i*2 - 1]
                    if posHasView[curSearch1]! && posHasView[curSearch2]!{
                        if (posIsCircle[pos]! == posIsCircle[curSearch2]!) && (posIsCircle[pos]! == posIsCircle[curSearch1]!){
                            gameOverStatu = true
                            shape = posIsCircle[pos]! ? "圆圈" : "叉叉"
                        }
                    }
                }
                
            }
        }
        if circlePos.count + crossPos.count == 9 || gameOverStatu{//游戏结束
            var message = "游戏结束，平局"
            if gameOverStatu{message = "游戏结束 \(shape) 赢"}
            let finishAlert = UIAlertController(title: "提示", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            finishAlert.addAction(UIAlertAction(title: "查看棋局", style: UIAlertActionStyle.Default, handler: nil))
            finishAlert.addAction(UIAlertAction(title: "返回主界面", style: UIAlertActionStyle.Default, handler: {
                (action) in
                self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            }))
            finishAlert.addAction(UIAlertAction(title: "重置游戏", style: UIAlertActionStyle.Destructive, handler: { (action) in
                self.resetGame()
            }))
            self.presentViewController(finishAlert, animated: true, completion: nil)
        }
        
    }
    
    
    
    func possibilityArray(lastpos:Int) -> [Int]{
        switch lastpos {
        case 0:
            return [1,2,3,6,4,8]
        case 1:
            return [0,2,4,7]
        case 2:
            return [1,0,4,6,5,8]
        case 3:
            return [0,6,4,5]
        case 4:
            return [0,8,1,7,2,6,3,5]
        case 5:
            return [2,8,4,3]
        case 6:
            return [0,3,7,8,4,2]
        case 7:
            return [4,1,6,8]
        case 8:
            return [0,4,5,2,7,6]
        default:
            return []
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

