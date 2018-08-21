//
//  ViewController.swift
//  ItunesSearchDemo
//
//  Created by Yenchiayu on 2018/8/20.
//  Copyright © 2018 顏嘉佑(Joe). All rights reserved.
//

import UIKit
import Alamofire
class SearchViewContorller: UIViewController {
    
    @IBOutlet weak var tableviewResult: UITableView!
    weak var requestSearch: DataRequest?
    
    lazy var searchBar: UISearchBar = {
        let bar = UISearchBar.init(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 0, height: 44)))
        return bar
    }()
    
    lazy var modelMusic: MusicSearchModel = {
        let model = MusicSearchModel.init()
        return model
    }()

    var arrayResult: [MusicObject]? {
        get {
            return modelMusic.searchResult?.results
        }
    }
    
    var audioPlayer: AudioPlayerController {
        return AudioPlayerController.share
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableviewResult.tableHeaderView = searchBar
        tableviewResult.delegate = self
        tableviewResult.dataSource = self
        tableviewResult.keyboardDismissMode = .onDrag
        tableviewResult.register(MusicResultCell.registNib, forCellReuseIdentifier: MusicResultCell.registID)
        
        searchBar.delegate = self
        
        registerNotification()
        
        self.addChildViewController(audioPlayer)
        audioPlayer.didMove(toParentViewController: self)
        audioPlayer.delegatePlayMusic = self        
    }
    
    private func registerNotification() {
        NotificationCenter.default.addObserver(forName: .NOTIFICATION_MUSIC_SEARCH_SUSSES, object: modelMusic, queue: OperationQueue.main) { [weak self] (notification) in
            self?.tableviewResult.reloadData()
        }
        NotificationCenter.default.addObserver(forName: .NOTIFICATION_MUSIC_SEARCH_FAILED, object: modelMusic, queue: OperationQueue.main) { [weak self] (notification) in
            self?.tableviewResult.reloadData()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let origin = CGPoint(x: 0, y: tableviewResult.frame.maxY - AudioPlayerController.defaultSize.height)
        audioPlayer.view.frame = CGRect(origin: origin, size: AudioPlayerController.defaultSize)
    }
    
    private func showAudioPlayer() {
        var contentInset = tableviewResult.contentInset
        contentInset.bottom = audioPlayer.view.frame.size.height
        tableviewResult.contentInset = contentInset
        self.view.addSubview(audioPlayer.view)
    }
    
    private func hideAudioPlayer() {
        var contentInset = tableviewResult.contentInset
        contentInset.bottom = 0
        tableviewResult.contentInset = contentInset
        audioPlayer.view.removeFromSuperview()
    }
    
    func selectedResult(selectedIndex: IndexPath?) -> MusicObject? {
        guard let selectedIndex = selectedIndex , selectedIndex.row < (arrayResult?.count ?? 0) else {
            return nil
        }
        guard let result = arrayResult?[selectedIndex.row] else {
            return nil
        }
        return result
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension SearchViewContorller: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        requestSearch?.cancel()
        requestSearch = modelMusic.sendSearchResultRequestFrom(keyword: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension SearchViewContorller: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayResult?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MusicResultCell.registID, for: indexPath) as! MusicResultCell
        let result = arrayResult?[indexPath.row]
        cell.viewModel = MusicResutCellViewModel(title: result?.trackName, subTitle: result?.artistName)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedResult = arrayResult?[indexPath.row] else {
            return
        }        
        showAudioPlayer()
        audioPlayer.play(model: selectedResult)
    }
    
}

extension SearchViewContorller: PlayMusicDelegate {
    func closeAciton() {
        hideAudioPlayer()
    }
}
