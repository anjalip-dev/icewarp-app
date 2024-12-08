//
//  ChannelViewController.swift
//  ice_warp
//
//  Created by Anjali Pandey on 07/12/24.
//

import UIKit
import CoreData

class ChannelViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var persistentContainer: NSManagedObjectContext!
    
    @IBOutlet weak var collectionView_channels: UICollectionView!
    
    private var channels: [Channel] = []
    private var channelsWithGroup: [ChannelWithGroup] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            persistentContainer = appDelegate.persistentContainer.viewContext
        }
        
        collectionView_channels.delegate = self
        collectionView_channels.dataSource = self
                
        loadData()
        populateData()

    }
    
    private func loadData() {
            
        channels = fetchChannelsFromCoreData(context: self.persistentContainer)
        
        channelsWithGroup = []
        var groups: [String] = []
        
        for channel in channels {
            if !groups.contains(channel.group_folder_name!) {
                groups.append(channel.group_folder_name!)
            }
        }
        
        for group in groups {
            let channelWithGroup = ChannelWithGroup()
            channelWithGroup.groupName = group
            let chs =  channels.filter { $0.group_folder_name == group }
            
            for ch in chs {
                let channelDto = ChannelDto(
                    id: ch.id!,
                    name: ch.name!,
                    groupFolderName: ch.group_folder_name!
                )
                channelWithGroup.channels.append(channelDto)
            }
            
            channelsWithGroup.append(channelWithGroup)

        }
        
        DispatchQueue.main.async {
            self.collectionView_channels.reloadData()
        }

    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    // MARK: Actions
    
    @IBAction func onBackPressed(_ sender: Any) {
        PrefManager.shared.clearData()
        KeyChainHelper.shared.clearAllKeychainData()
        navigationController?.popViewController(animated: true)
    }
    
    func populateData() {
        
        getChannels() { result in
            
            switch result {
                
            case .success(let data):
                self.processChannelResponse(data)
                
            case .failure(let error):
                print("===========> Error: \(error)")
                
                if self.channels.isEmpty {
                
                    DispatchQueue.main.async {
                        
                        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        
                        self.present(alert, animated: true)
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    func processChannelResponse(_ response: Data) {
        
        if let responseString = String(data: response, encoding: .utf8) {
                print("Data fetched successful: \(responseString)")
            
            if let jsonData = responseString.data(using: .utf8) {
                do {
                                        
                    let channelResponse = try JSONDecoder().decode(ChannelResponse.self, from: jsonData)
                     
                    Task {
                        await
                        saveChannelsToCoreData(channelResponse.channels, context: self.persistentContainer)
                    }
                    
                    loadData()
                    
                } catch {
                    print("Failed to decode JSON: \(error)")
                }
            }
            
        }
        
    }
    
    // MARK: Collection view
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return channelsWithGroup.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return channelsWithGroup[section].channels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let channelCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChannelCollectionViewCell", for: indexPath) as! ChannelCollectionViewCell
        
        let channel = channelsWithGroup[indexPath.section].channels[indexPath.item]
        
        channelCell.label_channelName.text = channel.name
        
        return channelCell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        if kind == UICollectionView.elementKindSectionHeader {
            
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ChannelGroupCollectionViewCell", for: indexPath) as! ChannelGroupCollectionViewCell
                           
            headerView.label_groupName.text = channelsWithGroup[indexPath.section].groupName
            
               return headerView
           }
        
        return UICollectionReusableView()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: 60)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: collectionView.bounds.width, height: 60)
        
    }
    
    // MARK: - Networking
    
    private func getChannels(completion: @escaping (Result<Data, Error>) -> Void) {
        
        let urlString = "https://mofa.onice.io/teamchatapi/channels.list"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        let parameters: [String: String] = [
            "token": PrefManager.shared.getAuthorizationToken() ?? "NA",
            "exclude_members": "true",
            "include_permissions": "false"
        ]
        
        let parameterString = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        guard let postData = parameterString.data(using: .utf8) else {
            completion(.failure(NSError(domain: "Encoding Error", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = postData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = data, let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    completion(.success(data))
                } else {
                    let error = NSError(domain: "HTTP Error", code: httpResponse.statusCode, userInfo: [
                        NSLocalizedDescriptionKey: "Server returned status code \(httpResponse.statusCode)"
                    ])
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    

}
