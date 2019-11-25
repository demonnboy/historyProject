//
//  MMSearchStyleFlowLayout.swift
//  storefront-ios
//
//  Created by Demon on 18/7/18.
//  Copyright © 2018年 WWE & CO. All rights reserved.
//

import UIKit

enum MMAlignType : NSInteger {
    case left = 0
    case center = 1
    case right = 2
}

class MMSearchStyleFlowLayout: UICollectionViewFlowLayout {
    //两个Cell之间的距离
    private var betweenOfCell : CGFloat{
        didSet{
            self.minimumInteritemSpacing = betweenOfCell
        }
    }
    //cell对齐方式
    private var cellType : MMAlignType = MMAlignType.center
    //在居中对齐的时候需要知道这行所有cell的宽度总和
    private var sumCellWidth : CGFloat = 0.0
    
    override init() {
        betweenOfCell = 5.0
        super.init()
        scrollDirection = UICollectionViewScrollDirection.vertical
        minimumLineSpacing = 5
        sectionInset = UIEdgeInsetsMake(5, 15, 5, 15)
    }
    
    convenience init(_ cellType:MMAlignType){
        self.init()
        self.cellType = cellType
    }
    
    convenience init(_ cellType: MMAlignType, _ betweenOfCell: CGFloat){
        self.init()
        self.cellType = cellType
        self.betweenOfCell = betweenOfCell
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let layoutAttributes_super : [UICollectionViewLayoutAttributes] = super.layoutAttributesForElements(in: rect) ?? [UICollectionViewLayoutAttributes]()
        let layoutAttributes:[UICollectionViewLayoutAttributes] = NSArray(array: layoutAttributes_super, copyItems:true)as! [UICollectionViewLayoutAttributes]
        var layoutAttributes_t : [UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()
        
        for index in 0..<layoutAttributes.count {
            let currentAttr = layoutAttributes[index]
            let previousAttr = index == 0 ? nil : layoutAttributes[index-1]
            let nextAttr = index + 1 == layoutAttributes.count ?
                nil : layoutAttributes[index+1]
            
            layoutAttributes_t.append(currentAttr)
            sumCellWidth += currentAttr.frame.size.width
            
            let previousY :CGFloat = previousAttr == nil ? 0 : previousAttr!.frame.maxY
            let currentY :CGFloat = currentAttr.frame.maxY
            let nextY:CGFloat = nextAttr == nil ? 0 : nextAttr!.frame.maxY
            
            if currentY != previousY && currentY != nextY {
                if currentAttr.representedElementKind == UICollectionElementKindSectionHeader {
                    layoutAttributes_t.removeAll()
                    sumCellWidth = 0.0
                } else if currentAttr.representedElementKind == UICollectionElementKindSectionFooter {
                    layoutAttributes_t.removeAll()
                    sumCellWidth = 0.0
                } else {
                    self.setCellFrame(with: layoutAttributes_t)
                    layoutAttributes_t.removeAll()
                    sumCellWidth = 0.0
                }
            } else if currentY != nextY {
                self.setCellFrame(with: layoutAttributes_t)
                layoutAttributes_t.removeAll()
                sumCellWidth = 0.0
            }
        }
        return layoutAttributes
    }
    
    /// 调整Cell的Frame
    ///
    /// - Parameter layoutAttributes: layoutAttribute 数组
    func setCellFrame(with layoutAttributes : [UICollectionViewLayoutAttributes]) {
        var nowWidth : CGFloat = 0.0
        switch cellType {
        case MMAlignType.left:
            nowWidth = self.sectionInset.left
            for attributes in layoutAttributes {
                var nowFrame = attributes.frame
                nowFrame.origin.x = nowWidth
                attributes.frame = nowFrame
                nowWidth += nowFrame.size.width + self.betweenOfCell
            }
            break;
        case MMAlignType.center:
            nowWidth = (self.collectionView!.frame.size.width - sumCellWidth - (CGFloat(layoutAttributes.count - 1) * betweenOfCell)) / 2
            for attributes in layoutAttributes {
                var nowFrame = attributes.frame
                nowFrame.origin.x = nowWidth
                attributes.frame = nowFrame
                nowWidth += nowFrame.size.width + self.betweenOfCell
            }
            break;
        case MMAlignType.right:
            nowWidth = self.collectionView!.frame.size.width - self.sectionInset.right
            for var index in 0 ..< layoutAttributes.count {
                index = layoutAttributes.count - 1 - index
                let attributes = layoutAttributes[index]
                var nowFrame = attributes.frame
                nowFrame.origin.x = nowWidth - nowFrame.size.width
                attributes.frame = nowFrame
                nowWidth = nowWidth - nowFrame.size.width - betweenOfCell
            }
            break;
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}