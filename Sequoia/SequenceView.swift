//
//  SequenceView.swift
//  Sequoia
//
//  Created by Colin Caufield on 12/1/14.
//  Copyright (c) 2014 Secret Geometry, Inc. All rights reserved.
//

import UIKit

class SequenceView: UIView {
    
    weak var delegate : SequenceViewDelegate?
    var itemRows = [[UIButton]]()
    var rowNames = ["untitled"]
    var rows = 0
    var cols = 0
    var itemWidth = CGFloat(0.0)
    var itemHeight = CGFloat(0.0)
    var cursorOffset = 0.0
    var showCursor = false
    var cursorView: UIImageView! = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initCommon()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initCommon()
    }
    
    func initCommon() {
        backgroundColor = UIColor.darkGray
        createCursorView()
        changeButtonColumns(8, rows:12)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        resizeCursorView()
        layoutButtons()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let minX = rect.minX
        let minY = rect.minY
        let maxX = rect.maxX
        let maxY = rect.maxY
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.setStrokeColor(UIColor.red.cgColor)
        context?.setLineWidth(2.0)
        
        context?.stroke(bounds)
        
        context?.beginPath()
        context?.move(to: CGPoint(x: minX, y: minY))
        context?.addLine(to: CGPoint(x: maxX, y: maxY))
        context?.move(to: CGPoint(x: maxX, y: minY))
        context?.addLine(to: CGPoint(x: minX, y: maxY))
        context?.strokePath()
    }
    
    func createCursorView() {
        
        let path = Bundle.main.path(forResource: "Images/SequenceCursor", ofType: "png")
        let insets = UIEdgeInsetsMake(7.0, 0.0, 7.0, 0.0)
        let image = UIImage(contentsOfFile: path!)?.resizableImage(withCapInsets: insets)
        
        self.cursorView = UIImageView(image: image)
        self.addSubview(self.cursorView)
        
        resizeCursorView()
        moveCursorView(0.0)
    }
    
    func resizeCursorView() {
        
        self.cursorView.frame.size.height = self.frame.size.height
    }
    
    func moveCursorView(_ timeOffset: CGFloat) {
        
        var position: CGFloat = 0.0
        
        if self.cols > 0 {
            position = self.frame.width * timeOffset / CGFloat(self.cols)
        }
        
        self.cursorView.frame.origin.x = position - 0.5 * self.cursorView.frame.width
    }
    
    func changeButtonColumns(_ cols: Int, rows: Int) {
        
        self.rows = rows
        self.cols = cols
        
        updateItemSizes()
        
        if rows < itemRows.count {
            itemRows.removeSubrange(rows..<itemRows.count)
        }
        else if rows > itemRows.count {
            itemRows += [[UIButton]](repeating: [], count: rows - itemRows.count)
        }
        
        for i in 0..<itemRows.count {
            
            if cols < itemRows[i].count {
                itemRows.removeSubrange(cols..<itemRows[i].count)
            }
            
            while cols > itemRows[i].count {
                
                let button = UIButton(type: .system) as UIButton
                
                let value = rows - i - 1
                let title = String(rowNames[value % rowNames.count])
                button.titleLabel?.text = title
                button.setTitle(title, for:UIControlState())
                //button.setTitle(title, forState:.Selected)
                
                button.setTitleColor(UIColor.clear, for: UIControlState())
                //button.setTitleColor(UIColor.clearColor(), forState: .Normal)
                
                button.addTarget(nil, action:#selector(itemTouched(_:)), for:.touchDown)
                //button.addTarget(self, action:"itemUpInside:", forControlEvents:.TouchUpInside)
                //button.addTarget(self, action:"itemUpOutside:", forControlEvents:.TouchUpOutside)
                
                itemRows[i].append(button)
                
                //addSubview(button)
                
                self.insertSubview(button, belowSubview: self.cursorView)
            }
        }
    }
    
    func layoutButtons() {
        
        updateItemSizes()
        
        var x = CGFloat(0.0)
        var y = frame.height - itemHeight
        
        for j in 0..<itemRows.count {
            
            for i in 0..<itemRows[j].count {
                itemRows[j][i].frame = CGRect(x: x, y: y, width: itemWidth, height: itemHeight)
                x += itemWidth
            }
            
            x = 0.0
            y -= itemHeight
        }
    }
    
    func updateItemSizes() {
        itemWidth = frame.width / CGFloat(cols)
        itemHeight = frame.height / CGFloat(rows)
    }
    
    func positionForValue(_ value: Double, start: Double) -> CGPoint {
        let x = CGFloat(start) * itemWidth
        let y = frame.height - CGFloat(value + 1.0) * itemHeight
        return CGPoint(x: x, y: y)
    }
    
    func valueForPosition(_ y: CGFloat) -> Double {
        return Double(rows) - floor(Double(y / itemHeight)) - 1.0
    }
    
    func startForPosition(_ x: CGFloat) -> Double {
        return floor(Double(x / itemWidth))
    }
    
    func buttonForValue(_ value: Double, start: Double) -> UIButton? {
        
        let y = Int(value)
        let x = Int(start)
        
        if y < itemRows.count {
            let row = itemRows[y]
            if x < row.count {
                return row[x]
            }
        }
        
        return nil
    }
    
    func valueForButton(_ button: UIButton) -> Double {
        return valueForPosition(button.frame.midY)
    }
    
    func startForButton(_ button: UIButton) -> Double {
        return startForPosition(button.frame.midX)
    }
    
    func addItem(_ tag: Int, value: Double, start: Double, length: Double) {
        let button = buttonForValue(value, start: start)
        button?.tag = tag
        button?.isSelected = true
    }
    
    func itemTouched(_ sender: UIButton!) {
        
        if sender.isSelected {
            sender.isSelected = false
            delegate?.itemWasRemoved(sender.tag)
        }
        else {
            sender.isSelected = true
            let value = valueForButton(sender)
            let start = startForButton(sender)
            delegate?.itemWasAdded(sender, value: value, start: start, length: 1.0)
        }
    }
}
