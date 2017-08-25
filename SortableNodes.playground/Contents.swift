import PlaygroundSupport
import SpriteKit

class SortableNodesConstants{
    static let sceneWidth = 610
    static let sceneHeight = 500
    static let sortableNodeWidth = 50
    static let sortableNodeHeight = 50
    static let nodeDistance = 10
}

class SortingViewScene: SKScene{
    
    var sortButton: SKShapeNode!
    var parentNode: SKShapeNode!
    var aSortableNode: SortableCustomNode!
    
    override init(size: CGSize) {
        super.init(size: size)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        parentNode = SKShapeNode(rectOf: CGSize(width: SortableNodesConstants.sceneWidth, height:SortableNodesConstants.sceneHeight))
        parentNode.name = "parent"
        parentNode.fillColor = UIColor(red:0.22, green:0.22, blue:0.50, alpha:1.0)
        parentNode.position = CGPoint.init(x: (SortableNodesConstants.sceneWidth/2), y: (SortableNodesConstants.sceneHeight/2))
        parentNode.isUserInteractionEnabled = false
        
        // adding a node as a button to start a sorting process
        sortButton = SortableCustomNode(rectOf: CGSize(width:120, height:30))
        sortButton.name = "sort"
        sortButton.fillColor = UIColor(red:0.15, green:0.68, blue:0.38, alpha:1.0)
        sortButton.position = CGPoint.init(x: 300, y: 100)
        sortButton.zPosition = 1.0
        sortButton.isUserInteractionEnabled = true
        
        // adding a lable over a button node
        let sortButtonLabel = SKLabelNode(fontNamed: "Helvetica")
        sortButtonLabel.text = String("Sort Nodes")
        sortButtonLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        sortButtonLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        sortButtonLabel.fontSize = 18
        sortButtonLabel.fontColor = SKColor.white
        
        self.addChild(sortButton)
        sortButton.addChild(sortButtonLabel)
        
        self.addChild(parentNode)
        
        let utilityObj = SortingUtility()
        
        for i in 0...9{
            
            let randomNumber = arc4random_uniform(90) + 10
            
            let xPosition = utilityObj.calcuateXPositionOfSprite(index: i)
            
            aSortableNode = SortableCustomNode(rectOf: CGSize(width: 50, height: 50))
            aSortableNode.name = "node" + String(i)
            aSortableNode.fillColor = UIColor(red:1.00, green:0.97, blue:0.22, alpha:1.0)
            aSortableNode.position = CGPoint.init(x: xPosition, y:220)
            aSortableNode.isUserInteractionEnabled = true
            
            let physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 50))
            physicsBody.affectedByGravity = false
            physicsBody.allowsRotation = false
            
            aSortableNode.physicsBody = physicsBody
            
            let valueLableNode = SKLabelNode(fontNamed: "Helvetica")
            valueLableNode.name = "value"
            valueLableNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
            valueLableNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
            valueLableNode.text = String(randomNumber)
            valueLableNode.fontSize = 20
            valueLableNode.fontColor = UIColor(red:0.22, green:0.22, blue:0.50, alpha:1.0)
            
            aSortableNode.addChild(valueLableNode)
            
            parentNode.addChild(aSortableNode)
        } // end of for loop
        
    } // end of didMove()
    
} // end of SortingViewScene class

class SortableCustomNode: SKShapeNode{
    
    var aNode : SKShapeNode!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (touches.first != nil) {
            
            aNode = self
            
            if let node = aNode {
                let name:String = node.name!
                
                if(name == "sort"){
                    
                    aNode = nil
                    
                    let scene: SKScene! = node.scene
                    
                    let parentNode = scene.childNode(withName: "parent")!
                    
                    let sortableNodeArray:[SKNode] = parentNode.children
                    
                    var sortableNodeDictionary = [String: Int]()
                    
                    for aSortableNode in sortableNodeArray{
                        
                        let nodeValue: SKLabelNode? = aSortableNode.childNode(withName: "value") as? SKLabelNode
                        
                        var intNodeValue: Int?
                        
                        if let v = nodeValue{
                            intNodeValue = Int(v.text!)
                        }
                        
                        let nodeName: String? = aSortableNode.name
                        
                        if(nodeName != "sort"){
                            sortableNodeDictionary.updateValue(intNodeValue!, forKey: nodeName!)
                        }
                        
                    } // end of for() getting x postion of all the nodes
                    
                    // Sorting the dictionary in ascending order based on the value of the node
                    let modifiedSortDictionary = sortableNodeDictionary.sorted { (first: (key: String, value: Int), second: (key: String, value: Int)) -> Bool in
                        return first.value < second.value
                    }
                    
                    let length = modifiedSortDictionary.count
                    let utilityObj = SortingUtility()
                    var actions = Array<SKAction>();
                    
                    for i in 0...length-1{
                        
                        let node = parentNode.childNode(withName: modifiedSortDictionary[i].key) as! SortableCustomNode
                        
                        node.physicsBody?.isDynamic = false // Removing the physicsBody to prevent collosions during move action
                        
                        let xPosition = utilityObj.calcuateXPositionOfSprite(index: i)
                        
                        actions.append(SKAction.run(SKAction.move(to: CGPoint(x: CGFloat(xPosition), y: CGFloat(0.0)), duration: 1.5), onChildWithName: modifiedSortDictionary[i].key ))
                        
                        actions.append(SKAction.wait(forDuration: 1.5))
                        
                    } // end of for loop
                    
                    let sortingSequece = SKAction.sequence(actions)
                    parentNode.run(sortingSequece)
                    
                } // end of cheking Node name
                
            } // end of aNode unwrapping
            
        } // end of touches.first condition
        
    } // end of touchedBegan()
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if touches.first != nil {
            aNode = nil
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first, aNode != nil {
            aNode.position = touch.location(in: self.parent!)
        }
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if touches.first != nil {
            aNode = nil
        }
        
    }
    
} // end of SortableCustomNode class

class SortingUtility{
    
    // calculates the x coordinate of the node during initial setup and while sorting
    func calcuateXPositionOfSprite(index : Int) -> Int{
        
        let xCord = (-1 * (SortableNodesConstants.sceneWidth)/2) + (SortableNodesConstants.sortableNodeWidth * index)
        var offset = SortableNodesConstants.nodeDistance * (index + 1)
        
        offset = offset + (SortableNodesConstants.sortableNodeWidth/2) // To adjust the anchor point
        
        let xPosition = xCord + offset
        
        return xPosition
    }
    
}

let sortingSceneSize = CGSize(width: SortableNodesConstants.sceneWidth, height: SortableNodesConstants.sceneHeight)

let aSkView = SKView(frame: CGRect(origin: CGPoint.zero, size: sortingSceneSize))

var aScene = SortingViewScene(size: sortingSceneSize)

aSkView.presentScene(aScene)

PlaygroundPage.current.liveView = aSkView
