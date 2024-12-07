//
//  IceWarpModel.swift
//  ice_warp
//
//  Created by Anjali Pandey on 07/12/24.
//

import Foundation

struct AuthResponse: Codable {
    let authorized: Bool
    let token: String
    let host: String
    let email: String
    let ok: Bool
}

// Model for Channel
class ChannelDto: Codable {
    let id: String
    let name: String
    let groupFolderName: String

    // Coding keys to map JSON keys to Swift properties
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case groupFolderName = "group_folder_name"
    }
    
    init(id: String = "", name: String = "", groupFolderName: String = "") {
            self.id = id
            self.name = name
            self.groupFolderName = groupFolderName
        }
    
}

struct ChannelResponse: Codable {
    let channels: [ChannelDto]
    let ok: Bool
}

class ChannelWithGroup {
    var channels: [ChannelDto] = []
    var groupName: String = ""
}
