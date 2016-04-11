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
    /**
    *   初始化线条视图
    *   screenFrame 屏幕大小
    *   lineType 线条类型
    */
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
    var isCircle:Bool = false//当前下的子的形状是否为圆圈
    var posHasView = [Int:Bool]()//纪录点是否被占领的词典数组
    var posIsCircle = [Int:Bool]()//纪录点是否为圆圈的词典数组
    var gameOverStatu = false//游戏结束的标志
    var playerWillNotWin = false//机器人的难度是否为王者级别
    
    var robotMode = false//是否为单人模式
    var robotshape = "circle"//机器人的棋子形状
    var robotFirst = true//机器人是否下它的第一个棋子
    var robotNext:Int?//机器人是否有获胜可能的下一步棋子
    var robotPos = [Int]()//纪录所有机器人下过的棋子位置
    
    
    var circlePos = [Int]()//纪录所有圆圈的位置
    var crossPos = [Int]()//纪录所有叉叉的位置

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.grayColor()
        self.addBoard()
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    ///重置游戏
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
    //当视图完全出现后，弹出提示框
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        gameInit()
        
    }
    //弹出提示框，让玩家选择游戏类型
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
    //向视图中添加背景图以及线条
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
    /**
     *  在指定位置生成一个圆圈视图
     *  position    Int类型的位置，从0-8
     *
     */
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
    /**
     *  在指定位置生成一个叉叉视图
     *  position    Int类型的位置，从0-8
     *
     */
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
    /**
     *  根据给定坐标计算出当前位置
     *  location    屏幕坐标
     *  return  返回Int类型的position位置
     */
    func calcPostion(location:CGPoint) -> Int{
        let x = Int((location.x-20)/((screen.width - 40)/3))
        let y = Int((location.y-(screen.height/2-(screen.width - 40)/2))/((screen.width - 40)/3))
        return (x+y*3 >= 0 && x+y*3 <= 8) && !posHasView[x+y*3]! ? x+y*3 : -1
    }
    //当用户点击屏幕提起手指时的事件
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
    
    ///一个储存已经检测过的位置的数组
    var preventDetectedPos = [Int]()
    ///添加一个机器人棋子
    func addRobotPos(){
        //如果这是机器人的第一枚棋子
        if robotFirst{
            robotFirst = false
            //最优胜率为从中间位置，也就是4开始
            if !posHasView[4]!{
                addPos(4)
                robotPos.append(4)
            }else{//如果4被玩家占领了，则随机生成一个没有被占领位置的棋子
                makeRandomRobotPos()
            }
        }else{//如果这个不是机器人的第一枚棋子
            if playerWillNotWin{//检测当前难度
                    let playArray = robotshape == "cross" ? circlePos : crossPos//判断玩家的棋子形状，然后找到所有玩家的棋子
                    for i in 0..<playArray.count{//循环遍历判断玩家有没有将要胜利的趋势，如果有则阻止玩家胜利
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
            ///在机器人下棋子的时候，如果有胜利的趋势，则会将下一步棋添加至robotNext
            ///如果没有胜利的趋势，则根据上一步，生成一个有可能会胜利的位置的棋子
            ///如果没有这样的条件，就随机生成一个
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
    /**
     *  生成一个随机位置的机器人棋子
     */
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
    
    /**
     *  根据当前位置向屏幕中添加棋子
     *  position    Int类型的位置，0-8
     */
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
    
    ///检测游戏状态，包括是否结束，是否有人获胜。
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
    
    
    /**
     *  根据指定位置，返回可能获胜的数组
     *  lastpos 当前检测的位置
     *  return [Int] 返回一个数组，数组包括当前位置所有可能获胜的位置，以2个为一组
     *  例如当传入1时，会返回[0,2,4,7],其中[0,2]是一组可能胜利,[4,7]也是一组可能的胜利
     */
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

