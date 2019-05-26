//
//  GameScene.swift
//  Smash Boltz
//
//  Created by Aditya Abhyankar on 10/15/17.
//  Copyright © 2017 Aditya Abhyankar. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation
import AudioToolbox

import GoogleMobileAds

class GameScene: SKScene, AVAudioPlayerDelegate, GADInterstitialDelegate {
    
    let losingEnabled = true
    var unlocked = 0 {
        didSet {
            UserDefaults.standard.set(unlocked, forKey: "unlocked")
        }
    }
    let checkPoints = [200, 220, 230]
    
    var circles : [Circle] = []
    var bounds : [SKShapeNode] = []
    var boundGlows : [Double] = [0,0,0,0]
    
    var globalGlow = 0.0
    
    static var globalVelocity = vector2(0.0, -10.0)
    var counter = 0.0
    
    var rgb = [0.0,0.0,0.0,1.0]
    static let colors : [UIColor] = [UIColor(red: 1, green: 85/255, blue: 43/255, alpha: 1.0),
                              UIColor(red: 30/255, green: 200/255, blue: 255/255, alpha: 1.0),
                              UIColor(red: 40/255, green: 255/255, blue: 90/255, alpha: 1.0),
                              UIColor(red: 1, green: 220/255, blue: 40/255, alpha: 1.0)]
    
    var score = 0 {
        didSet {
            scoreLabel.text = String(score)
        }
    }
    
    var meterNode : SKShapeNode!
    
    let scoreLabel : SKLabelNode = SKLabelNode()
    let difficultyLabel : SKLabelNode = SKLabelNode()
    static var difficulty = 0
    let modeNames : [String] = ["Easy", "Normal", "Hard", "Insane"]
    
    let lineWidth = CGFloat(60.0)
    
    static var state = 0.0 {
        didSet {
            Circle.gameState = state
        }
    }
    
    var menuNodes : [[SKNode]] = [[]]
    var menuAnimationFrame = CGFloat(0.0)
    var touchedMenuCircle : Circle? = nil
    var menuCircleOriginalPos : [CGPoint] = []
    
    static let gameSong = SKAudioNode(fileNamed: "GameAudio.m4a")
    static let gameSongExpert = SKAudioNode(fileNamed: "ExpertGameAudio.m4a")
    static let gameSongInsane = SKAudioNode(fileNamed: "InsaneGameAudio.m4a")
    let menuSong = SKAudioNode(fileNamed: "MenuSong.m4a")
    static var crashBoom = SKAudioNode(fileNamed: "CrashBoom.m4a")
    let ding = SKAudioNode(fileNamed: "Pop.m4a")
    let ding2 = SKAudioNode(fileNamed: "SynthDing2.m4a")
    
    let littleShake = SKAction.init(named: "Shake")
    let mediumShake = SKAction.init(named: "MediumShake")
    let hugeShake = SKAction.init(named: "HugeShake")
    
    var sparks : SKEmitterNode!
    var discoParticles : SKEmitterNode!
    
    var deviceType = 0
    var deviceFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
    
    struct AppUtility {
        
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
            UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        }
        
    }
    
    var interstitial: GADInterstitial!
    static var viewController : GameViewController!
    var playCount = 0
    
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-3799260471702621/1178175959")
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
    }
    
    override func didMove(to view: SKView) {
          interstitial = createAndLoadInterstitial()
        let request = GADRequest()
        interstitial.load(request)
        
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
        if let s = UserDefaults.standard.object(forKey: "unlocked") {
            unlocked = s as! Int
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch let error as NSError {
            print(error)
        }
        addChild(menuSong)
        
        deviceFrame = frame
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                deviceType = -1
                print("iPhone 5 or 5S or 5C")
            case 1334:
                print("iPhone 6/6S/7/8")
                deviceType = 0
            case 2208:
                deviceType = 1
                print("iPhone 6+/6S+/7+/8+")
            case 2436:
                deviceType = 2
                print("iPhone X")
            default:
                print("unknown")
            }
        } else if UIDevice().userInterfaceIdiom == .pad {
            deviceType = 3
        }
        
        if deviceType == 2 {
            deviceFrame = CGRect(x: frame.minX, y: frame.minY, width: frame.width/1.2, height: frame.height/1)
        } else if deviceType == 3 {
            deviceFrame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height/1.3)
        }
    }
    
    func setUpGame() {
        menuSong.run(SKAction.stop())
        self.removeAllChildren()
        bounds.removeAll()
        
        scoreLabel.text = "0"
//        scoreLabel.fontName = "Copperplate"
        scoreLabel.fontSize = 300
        scoreLabel.fontColor = .black
        scoreLabel.zPosition = -1
        addChild(scoreLabel)
        
        var highscore = 0
        if let s = UserDefaults.standard.object(forKey: "highscore"+String(GameScene.difficulty)) {
            highscore = s as! Int
        }
        
        difficultyLabel.text = String(modeNames[GameScene.difficulty]) + " | Best: " + String(highscore)
//        difficultyLabel.fontName = "Arial Rounded MT Bold"
        difficultyLabel.fontSize = 55
        difficultyLabel.fontColor = .black
        difficultyLabel.zPosition = -1
        difficultyLabel.position.y = scoreLabel.frame.minY - (difficultyLabel.frame.height*2.5)
        addChild(difficultyLabel)
        
        let c = Circle()
        c.isUserInteractionEnabled = true
        c.position = generateRandomPoint()
        c.zPosition = 7
        circles.append(c)
        
        addChild(c)
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -deviceFrame.width/2, y: deviceFrame.height/2))
        path.addLine(to: CGPoint(x: -deviceFrame.width/2, y: -deviceFrame.height/2))
        let blueBound = SKShapeNode(path: path)
        blueBound.lineWidth = lineWidth
        blueBound.strokeColor = GameScene.colors[1]
        
        let path2 = CGMutablePath()
        path2.move(to: CGPoint(x: -deviceFrame.width/2, y: -deviceFrame.height/2))
        path2.addLine(to: CGPoint(x: deviceFrame.width/2, y: -deviceFrame.height/2))
        let greenBound = SKShapeNode(path: path2)
        greenBound.lineWidth = lineWidth
        greenBound.strokeColor = GameScene.colors[2]
        
        let path3 = CGMutablePath()
        path3.move(to: CGPoint(x: deviceFrame.width/2, y: deviceFrame.height/2))
        path3.addLine(to: CGPoint(x: deviceFrame.width/2, y: -deviceFrame.height/2))
        let yellowBound = SKShapeNode(path: path3)
        yellowBound.lineWidth = lineWidth
        yellowBound.strokeColor = GameScene.colors[3]
        
        let path4 = CGMutablePath()
        path4.move(to: CGPoint(x: -deviceFrame.width/2, y: deviceFrame.height/2))
        path4.addLine(to: CGPoint(x: deviceFrame.width/2, y: deviceFrame.height/2))
        let redBound = SKShapeNode(path: path4)
        redBound.lineWidth = lineWidth
        redBound.strokeColor = GameScene.colors[0]
        
        let wrapper = SKShapeNode()
        wrapper.addChild(redBound)
        if deviceType == 2 {
            let roundedRect = SKShapeNode(rect: CGRect(x: -deviceFrame.width/3.5, y: deviceFrame.height/2 - 65, width: 2*deviceFrame.width/3.5, height: 65), cornerRadius: 30.0)
            roundedRect.fillColor = GameScene.colors[0]
            roundedRect.strokeColor = UIColor.clear
            
            wrapper.addChild(roundedRect)
        }
        
        addChild(blueBound)
        addChild(wrapper)
        addChild(greenBound)
        addChild(yellowBound)
        
        bounds.append(redBound)
        bounds.append(blueBound)
        bounds.append(greenBound)
        bounds.append(yellowBound)
        
        if GameScene.difficulty==3 {
            GameScene.gameSongInsane.run(SKAction.play())
            if GameScene.gameSongInsane.parent == nil {
                addChild(GameScene.gameSongInsane)
            }
            
            if let discoParticles = SKEmitterNode(fileNamed: "DiscoParticles.sks") {
                discoParticles.alpha = 0.3
                discoParticles.zPosition = -10
                addChild(discoParticles)
            }
            scoreLabel.fontColor = UIColor.white
            difficultyLabel.fontColor = UIColor.white
            rgb = [0,0,0]
        } else if GameScene.difficulty==2 {
            GameScene.gameSongExpert.run(SKAction.play())
            if GameScene.gameSongExpert.parent == nil {
                addChild(GameScene.gameSongExpert)
            }
        } else {
            GameScene.gameSong.run(SKAction.play())
            if GameScene.gameSong.parent == nil {
                addChild(GameScene.gameSong)
            }
        }
        self.backgroundColor = UIColor(red: CGFloat(rgb[0]), green: CGFloat(rgb[0]), blue: CGFloat(rgb[0]), alpha: 1)
        
        meterNode = SKShapeNode(rect: CGRect(x: -deviceFrame.width/2, y: -3*frame.height/2, width: deviceFrame.width, height: deviceFrame.height), cornerRadius: 10.0)
        meterNode.fillColor = UIColor.orange
        meterNode.strokeColor = UIColor.clear
        meterNode.glowWidth = 2.0
//        meterNode.alpha = 0.1
        meterNode.zPosition = -3
        addChild(meterNode)
        
        ding.autoplayLooped = false
    }
    
    func menuSetup() {
        let chars = ["U", "D", "L", "R"]
        let colorMap = [0, 2, 1, 3]
        self.backgroundColor = .black
        var smallTextData = [("Easy", 0), ("Normal", 0), ("Hard", 0), ("Insane", 0)]
        
        if let s = UserDefaults.standard.object(forKey: "highscore"+String(unlocked)) {
            if unlocked != 3 && (s as! Int) > checkPoints[unlocked] {
                unlocked += 1
            }
        }
        
        for d in 0..<4 {
            if let s = UserDefaults.standard.object(forKey: "highscore"+String(d)) {
                smallTextData[d].1 = s as! Int
//                print("saved: " + String(describing: s))
//                print(smallTextData[d].1)
            } else {
//                print(String(d) + " not saved")
            }
        }
        
        for _ in 0..<6 {
            menuNodes.append([])
        }
        
        for i in 0..<chars.count {
            let letter = SKLabelNode(text: chars[i])
            letter.fontSize = deviceFrame.width * 0.2
            letter.fontColor = GameScene.colors[colorMap[i]]
//            letter.fontName = "American Typewriter Light"
            letter.fontName = "Arial Rounded MT Bold"
//            letter.fontName = "Avenir Next Condensed"
            letter.position.x = CGFloat(i - 2)*(letter.fontSize) + letter.fontSize/2
            letter.position.y = (CGFloat(pow(-1, Double(i))) * letter.fontSize/4) + deviceFrame.height/3.5
            letter.run(SKAction.moveBy(x: 0, y: 30, duration: 0))
            letter.run(SKAction.fadeOut(withDuration: 0))
            menuNodes[0].append(letter)
            addChild(letter)
            letter.run(SKAction.moveBy(x: 0, y: -30, duration: 2))
            letter.run(SKAction.fadeIn(withDuration: 2), completion: {
                let moveUpAction = SKAction.moveBy(x: 0, y: 10, duration: 1.5)
                let moveDownAction = SKAction.moveBy(x: 0, y: -10, duration: 1.7)
                moveUpAction.timingMode = SKActionTimingMode.easeInEaseOut
                moveDownAction.timingMode = SKActionTimingMode.easeInEaseOut
                
                if i%2==0 {
                    letter.run(SKAction.repeatForever(SKAction.sequence([moveUpAction, moveDownAction])))
                } else {
                    letter.run(SKAction.repeatForever(SKAction.sequence([moveDownAction, moveUpAction])))
                }
            })
            
        }
        
        for i in 0..<chars.count {
            
            let circle = Circle()
            circle.direction = i
            
            circle.position.x = CGFloat(pow(-1, Double(i))) * CGFloat(-self.deviceFrame.width/3.5)
            circle.position.y = CGFloat(-(CGFloat(i) * (circle.radius*2.7)) + self.deviceFrame.height/2/12)
            
            if deviceType == 3 {
                circle.radius /= 1.2
                circle.position.x = CGFloat(pow(-1, Double(i))) * CGFloat(-self.deviceFrame.width/3)
                circle.position.y = CGFloat(-(CGFloat(i) * (circle.radius*2.6)) + self.deviceFrame.height/13)
            }
            
            circle.alpha = 0.5
            circle.isUserInteractionEnabled = true
            circle.zPosition = 10
            
            circle.velocity.x = 0
            circle.velocity.y = 0
            menuNodes[1].append(circle)
            menuCircleOriginalPos.append(circle.position)
            addChild(circle)
            
            let capsule = SKShapeNode(rect: CGRect(x: CGFloat(pow(-1, Double(i))) * circle.position.x-circle.radius,y: circle.position.y-circle.radius,width: (abs(circle.position.x) + circle.radius)*2,height: circle.radius*2), cornerRadius: circle.radius)
            
            capsule.strokeColor = .clear
            capsule.fillColor = GameScene.colors[i]
            capsule.alpha = circle.alpha * 0.25
            menuNodes[2].append(capsule)
            addChild(capsule)
            
            let difficultyText = SKLabelNode(text: smallTextData[3-i].0)
//            difficultyText = circle.position.x + (CGFloat(pow(-1, Double(i))) * 1.5*(circle.radius * 2))
            difficultyText.position.y = circle.position.y - capsule.frame.height/5.5
            difficultyText.fontSize = deviceFrame.width * 0.08
            difficultyText.alpha = 1.0
            menuNodes[3].append(difficultyText)
            addChild(difficultyText)
            
            let highScoreText = SKLabelNode(text: String(smallTextData[3-i].1))
            highScoreText.position.x = (capsule.position.x + (CGFloat(pow(-1, Double(i))) * capsule.frame.width/2*0.7))
            highScoreText.position.y = circle.position.y - capsule.frame.height/8
            highScoreText.alpha = 0.5
            highScoreText.fontSize += 20
            menuNodes[4].append(highScoreText)
            addChild(highScoreText)
            
            let messageText = SKLabelNode(text: "Swipe in a direction to play")
            messageText.position.y = deviceFrame.height/5.5
            messageText.run(SKAction.repeatForever(SKAction.sequence([SKAction.fadeOut(withDuration: 1), SKAction.fadeIn(withDuration: 1)])))
            menuNodes[5].append(messageText)
            addChild(messageText)
            
            if i < 3-unlocked {
                circle.isHidden = true
                capsule.alpha = 0.05
                if i==3-unlocked-1 {
                    difficultyText.text = String(checkPoints[3-i-1]) + " to unlock"
                    difficultyText.fontColor = GameScene.colors[3-unlocked]
                } else {difficultyText.text = "?"}
                difficultyText.alpha = 0.5
                highScoreText.isHidden = true
                circle.isUserInteractionEnabled = false
            }
            
            GameScene.state = 0.5
        }
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -deviceFrame.width/2, y: deviceFrame.height/2))
        path.addLine(to: CGPoint(x: -deviceFrame.width/2, y: -deviceFrame.height/2))
        let blueBound = SKShapeNode(path: path)
        blueBound.lineWidth = lineWidth
        blueBound.strokeColor = GameScene.colors[1]
        
        let path2 = CGMutablePath()
        path2.move(to: CGPoint(x: -deviceFrame.width/2, y: -deviceFrame.height/2))
        path2.addLine(to: CGPoint(x: deviceFrame.width/2, y: -deviceFrame.height/2))
        let greenBound = SKShapeNode(path: path2)
        greenBound.lineWidth = lineWidth
        greenBound.strokeColor = GameScene.colors[2]
        
        let path3 = CGMutablePath()
        path3.move(to: CGPoint(x: deviceFrame.width/2, y: deviceFrame.height/2))
        path3.addLine(to: CGPoint(x: deviceFrame.width/2, y: -deviceFrame.height/2))
        let yellowBound = SKShapeNode(path: path3)
        yellowBound.lineWidth = lineWidth
        yellowBound.strokeColor = GameScene.colors[3]
        
        let path4 = CGMutablePath()
        path4.move(to: CGPoint(x: -deviceFrame.width/2, y: deviceFrame.height/2))
        path4.addLine(to: CGPoint(x: deviceFrame.width/2, y: deviceFrame.height/2))
        let redBound = SKShapeNode(path: path4)
        redBound.lineWidth = lineWidth
        redBound.strokeColor = GameScene.colors[0]
        
        let wrapper = SKShapeNode()
        wrapper.addChild(redBound)
        if deviceType == 2 {
            let roundedRect = SKShapeNode(rect: CGRect(x: -deviceFrame.width/3.5, y: deviceFrame.height/2 - 65, width: 2*deviceFrame.width/3.5, height: 65), cornerRadius: 30.0)
            roundedRect.fillColor = GameScene.colors[0]
            roundedRect.strokeColor = UIColor.clear
            roundedRect.alpha /= 2
            
            wrapper.addChild(roundedRect)
        }
        
        addChild(blueBound)
        addChild(wrapper)
        addChild(greenBound)
        addChild(yellowBound)
        
        bounds.append(redBound)
        bounds.append(blueBound)
        bounds.append(greenBound)
        bounds.append(yellowBound)
        
        for b in bounds {
            b.alpha = 0.5
        }
    }
    
    func menuLoop() {
        
        let d = Int(arc4random_uniform(UInt32(300)))
        
        var shakeScene : SKAction? = nil
        
        if d==0 {
            shakeScene = SKAction.init(named: "Shake")!
        } else if d==50 {
            shakeScene = SKAction.init(named: "Shake2")
        }
        
        for node in self.children {
            if node != menuSong && node != GameScene.gameSong && node != GameScene.gameSongExpert && node != GameScene.gameSongInsane {
                if shakeScene != nil {
                    node.run(shakeScene!)
                }
                
                if d<5 && Int(arc4random_uniform(UInt32(200)))<50 {
                    node.run(SKAction.sequence([SKAction.run({node.alpha *= 2}), SKAction.wait(forDuration: 0.1), SKAction.run {node.alpha /= 2}]))
                }
            }
        }
        
        
    }
    
    func menuAnimation() {
        let boundIndex = menuNodes[1].index(of: touchedMenuCircle!)!
        
        if menuAnimationFrame < 1.0 {
            if boundIndex==0 {
                menuAnimationFrame = max(0, 1.0 - abs(deviceFrame.height/2 - (touchedMenuCircle?.position.y)!) / abs(deviceFrame.height/2 - menuCircleOriginalPos[boundIndex].y))
            } else if boundIndex==1 {
                menuAnimationFrame = max(0, 1.0 - abs(deviceFrame.width/2 + (touchedMenuCircle?.position.x)!) / abs(deviceFrame.width/2 + menuCircleOriginalPos[boundIndex].x))
            } else if boundIndex==2 {
                menuAnimationFrame = max(0, 1.0 - abs(deviceFrame.height/2 + (touchedMenuCircle?.position.y)!) / abs(deviceFrame.height/2 + menuCircleOriginalPos[boundIndex].y))
            } else if boundIndex==3 {
                menuAnimationFrame = max(0, 1.0 - abs(deviceFrame.width/2 - (touchedMenuCircle?.position.x)!) / abs(deviceFrame.width/2 - menuCircleOriginalPos[boundIndex].x))
            }
        }
        
        for i in menuNodes {
            for n in i {
                if !(menuNodes[0].contains(n) || touchedMenuCircle==n) {
                    var originalFade = 0.5
                    if menuNodes[2].contains(n) {
                        originalFade = 0.5 * 0.25
                    }
                    if menuNodes[3].contains(n) {
                        originalFade = 1.0
                    }
                    n.alpha = CGFloat(min(originalFade, Double(1.0 - menuAnimationFrame)))
                } else if !(touchedMenuCircle==n) {
                    n.zRotation = menuAnimationFrame * CGFloat(pow(-1.0, Double(menuNodes[0].index(of: n)!)))
                    
                    if menuNodes[0].index(of: n) == 0 {
                        let originalYPos = (CGFloat(pow(-1, Double(menuNodes[0].index(of: n)!))) * (n as! SKLabelNode).fontSize/4) + deviceFrame.height/3.5
                        n.position.y = originalYPos + (menuAnimationFrame * abs(deviceFrame.height/2 - originalYPos))
                    } else if menuNodes[0].index(of: n) == 1 {
                        let originalYPos = (CGFloat(pow(-1, Double(menuNodes[0].index(of: n)!))) * (n as! SKLabelNode).fontSize/4) + deviceFrame.height/3.5
                        n.position.y = originalYPos - (menuAnimationFrame * (originalYPos + deviceFrame.height/2))
                    } else if menuNodes[0].index(of: n) == 2 {
                        let originalXPos = CGFloat(menuNodes[0].index(of: n)! - 2)*((n as! SKLabelNode).fontSize) + (n as! SKLabelNode).fontSize/2
                        n.position.x = originalXPos - (menuAnimationFrame * (originalXPos + deviceFrame.width/2))
                    } else if menuNodes[0].index(of: n) == 3 {
                        let originalXPos = CGFloat(menuNodes[0].index(of: n)! - 2)*((n as! SKLabelNode).fontSize) + (n as! SKLabelNode).fontSize/2
                        n.position.x = originalXPos + (menuAnimationFrame * abs(originalXPos - deviceFrame.width/2))
                    }
                }
            }
        }
    }
        
    
    override func update(_ currentTime: TimeInterval) {
        
        if GameScene.state==0 {
            menuSetup()
        }
        
        if GameScene.state==0.5 {
            menuLoop()
            for c in menuNodes[1] {
                c.isUserInteractionEnabled = true
                if (c as! Circle).touched {
                    touchedMenuCircle = (c as! Circle)
                    touchedMenuCircle?.alpha = 1.0
                    GameScene.state = 1.0
                }
            }
        }
        
        if GameScene.state==1 {
            
            for c in menuNodes[1] {
                if c != touchedMenuCircle {
                    c.isUserInteractionEnabled = false
                }
            }
            
            menuAnimation()
            
            for b in bounds {
                if (touchedMenuCircle?.frame.intersects(b.frame))! {
                    if menuNodes[1].index(of: touchedMenuCircle!)==bounds.index(of: b) {
                        menuAnimationFrame = 1.5
                        menuAnimation()
                        boundGlows[bounds.index(of: b)!] += 125 / 25
                        GameScene.state = 1.5
                        GameScene.difficulty = 3 - bounds.index(of: b)!
//                        print(GameScene.difficulty)
                    } else if !(touchedMenuCircle?.fingered)! {
                        goBackToMenuLoop()
                    }
                }
            }
            
            if menuAnimationFrame==0.0{
                GameScene.state = 0.5
            }
            
            if !(touchedMenuCircle?.fingered)! && touchedMenuCircle?.position != menuCircleOriginalPos[menuNodes[1].index(of: touchedMenuCircle!)!] {
                touchedMenuCircle!.position.x += CGFloat(touchedMenuCircle!.velocity.x)
                touchedMenuCircle!.position.y += CGFloat(touchedMenuCircle!.velocity.y)
            }
            
            if sqrt(pow((touchedMenuCircle?.velocity.x)!, 2) + pow((touchedMenuCircle?.velocity.y)!, 2)) < 5 {
                goBackToMenuLoop()
            }
        }
        
        if GameScene.state==1.5 {
            if GameScene.difficulty==3 {
                fadeBackground(toRGB: [0, 0, 0, 0], incr: 10)
            } else {
                fadeBackground(toRGB: [255, 255, 255, 255], incr: 10)
            }
            touchedMenuCircle?.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.25), SKAction.wait(forDuration: 1)]), completion: setStateTo2)
            for b in bounds {
                let x = boundGlows[bounds.index(of: b)!]
                if x != 0 {
                    boundGlows[bounds.index(of: b)!] = (x + (125 / 25)).truncatingRemainder(dividingBy: 125)
                }
                
                b.glowWidth = CGFloat(100 * sin(0.025*x))
            }
        }
        
        if GameScene.state==2 {
            self.removeAllActions()
//            print(self.hasActions())
            rgb = [255.0, 255.0, 255.0, 255.0, 1.0]
            setUpGame()
            GameScene.state = 3
            GameScene.globalVelocity.y = -10.0
        }
        
        if GameScene.state==3 {
            if (circles.isEmpty || circles.last!.position.y<deviceFrame.height/4  || circles.last!.touched) {
                let c = Circle()
                c.isUserInteractionEnabled = true
                c.position = generateRandomPoint()
                c.zPosition = 7
                circles.append(c)
                addChild(c)
            }

            globalGlow = ((globalGlow + 1.5).truncatingRemainder(dividingBy: (81.0)))

            for c in circles {
                for b in bounds {
                    if (c.touched && c.frame.intersects(b.frame)) || (c.position.y < -deviceFrame.height/2 - lineWidth) {
                        circles.remove(at: circles.index(of: c)!)
                        c.removeFromParent()
                        if c.touched {
                            handleExit(boundary: bounds.index(of: b)!, circle: c)
                        } else {
                            handleExit(boundary: 2, circle: c)
                        }

                        break
                    }
                }

                if !c.touched || (c.velocity.x == 0 && c.velocity.y == 0) {
                    c.velocity = GameScene.globalVelocity
                }

                if !c.fingered {
                    c.position.x += CGFloat(c.velocity.x)
                    c.position.y += CGFloat(c.velocity.y)
                }

                c.glow = globalGlow

                c.hitbox.setScale((CGFloat(abs(GameScene.globalVelocity.y) / 10.0)))
            }

            for b in bounds {
                let x = boundGlows[bounds.index(of: b)!]
                if x != 0 {
                    boundGlows[bounds.index(of: b)!] = (x + (125 / 25)).truncatingRemainder(dividingBy: 125)
                }

                b.glowWidth = CGFloat(100 * sin(0.025*x))
            }

    //        print(boundGlows)

            counter += 0.003
            GameScene.globalVelocity.y = calculateVelocity(x: counter)
            print(counter)
            
            if meterNode.frame.maxY > -deviceFrame.height/2 {
                meterNode.run(SKAction.moveBy(x: 0, y: -0.001*deviceFrame.height, duration: 1))
            }
            meterNode.alpha = max((meterNode.frame.maxY + deviceFrame.height/2) / deviceFrame.height, 0.3)
            
            if (AVAudioSession.sharedInstance().secondaryAudioShouldBeSilencedHint) && counter==0.003 {
            } else {
                if (counter >= 16.188) {
                    self.backgroundColor = .black
                    scoreLabel.fontColor = .white
                    difficultyLabel.fontColor = .white
                }
                    
                else if (counter > 13.5) {
                    fadeBackground(toRGB: [255.0, 153.0, 153.0], incr: 3)
                }
                    
                else if (counter > 10.7) {
                    fadeBackground(toRGB: [102.0, 200.0, 153.0], incr: 3)
                }
                    
                else if (counter > 5.4) {
                    fadeBackground(toRGB: [64, 0, 128], incr: 3)
                }
                    
                else if (counter > 2.7) {
                    fadeBackground(toRGB: [255, 204, 230], incr: 3)
                    if GameScene.difficulty==3 {
                        scoreLabel.fontColor = UIColor.black
                        difficultyLabel.fontColor = UIColor.black
                    }
                }
            }
        }

        if GameScene.state==4 {
            self.backgroundColor = .red
            scoreLabel.fontColor = .white
            difficultyLabel.fontColor = .white
            
            let key = "highscore"+String(GameScene.difficulty)
            if let s = UserDefaults.standard.object(forKey: key) {
                if score == s as! Int {
                    scoreLabel.fontColor = UIColor.orange
                }
            }

            fadeBackground(toRGB: [0,0,0], incr: 3)

            for b in bounds {
                let x = boundGlows[bounds.index(of: b)!]
                if x != 0 {
                    boundGlows[bounds.index(of: b)!] = (x + (125 / 25)).truncatingRemainder(dividingBy: 125)
                }

                b.glowWidth = CGFloat(100 * sin(0.025*x))
            }

            globalGlow = ((globalGlow + 1.5).truncatingRemainder(dividingBy: (81.0)))

            for c in circles {
                c.glow = globalGlow
            }

            GameScene.crashBoom.run(SKAction.changeVolume(by: -0.005, duration: 0))
        }

        if GameScene.state < 3 {
            if !(AVAudioSession.sharedInstance().secondaryAudioShouldBeSilencedHint) {
                menuSong.run(SKAction.changeVolume(to: 1, duration: 0))
            } else {
                menuSong.run(SKAction.changeVolume(to: 0, duration: 0))
            }
        } else {
            if !(AVAudioSession.sharedInstance().secondaryAudioShouldBeSilencedHint) {
                if GameScene.difficulty == 3 {
                    GameScene.gameSongInsane.run(SKAction.changeVolume(to: 1, duration: 0))
                    
                } else if GameScene.difficulty == 2{
                    GameScene.gameSongExpert.run(SKAction.changeVolume(to: 1, duration: 0))
                } else {
                    GameScene.gameSong.run(SKAction.changeVolume(to: 1, duration: 0))
                }
            } else {
                if GameScene.difficulty == 3 {
                    GameScene.gameSongInsane.run(SKAction.changeVolume(to: 0, duration: 0))
                    
                } else if GameScene.difficulty == 2{
                    GameScene.gameSongExpert.run(SKAction.changeVolume(to: 0, duration: 0))
                } else {
                    GameScene.gameSong.run(SKAction.changeVolume(to: 0, duration: 0))
                }
            }
        }
    }
    
    func setStateTo2() {
        GameScene.state = 2.0
    }
    
    func goBackToMenuLoop() {
        let moveBackAction = SKAction.move(to: menuCircleOriginalPos[menuNodes[1].index(of: touchedMenuCircle!)!], duration: 0.25)
        
        touchedMenuCircle?.velocity.x = 0
        touchedMenuCircle?.velocity.y = 0
        touchedMenuCircle?.touched = false
        touchedMenuCircle?.isUserInteractionEnabled = false
        touchedMenuCircle?.run(moveBackAction, completion: {
            self.menuAnimationFrame = 0.0
        })
    }
    
    func fadeBackground(toRGB: [Double], incr: Double) {
        let increment = incr
        
        let amounts = [increment * sign(toRGB[0] - rgb[0]), increment * sign(toRGB[1] - rgb[1]), increment * sign(toRGB[2] - rgb[2])]
        
        let r = min(abs(rgb[0] + amounts[0]), 255.0)
        let g = min(abs(rgb[1] + amounts[1]), 255.0)
        let b = min(abs(rgb[2] + amounts[2]), 255.0)
        
        rgb = [r, g, b]
        let color = UIColor(red: CGFloat(rgb[0]) / 255.0, green: CGFloat(rgb[1]) / 255.0, blue: CGFloat(rgb[2]) / 255.0, alpha: 1)
        self.backgroundColor = color
        
//        print(self.backgroundColor)
    }
    
    func calculateVelocity(x: Double) -> Double {
        
        switch GameScene.difficulty {
        case 0:
            return -24.0 / (1 + exp(0.5 - (0.09 * x))) //easy mode
        case 1:
            return -26.0 / (1 + exp(0.2 - (0.115 * x))) //normal mode
        case 2:
            return -30 / (1 + exp(0.3 - (0.1 * x))) //hard mode
        case 3:
            return -34.0 / (1 + exp(0.2 - (0.24 * x))) // expert mode
        default:
            return -23.0/(1 + exp(0.5 - (0.05 * x))) //easy mode
        }
    }
    
    func handleExit(boundary: Int, circle: Circle) {

        if ding.parent != nil {
            ding.removeFromParent()
        }
        
        if circle.direction == boundary {
//            ding.run(SKAction.changeVolume(to: 0.15, duration: 0))
            
            if circle.touched {
                score += 1
                addChild(ding)
                ding.run(SKAction.play())
                
                if boundary == 2 {
//                    meterNode.run(SKAction.moveBy(x: 0, y: 0.1 * deviceFrame.height, duration: 0.7))
                }
            }
            boundGlows[boundary] += 125 / 25
            
            //let velocityMag = sqrt(pow(circle.velocity.x, 2) + pow(circle.velocity.y, 2))
            
            var shakeScene:SKAction? = nil
            shakeScene = SKAction.init(named: "Shake")!

                for node in self.children {
                    if node != GameScene.gameSong && node != GameScene.gameSongExpert && node != GameScene.gameSongInsane {
                        node.run(shakeScene!)
                    }
                }
            
        } else if losingEnabled {
            GameScene.state = 4
            
            let key = "highscore"+String(GameScene.difficulty)
            if let s = UserDefaults.standard.object(forKey: key) {
                if (s as! Int) < score {
                    UserDefaults.standard.set(score, forKey: key)
                }
            } else {
                UserDefaults.standard.set(score, forKey: key)
            }
            
            let expandingCircle = SKShapeNode(circleOfRadius: circle.radius)
            expandingCircle.glowWidth = 2
            expandingCircle.lineWidth = 5
            expandingCircle.run(SKAction.scaleX(to: 100, duration: 6))
            expandingCircle.run(SKAction.scaleY(to: 100, duration: 6))
            expandingCircle.position = circle.position
            expandingCircle.strokeColor = GameScene.colors[boundary]
            addChild(expandingCircle)
            
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            GameScene.gameSong.run(SKAction.stop())
            GameScene.gameSongExpert.run(SKAction.stop())
            GameScene.gameSongInsane.run(SKAction.stop())
            
            if GameScene.crashBoom.parent != nil {
                GameScene.crashBoom.removeFromParent()
            }
            GameScene.crashBoom.run(SKAction.changeVolume(to: 1.0, duration: 0))
            addChild(GameScene.crashBoom)
            
            if let sparks = SKEmitterNode(fileNamed: "SmashParticles.sks") {
                sparks.position = circle.position
                sparks.particleColor = circle.circle.fillColor
//                print(sparks.particleColor == circle.circle.fillColor)
                addChild(sparks)
            }
            
            scoreLabel.fontColor = .white
            difficultyLabel.fontColor = .white
            //generate particles
            
            run(SKAction.sequence([SKAction.run {
                let shakeScene = SKAction.init(named: "Shake")
                
                for node in self.children {
                    if node != GameScene.gameSong && node != GameScene.gameSongExpert && node != GameScene.crashBoom && node != GameScene.gameSongInsane {
                        if shakeScene != nil {
                            node.run(shakeScene!)
                        }
                    }
                }
                
                self.scoreLabel.zPosition = 30
                
                }, SKAction.wait(forDuration: 1), SKAction.run {
                    for n in self.children {
                        if n != GameScene.gameSong && n != GameScene.gameSongExpert && n != GameScene.gameSongInsane && n != GameScene.crashBoom && n != self.scoreLabel && n != self.difficultyLabel {
                            n.run(SKAction.fadeOut(withDuration: 1))
                        }
                    }
                }, SKAction.wait(forDuration: 3), SKAction.run {
                    self.resetGame()
                    if self.interstitial.isReady && self.playCount%4==0 && self.playCount>0{
                        self.interstitial.present(fromRootViewController: GameScene.viewController)
                    } else {
                        print("not ready")
                    }
                    self.playCount += 1
                }]))
        }
    }
    
    func resetGame() {
        GameScene.gameSong.run(SKAction.stop())
        GameScene.gameSongExpert.run(SKAction.stop())
        GameScene.gameSongInsane.run(SKAction.stop())
        GameScene.crashBoom.run(SKAction.stop())
        
        for node in self.children {
            if node != GameScene.gameSong && node != GameScene.gameSongExpert && node != GameScene.gameSongInsane && node != GameScene.crashBoom {
                node.removeFromParent()
            }
        }
        
        GameScene.state = 0.0
        removeAllActions()
        menuSong.run(SKAction.play())
        addChild(menuSong)
        score = 0
        GameScene.difficulty = -1
        circles.removeAll()
        bounds.removeAll()
        boundGlows = [0,0,0,0]
        globalGlow = 0.0
        GameScene.globalVelocity = vector2(0.0, -10.0)
        counter = 0
        rgb = [0.0,0.0,0.0,1.0]
        menuNodes = [[]]
        menuAnimationFrame = CGFloat(0.0)
        touchedMenuCircle = nil
        menuCircleOriginalPos = []
    }
    
    func generateSmashParticles(atPoint: CGPoint, dir: Int) {
        let particles = SKEmitterNode(fileNamed: "Spark.sks")
        particles?.position = atPoint
        particles?.particleColor = GameScene.colors[dir]
        particles?.particleColorSequence = nil;
        particles?.particleColorBlendFactor = 1.0;
        particles?.particleLifetime = 0.3
        
        let accelMag = 20000
        
        switch dir {
        case 0:
            particles?.yAcceleration = CGFloat(-accelMag)
        case 1:
            particles?.xAcceleration = CGFloat(accelMag)
        case 2:
            particles?.yAcceleration = CGFloat(accelMag)
        case 3:
            particles?.xAcceleration = CGFloat(-accelMag)
        default: break
        }
        
        particles?.zPosition = 6
        particles?.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.5), SKAction.removeFromParent()]))
        addChild(particles!)
    }
    
    func generateRandomPoint() -> CGPoint {
        return CGPoint(x: Int(arc4random_uniform(UInt32(deviceFrame.width - 4*CGFloat(70) + 1)))+140-Int(deviceFrame.width/2), y: Int(deviceFrame.height/2 + 70))
    }
    
    //
    //
    //
    //
    //      Circle class starts here
    //
    //
    //
    
    class Circle : SKShapeNode {
        
        var circle = SKShapeNode(circleOfRadius: 0)
        var hitbox = SKShapeNode(circleOfRadius: 0)
        let shape = SKShapeNode()
        
        static var gameState = 0.0
        
        var radius = CGFloat(70) {
            didSet {
                circle.xScale *= radius/70.0
                circle.yScale *= radius/70.0
                hitbox.xScale *= radius/70.0
                hitbox.yScale *= radius/70.0
                shape.xScale *= radius/70.0
                shape.yScale *= radius/70.0
            }
        }
        let colors : [UIColor] = [UIColor(red: 1, green: 85/255, blue: 43/255, alpha: 1.0),
                                  UIColor(red: 30/255, green: 200/255, blue: 255/255, alpha: 1.0),
                                  UIColor(red: 40/255, green: 255/255, blue: 90/255, alpha: 1.0),
                                    UIColor(red: 1, green: 220/255, blue: 40/255, alpha: 1.0)]
        
        var direction = -1 {
            didSet {
                circle.removeFromParent()
                shape.removeFromParent()
                shape.run(SKAction.rotate(toAngle: 0, duration: 0))
                shape.fillColor = .white
                shape.run(SKAction.rotate(byAngle: (CGFloat.pi/2)*CGFloat(direction), duration: 0))
                
                circle = SKShapeNode(circleOfRadius: radius)
                circle.fillColor = colors[direction]
                circle.strokeColor = colors[direction]
                addChild(circle)
                addChild(shape)
            }
        }
        
        let imageNames : [String] = ["RedBall", "BlueBall", "GreenBall", "YellowBall"]
        var glow = 0.0 {
            didSet {
                setGlowWidth(width: glow)
            }
        }
        
        var velocity = vector2(0.0, 0.0) {
            didSet {
                if velocity.x == 0 && velocity.y == 0 {
                    self.velocity = GameScene.globalVelocity
                }
            }
        }
        
        var touched = false
        var fingered = false
        
        var touchTimeStamp : TimeInterval = 0.0
        var touchPositionStamp : CGPoint = CGPoint.zero
        
        override init() {
            super.init()
            velocity = GameScene.globalVelocity
            
            shape.run(SKAction.scale(by: 0.7, duration: 0))
            shape.path = makeArrowPath()
            shape.lineWidth = 2
            shape.strokeColor = .white
            
            setRandomDirection()
            
            hitbox = SKShapeNode(circleOfRadius: radius + 10)
            hitbox.fillColor = .clear
            hitbox.strokeColor = .clear
            
            
//            print(circle.strokeColor)
            addChild(hitbox)
            
            if circle.parent == nil {
                addChild(circle)
                addChild(shape)
            }
        }
        
        func setRandomDirection() {self.direction = Int(arc4random_uniform(4))}
        
        func setGlowWidth(width: Double) {
            circle.glowWidth = CGFloat(13 * (sin(0.07*width) + sin(0.07 * 4.4 * width)))
        }
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            if self.parent != nil {
                touched = true
                fingered = true
                touchTimeStamp = touches.first!.timestamp
                touchPositionStamp = touches.first!.location(in: self.parent!)
            }
            
//            print("began")
        }
        
        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            
            if self.parent != nil {
                let touchedPoint = touches.first!.location(in: self.parent!)
                
                if (self.parent?.frame.contains(touchedPoint))! {
                    position = touchedPoint
                }
            }
            
//            print("moved")
        }
        
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            if self.parent != nil {
                let dx = Double(touches.first!.location(in: self.parent!).x - touchPositionStamp.x)
                let dy = Double(touches.first!.location(in: self.parent!).y - touchPositionStamp.y)
                let dt = Double(touches.first!.timestamp - touchTimeStamp)
                
                let a = 300.0
                velocity.x = min(max(pow((dx/dt) / a, 2), 1), 60) * sign((dx/dt) / a)
                velocity.y = min(max(pow((dy/dt) / a, 2), 1), 60) * sign((dy/dt) / a)
                
                fingered = false
            }
            
//            print("ended")
        }
        
        private func makeArrowPath() -> CGMutablePath {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: -radius/3 , y: 0))
            path.addLine(to: CGPoint(x:-radius/3, y:-radius/1.5))
            path.addLine(to: CGPoint(x: radius/3, y: -radius/1.5))
            path.addLine(to: CGPoint(x: radius/3, y: 0))
            path.addLine(to: CGPoint(x: radius*3/5, y: 0))
            path.addLine(to: CGPoint(x: 0, y: radius-radius/5))
            path.addLine(to: CGPoint(x: -radius*3/5, y: 0))
            path.addLine(to: CGPoint(x: -radius/3, y: 0))
            
            return path
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
}




extension CAGradientLayer {
    
    func turquoiseColor() -> CAGradientLayer {
        let topColor = UIColor(red: (15/255.0), green: (118/255.0), blue: (128/255.0), alpha: 1)
        let bottomColor = UIColor(red: (84/255.0), green: (187/255.0), blue: (187/255.0), alpha: 1)
        
        let gradientColors: [CGColor] = [topColor.cgColor, bottomColor.cgColor]
        let gradientLocations: [Float] = [0.0, 1.0]
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations as [NSNumber]
        
        return gradientLayer
    }
}

//func showToast(message : String) {
//    let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
//    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
//    toastLabel.textColor = UIColor.white
//    toastLabel.textAlignment = .center;
//    toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
//    toastLabel.text = message
//    toastLabel.alpha = 1.0
//    toastLabel.layer.cornerRadius = 10;
//    toastLabel.clipsToBounds  =  true
//    self.addSubview(toastLabel)
//    UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
//        toastLabel.alpha = 0.0
//    }, completion: {(isCompleted) in
//        toastLabel.removeFromSuperview()
//    })
//}

