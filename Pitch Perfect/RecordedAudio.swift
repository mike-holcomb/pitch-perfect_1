//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by Denisse Holcomb on 6/7/15.
//  Copyright (c) 2015 Mike Holcomb. All rights reserved.
//

import Foundation

/**
    Data model for recorded audio; stores file URL and file title for recorded audio file

    **fileURL** Stores URL pointing to audio file as NSURL
    
    **fileTitle** Stores title of audio file as String
*/
class RecordedAudio: NSObject {
    var filePathURL: NSURL!
    var title: String!
    
    // Full member initializer for Recorded Audio
    init(fileURL filePathURL: NSURL, fileTitle title: String){
        self.filePathURL = filePathURL
        self.title = title
    }
}