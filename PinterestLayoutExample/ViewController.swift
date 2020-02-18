//
//  ViewController.swift
//  PinterestLayoutExample
//
//  Created by Foltányi Kolos on 2020. 02. 18..
//  Copyright © 2020. Foltányi Kolos. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private enum Constants {
        static let imageCellID = "ImageCell"
        static let bannerID = "BannerView"
        static let mockLabels = [
            "This is a nice house, but it must be expensive",
            "Wow, very nice design. It must have been hard to build this.",
            "I want to live in this, but I can't afford a flat.",
            "This looks stupid",
            "This one is also very modern looking.",
            "What a great design",
        ]
    }
    
    var numberOfCells = 100

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pinterestLayout: PinterestLayout!
    @IBOutlet weak var titleLabel: UILabel!
    
    var houseImages: [UIImage?] = []
    var houseLabels: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadData()
    }
    
    private func loadData() {
        houseImages = (0..<numberOfCells).map { return UIImage(named: "house\($0 % 10)") }
        houseLabels = (0..<numberOfCells).map {
            return Constants.mockLabels[$0 % Constants.mockLabels.count]
        }
    }
    
    private func setupViews() {
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.contentInset = UIEdgeInsets(top: 115, left: 6, bottom: 0, right: 6)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: Constants.imageCellID)
        collectionView.register(BannerView.self, forSupplementaryViewOfKind: PinterestLayout.elementKindBanner, withReuseIdentifier: Constants.bannerID)
        
        pinterestLayout.delegate = self
        pinterestLayout.numberOfColumns = 2
        pinterestLayout.cellPadding = 6
        
    }
}


extension ViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout: PinterestLayout, heightForItemAtIndexPath indexPath: IndexPath) -> CGFloat {
        let image = houseImages[indexPath.item]
        let text = houseLabels[indexPath.item]
        
        let width = image?.size.width ?? 0
        let height = image?.size.height ?? 0
        let scaledImageHeight = (height * layout.cellWidth) / width
        
        let padding = ImageCell.Constants.padding
        
        let labelHeight = text.heightFitting(width: layout.cellWidth, font: ImageCell.Constants.font)
        
        return scaledImageHeight + padding + labelHeight
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: PinterestLayout, heightForBannerAtIndexPath indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    func numberOfItemsBeforeAds(in collectionView: UICollectionView) -> Int {
        return 10
    }
    

}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfCells
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dequeuedCell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.imageCellID, for: indexPath)
        let cell = dequeuedCell as? ImageCell ?? ImageCell()
        cell.imageView.image = houseImages[indexPath.item]
        cell.label.text = houseLabels[indexPath.item]
        return cell
    }
    
     func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == PinterestLayout.elementKindBanner {
            let dequeuedBanner = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.bannerID, for: indexPath) as? BannerView
            let cell = dequeuedBanner ?? BannerView()
            cell.imageView.image = UIImage(named: "testAd")
            return cell
        }
           fatalError()
       }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y + scrollView.contentInset.top
        
        let dy = offsetY > 0 ? -offsetY : 0
        titleLabel.transform = CGAffineTransform(translationX: 0, y: dy)
    }
    
}

extension String {
    func heightFitting(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: font], context: nil)
        return boundingBox.height
    }
}
