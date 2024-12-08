//
//  ChannelCollectionViewCell.swift
//  ice_warp
//
//  Created by Anjali Pandey on 07/12/24.
//

import UIKit

class ChannelCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var label_channelName: UILabel!
    
    override var isSelected: Bool {
           didSet {
               contentView.backgroundColor = isSelected ? .systemGray5 : .systemBackground
           }
       }
    
}
