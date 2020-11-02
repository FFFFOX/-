//
//  CollectionViewAnimationLayout.swift
//  视讼
//
//  Created by KlausZhang on 2020/7/27.
//  Copyright © 2020 KlausZhang. All rights reserved.
//

import UIKit

class CollectionViewAnimationLayout: UICollectionViewFlowLayout {
    var updateIndexPaths = NSArray.init()
    
    override func prepare() {
        super.prepare()
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {

        return nil
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let oldRect = collectionView!.bounds
        if oldRect.equalTo(newBounds) {
            return false
        }
        return true
    }
    
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        let indexPaths = NSMutableArray.init()
        for item in updateItems {
            switch item.updateAction {
            case UICollectionViewUpdateItem.Action.insert:
                indexPaths.add(item.indexPathAfterUpdate!)
                
            case UICollectionViewUpdateItem.Action.delete:
                indexPaths.add(item.indexPathBeforeUpdate!)
                
            case UICollectionViewUpdateItem.Action.move:
                indexPaths.add(item.indexPathAfterUpdate!)
                indexPaths.add(item.indexPathBeforeUpdate!)
            default:
                print("")
            }
        }
        updateIndexPaths = indexPaths.copy() as! NSArray
        
    }
}
