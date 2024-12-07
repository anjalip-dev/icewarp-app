//
//  ChannelRepo.swift
//  ice_warp
//
//  Created by Anjali Pandey on 07/12/24.
//

import Foundation
import CoreData

func saveAccountToCoreData(
    _ authResponse: AuthResponse,
    context: NSManagedObjectContext
) {
    
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Account.fetchRequest()
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    do {
        try context.execute(deleteRequest)
    } catch {
        print("Failed to clear old Account: \(error)")
    }
    
    let account = Account(context: context)
    account.email = authResponse.email
    account.token = authResponse.token
    account.host = authResponse.host

    do {
        try context.save()
        print("Account saved successfully!")
    } catch {
        print("Failed to save Account: \(error)")
    }
}


// _ channels: [Channel],

func saveChannelsToCoreData(
    _ channels: [ChannelDto],
    context: NSManagedObjectContext
) {
    
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Channel.fetchRequest()
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    do {
        try context.execute(deleteRequest)
    } catch {
        print("Failed to clear old channels: \(error)")
    }

    for channel in channels {
        
        let coreDataChannel = Channel(context: context)
        coreDataChannel.id = channel.id
        coreDataChannel.name = channel.name
        coreDataChannel.group_folder_name = channel.groupFolderName
        
    }

    do {
        try context.save()
        print("Channels saved successfully!")
    } catch {
        print("Failed to save channels: \(error)")
    }
}

func fetchChannelsFromCoreData(context: NSManagedObjectContext) -> [Channel] {
    let fetchRequest: NSFetchRequest<Channel> = Channel.fetchRequest()
    do {
        let channels = try context.fetch(fetchRequest)
        return channels
    } catch {
        print("Failed to fetch channels: \(error)")
        return []
    }
}
