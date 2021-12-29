//
//  Person.swift
//  Friends
//
//  Created by SANGMIN YEOM on 2021/12/27.
//



// https://randomuser.me/ 참고할 것

import Foundation
import UIKit

struct Person: Codable, Equatable {
    struct Name: Codable, Equatable {
        let title: String
        let first: String
        let last: String
        
        var full: String {
            return (self.title + ". " + self.last + " " + self.first).uppercased()
        }
    }
    
    struct PictureURL : Codable, Equatable {
        let large: URL
        let medium: URL
        let thumbnail: URL
    }
    
    let name: Name
    let cell: String
    let pictureURL: PictureURL
    
    private let nat : String
}

extension Person {
    enum CodingKeys: String, CodingKey {
        case name, cell
        case pictureURL = "picture"
        case nat
    }
}

extension Person {
    var nationality: String {
        return nat.uppercased()
    }
}

extension Person {
    private static let bestFriendFileName: String = "best_friends.json"
    private static var bestFriendFileURL: URL? {
        
        let fileManager : FileManager = FileManager.default
        
        let documentURL: URL
        
        do {
            documentURL = try fileManager.url(for: FileManager.SearchPathDirectory.applicationSupportDirectory,
                                                 in: FileManager.SearchPathDomainMask.userDomainMask,
                                                 appropriateFor: nil,
                                                 create: true)
        } catch {
            print(error.localizedDescription)
            return nil
        }
        
        let fileURL : URL = documentURL.appendingPathComponent(bestFriendFileName)
        
        return fileURL
    }
}

extension Person {
    private static func loadBestFriendsFromFile() -> [Person] {
        guard let fileURL : URL = bestFriendFileURL else { return [] }
        
        do {
            let data : Data = try Data(contentsOf: fileURL)
            
            let decoder : JSONDecoder = JSONDecoder()
            let friends: [Person] = try decoder.decode([Person].self, from: data)
            
            return friends
        }catch {
            print(error.localizedDescription)
            
        }
        return []
    }
}

extension Person {
    static var bestFriends: [Person] = Person.loadBestFriendsFromFile()
}

extension Person {
    static func saveCurrentBestFriendsToFile() -> Bool {
        guard let fileURL : URL = bestFriendFileURL else { return false }
        
        let encodder: JSONEncoder = JSONEncoder()
        
        do {
            let data: Data = try encodder.encode(self.bestFriends)
            try data.write(to: fileURL)
            
            return true
        } catch {
            print(error.localizedDescription)
        }
        
        return false
    }
}

extension Person {
    static func addBestFriend(_ friend: Person, completion: ((_ isSuccess:Bool)->Void)? = nil) {
        self.bestFriends.append(friend)
        
        DispatchQueue.main.async {
            completion?(self.saveCurrentBestFriendsToFile())
        }
    }
}

extension Person {
    private static func bestFriendIndex(of target:Person) -> Int? {
        guard let index: Int = self.bestFriends.firstIndex(where: {(friend:Person)->Bool in friend == target}) else { return nil }
        
        return index
    }
}

extension Person {
    static func removeBestFriend(_ friend:Person, completion: ((_ isSuccess:Bool)->Void)? = nil) {
        if let index: Int = self.bestFriendIndex(of: friend) {
            self.bestFriends.remove(at: index)
            
            DispatchQueue.main.async {
                completion?(self.saveCurrentBestFriendsToFile())
            }
        } else {
            DispatchQueue.main.async {
                completion?(false)
            }
        }
    }
}
