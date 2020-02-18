# Pinterest Layout
A custom UICollectionViewLayout subclass that implements a layout used in the Pinterest app. The layout supports the placement of banners that are full sized cells "braking" the waterfall layout.

<p align="center">
<img src="demo.gif">
</p>

## Usage
### Setup
```swift
pinterestLayout.delegate = self
pinterestLayout.numberOfColumns = 2
pinterestLayout.cellPadding = 6
```
### Register banner
```swift
colView.register(BannerView.self, forSupplementaryViewOfKind: PinterestLayout.elementKindBanner,
                withReuseIdentifier: Constants.bannerID)
```
### Pinterest Layout Delegates
```swift
func collectionView(_ collectionView: UICollectionView, layout: PinterestLayout,
                    heightForItemAtIndexPath indexPath: IndexPath) -> CGFloat {
    // Return the desired cell size
}

func collectionView(_ collectionView: UICollectionView, layout: PinterestLayout,
                    heightForBannerAtIndexPath indexPath: IndexPath) -> CGFloat {
    // Return the height of the banner
}

func numberOfItemsBeforeAds(in collectionView: UICollectionView) -> Int {
    // Specify the frequency of banners
}
```
## Performance
The layout uses binary search to provide the visible cells' layout attributes.

```swift
override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    var result = [UICollectionViewLayoutAttributes]()
    
    let attributes = binSearchAttributes(in: itemCache, intersecting: rect)
    result.append(contentsOf: attributes)
    
    supplementaryCache.keys.forEach { key in
        if let cache = supplementaryCache[key] {
            let attributes = binSearchAttributes(in: cache, intersecting: rect)
            result.append(contentsOf: attributes)
        }
    }
        
    return result
}
```
## Extensibility
The supplementary cache is a dictionary in which the key should be the `elementKind` property of supplementary views. With the extension of the layout, other supplementary views could be added easily by the modification of only the prepare method. You just have to:
1) **Calculate the frames of the new supplementary view**
2) **Create the layout attribute for the supplementary viewv
3) **Set the calculated frame on the attribute**
4) **Update the supplementaryCache with the new attribute**
5) **Update the contentBounds property to keep track of the content size**
6) **Update the yOffsets vector so the next cell continues from the correct y coordinate**
7) **Keep track of the supplementary view's index**

```swift
// The layout of the banner:
if itemIndex % adFrequency == 0 {
    // 1
    let indexPath = IndexPath(item: adIndex, section: 0)
    let height = delegate?.collectionView(collectionView, layout: self,
                                          heightForBannerAtIndexPath: indexPath) ?? 200
    let frame = CGRect(x: 0,
                       y: yOffsets.max() ?? 0,
                       width: contentBounds.width,
                       height: height)
    
    let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
    
    // 2
    let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind:
                              Self.elementKindBanner, with: indexPath)
                                                
    // 3
    attributes.frame = insetFrame
    
    // 4
    supplementaryCache.updateCollection(keyedBy: PinterestLayout.elementKindBanner, 
                                        with: attributes)
    
    // 5
    contentBounds = contentBounds.union(frame)
    
    // 6
    yOffsets = yOffsets.map { _ in frame.maxY }
    
    // 7
    adIndex += 1
}
```

## Dictionary extension
The layout uses a simple dictionary extension for the supplementary cache update. The method called `updateCollection(keyedBy:with:)`  enables you to update a dictionary's collection value with a new element, even if it is the first one. It's very simple, but saves you some code and shows the power of POP.

```swift
extension Dictionary where Value: RangeReplaceableCollection {
    mutating func updateCollection(keyedBy key: Key, with element: Value.Element) {
        if var collection = self[key] {
            collection.append(element)
            self[key] = collection
        } else {
            var collection = Value()
            collection.append(element)
            self[key] = collection
        }
    }
}
```
