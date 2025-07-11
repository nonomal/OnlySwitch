//
//  RadioStationSwitch.swift
//  OnlySwitch
//
//  Created by Jacklandrin on 2021/12/9.
//

import AppKit
import CoreData
import Switches

let defaultRadioStations = [
    ["title":"Country Radio", "url":"https://live.leanstream.co/CKRYFM"],
    ["title":"Dance UK", "url":"http://uk2.internet-radio.com:8024/stream"],
    ["title":"Box UK", "url":"http://51.75.170.46:6191/stream"]
]

final class RadioStationSwitch:SwitchProvider {
    static let shared = RadioStationSwitch()
    var type: SwitchType = .radioStation
    weak var delegate: SwitchDelegate?
    private var managedObjectContext:NSManagedObjectContext?
    
    var playerItem: RadioPlayerItemViewModel = RadioPlayerItemViewModel(isPlaying: false, title: "Country Radio", streamUrl: "http://uk2.internet-radio.com:8024/stream", streamInfo: "", id: UUID())

    init() {
        self.managedObjectContext = PersistenceController.shared.container.viewContext
        
        let currentStationIDStr = Preferences.shared.radioStationID
        if let currentStationIDStr = currentStationIDStr, let currentStationID = UUID(uuidString: currentStationIDStr) {
            let station = RadioStations.fetchRequest(by: currentStationID).first
            guard let station = station else {return}
            setPlayerItem(station: station)
        } else {
            let station = RadioStations.fetchResult.first
            guard let station = station else {return}
            setPlayerItem(station: station)
        }
    }
    
    func setPlayerItem(station:RadioStations) {
        if self.playerItem.isPlaying {
            self.playerItem.isPlaying = false
        }
        
        self.playerItem.title = station.title!
        self.playerItem.streamUrl = station.url!
        self.playerItem.id = station.id!
        self.playerItem.streamInfo = ""
        //refresh player item
        PlayerManager.shared.player.currentPlayerItem = self.playerItem
//        PlayerManager.shared.player.play(stream: self.playerItem)
//        PlayerManager.shared.player.stop()
    }

    @MainActor
    func operateSwitch(isOn: Bool) async throws {
        guard Preferences.shared.radioEnable else {return}
        if isOn {
            self.playerItem.isPlaying = true
        } else {
            self.playerItem.isPlaying = false
            self.playerItem.streamInfo = ""
        }
    }

    @MainActor
    func currentStatus() async -> Bool {
        return playerItem.isPlaying
    }

    @MainActor
    func currentInfo() async -> String {
        return playerItem.title
    }
    
    func isVisible() -> Bool {
        return Preferences.shared.radioEnable
    }
    
    private func firstRadioRun() -> Bool {
//        RadioStations.fetchResult.forEach{ station in
//            managedObjectContext?.delete(station)
//            PersistenceController.shared.saveContext()
//        }
        let hasRun = UserDefaults.standard.bool(forKey: UserDefaults.Key.hasRunRadio)
        if !hasRun {
            UserDefaults.standard.set(true, forKey: UserDefaults.Key.hasRunRadio)
            UserDefaults.standard.synchronize()
        }
        return !hasRun
    }
    
    func setDefaultRadioStations() {
        if firstRadioRun() {
            guard let managedObjectContext = managedObjectContext else {
                fatalError("No Managed Object Context Available")
            }
            for radioDic in defaultRadioStations {
                let radio = RadioStations(context:managedObjectContext)
                radio.title = radioDic["title"]!
                radio.url = radioDic["url"]!
                radio.id = UUID()
                radio.timestamp = Date()
            }
            PersistenceController.shared.saveContext()
        }
    }
}
