//
//  Episode.swift
//  AANetworking
//
//  Created by Ankit Angra on 12/09/16.
//  Copyright © 2016 Ankit Angra. All rights reserved.
//

import Foundation


struct Movie {
    var overView : String!
    var releaseData : String!
    var originalTitle : String!
    var originalLanguage : String!
    var title : String!
}

extension Movie {
    init? (movieDetails : JSONDictionary ) {
        guard let overView = movieDetails["overview"] as? String,
            releaseData = movieDetails["release_date"] as? String,
            originalTitle = movieDetails["original_title"] as? String,
            originalLanguage = movieDetails["original_language"] as? String,
            title = movieDetails["title"] as? String
            else { return nil }
        
        self.overView = overView
        self.releaseData = releaseData
        self.originalTitle = originalTitle
        self.originalLanguage = originalLanguage
        self.title = title
    }
}