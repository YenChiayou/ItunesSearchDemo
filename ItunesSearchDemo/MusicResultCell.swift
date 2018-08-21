//
//  MusicResultCell.swift
//  ItunesSearchDemo
//
//  Created by Yenchiayu on 2018/8/21.
//  Copyright © 2018 顏嘉佑(Joe). All rights reserved.
//

import UIKit

class MusicResultCell: UITableViewCell {
    static var registID: String {
        return "MusicResultCellID"
    }
    
    static var registNib: UINib {
        return UINib.init(nibName: "MusicResultCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    var viewModel: MusicResutCellViewModel? {
        didSet {
            self.textLabel?.text = viewModel?.title
            self.detailTextLabel?.text = viewModel?.subTitle
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.textLabel?.text = nil
        self.detailTextLabel?.text = nil
    }
}

struct MusicResutCellViewModel {
    var title: String?
    var subTitle: String?
}
