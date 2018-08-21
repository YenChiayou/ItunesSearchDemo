//
//  Music.swift
//  ItunesSearchDemo
//
//  Created by Yenchiayu on 2018/8/20.
//  Copyright © 2018 顏嘉佑(Joe). All rights reserved.
//

import Foundation
import Alamofire

extension Notification.Name {
    static let NOTIFICATION_MUSIC_SEARCH_SUSSES = Notification.Name(rawValue: "NOTIFICATION_MUSIC_SEARCH_SUSSES")
    static let NOTIFICATION_MUSIC_SEARCH_FAILED = Notification.Name(rawValue: "NOTIFICATION_MUSIC_SEARCH_FAILED")
}

struct MusicObject: Codable, Playable{
    var previewUrl, artistName, trackName: String?
    
    var musicUrl: URL? {
        guard let stringUrl = previewUrl else {
            return nil
        }
        return URL(string: stringUrl)
    }
    
    var musicDescription: String? {
        let stringTrack = trackName ?? ""
        let stringArtist = artistName ?? ""
        return stringTrack + " by " + stringArtist
    }
}

struct MusicSearchResults: Codable {
    var results = [MusicObject]()
}

class MusicSearchModel {
    
    private static func makeRequest(path: String, paramters: [String: Any]?) -> DataRequest? {
        let request = Alamofire.request(path, method: .get, parameters: paramters)
        return request
    }

    var searchResult: MusicSearchResults?
    
    func sendSearchResultRequestFrom(keyword: String?) -> DataRequest? {
        guard let keyword = keyword, keyword.isEmpty == false else {
            searchResult = nil
            NotificationCenter.default.post(name: .NOTIFICATION_MUSIC_SEARCH_FAILED, object: self)
            return nil
        }
        let dicParam = ["term" : keyword]
        let requestSearch = MusicSearchModel.makeRequest(path: ApiRouter.search ,paramters: dicParam)
        requestSearch?.responseData(completionHandler: { [weak self] (response) in
            switch response.result {
            case .success(let data):
                let decoderMusic = JSONDecoder()
                self?.searchResult = try? decoderMusic.decode(MusicSearchResults.self, from: data)
                NotificationCenter.default.post(name: .NOTIFICATION_MUSIC_SEARCH_SUSSES, object: self)
            case.failure(let error):
                if (error as NSError).code != NSURLErrorCancelled {
                    NotificationCenter.default.post(name: .NOTIFICATION_MUSIC_SEARCH_FAILED, object: self)
                }
            }
        })
        return requestSearch
    }
}
