//
//  SettingsContext.swift
//  Soundscape
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.
//

import Foundation
import AVFoundation
import CoreLocation

extension Notification.Name {
    static let automaticCalloutsEnabledChanged = Notification.Name("GDAAutomaticCalloutsChanged")
    static let shakeCalloutsEnabledChanged = Notification.Name("GDAShakeCalloutsChanged")
    static let autoCalloutCategorySenseChanged = Notification.Name("GDAAutomaticCalloutSenseChanged")
    static let beaconVolumeChanged = Notification.Name("GDABeaconVolumeChanged")
    static let ttsVolumeChanged = Notification.Name("GDATTSVolumeChanged")
    static let otherVolumeChanged = Notification.Name("GDAOtherVolumeChanged")
    static let beaconGainChanged = Notification.Name("GDABeaconGainChanged")

    static let previewIntersectionsIncludeUnnamedRoadsDidChange = Notification.Name("PreviewIntersectionsIncludeUnnamedRoadsDidChange")

    static let calloutSoundsEnabledChanged = Notification.Name("GDACalloutSoundsEnabledChanged")
    static let calloutDelayEnabledChanged = Notification.Name("GDACalloutDelayEnabledChanged")
    static let calloutDelayIntervalChanged = Notification.Name("GDACalloutDelayIntervalChanged")
    static let autoCalloutSoundsEnabledChanged = Notification.Name("GDAAutoCalloutSoundsEnabledChanged")
}

class SettingsContext {

    struct Keys {
        // MARK: Internal UserDefaults Keys

        /// Number of times the user has open the app
        fileprivate static let appUseCount               = "GDAAppUseCount"
        fileprivate static let newFeaturesLastDisplayedVersion = "GDANewFeaturesLastDisplayedVersion"
        fileprivate static let clientIdentifier          = "GDAUserDefaultClientIdentifier"
        fileprivate static let servicesHostName          = "GDAServicesHostName"
        fileprivate static let metricUnits               = "GDASettingsMetric"
        fileprivate static let locale                    = "GDASettingsLocaleIdentifier"
        fileprivate static let voiceID                   = "GDAAppleSynthVoice"
        fileprivate static let speakingRate              = "GDASettingsSpeakingRate"
        fileprivate static let beaconVolume              = "GDABeaconVolume"
        fileprivate static let ttsVolume                 = "GDATTSVolume"
        fileprivate static let otherVolume               = "GDAOtherVolume"
        fileprivate static let telemetryOptout           = "GDASettingsTelemetryOptout"
        fileprivate static let selectedBeaconName        = "GDASelectedBeaconName"
        fileprivate static let useOldBeacon              = "GDASettingsUseOldBeacon"
        fileprivate static let playBeaconStartEndMelody  = "GDAPlayBeaconStartEndMelody"
        fileprivate static let automaticCalloutsEnabled  = "GDASettingsAutomaticCalloutsEnabled"
        fileprivate static let shakeCalloutsEnabled      = "GDASettingsShakeCalloutsEnabled"
        fileprivate static let sensePlace                = "GDASettingsPlaceSenseEnabled"
        fileprivate static let senseLandmark             = "GDASettingsLandmarkSenseEnabled"
        fileprivate static let senseMobility             = "GDASettingsMobilitySenseEnabled"
        fileprivate static let senseInformation          = "GDASettingsInformationSenseEnabled"
        fileprivate static let senseSafety               = "GDASettingsSafetySenseEnabled"
        fileprivate static let senseIntersection         = "GDASettingsIntersectionsSenseEnabled"
        fileprivate static let senseDestination          = "GDASettingsDestinationSenseEnabled"
        fileprivate static let apnsDeviceToken           = "GDASettingsAPNsDeviceToken"
        fileprivate static let pushNotificationTags      = "GDASettingsPushNotificationTags"
        fileprivate static let previewIntersectionsIncludeUnnamedRoads = "GDASettingsPreviewIntersectionsIncludeUnnamedRoads"
        fileprivate static let audioSessionMixesWithOthers = "GDAAudioSessionMixesWithOthers"
        fileprivate static let markerSortStyle           = "GDAMarkerSortStyle"
        fileprivate static let leaveImmediateVicinityDistance = "GDALeaveImmediateVicinityDistance"
        fileprivate static let enterImmediateVicinityDistance = "GDAEnterImmediateVicinityDistance"

        fileprivate static let ttsGain                   = "GDATTSAudioGain"
        fileprivate static let beaconGain                = "GDABeaconAudioGain"
        fileprivate static let afxGain                   = "GDAAFXAudioGain"

        fileprivate static let calloutSoundsEnabled      = "GDACalloutSoundsEnabled"
        fileprivate static let calloutDelayEnabled       = "GDACalloutDelayEnabled"
        fileprivate static let calloutDelayInterval      = "GDACalloutDelayInterval"

        // MARK: Notification Keys

        static let enabled = "GDAEnabled"
        static let interval = "GDACalloutDelayIntervalValue"
        fileprivate static let autoCalloutSoundsEnabled = "GDAAutoCalloutSoundsEnabled"
        // MARK: Notification Keys
        static let enabled = "GDAEnabled"
        static let interval = "GDACalloutDelayIntervalValue"
    }

    // MARK: Shared Instance

    static let shared = SettingsContext()

    // MARK: User Defaults

    private var userDefaults: UserDefaults {
        return UserDefaults.standard
    }

    // MARK: Initialization

    init() {
        // register default values
        userDefaults.register(defaults: [
            Keys.calloutSoundsEnabled: true,
            Keys.calloutDelayEnabled: true,
            Keys.calloutDelayInterval: 1.5,

            Keys.appUseCount: 0,
            Keys.newFeaturesLastDisplayedVersion: "0.0.0",
            Keys.metricUnits: Locale.current.usesMetricSystem,
            Keys.speakingRate: 0.55,
            Keys.beaconVolume: 0.75,
            Keys.ttsVolume: 0.75,
            Keys.otherVolume: 0.75,
            Keys.ttsGain: 5,
            Keys.beaconGain: 5,
            Keys.afxGain: 5,
            Keys.telemetryOptout: (BuildSettings.configuration != .release),
            Keys.selectedBeaconName: V2Beacon.description,
            Keys.useOldBeacon: false,
            Keys.playBeaconStartEndMelody: false,
            Keys.automaticCalloutsEnabled: true,
            Keys.shakeCalloutsEnabled: false,
            Keys.sensePlace: true,
            Keys.senseLandmark: true,
            Keys.senseMobility: true,
            Keys.senseInformation: true,
            Keys.senseSafety: true,
            Keys.senseIntersection: true,
            Keys.senseDestination: true,
            Keys.previewIntersectionsIncludeUnnamedRoads: false,
            Keys.audioSessionMixesWithOthers: true,
            Keys.markerSortStyle: SortStyle.distance.rawValue,
            Keys.leaveImmediateVicinityDistance: 30.0,
            Keys.enterImmediateVicinityDistance: 15.0
            Keys.calloutSoundsEnabled: true,
            Keys.calloutDelayEnabled: true,
            Keys.calloutDelayInterval: 1.5,
            Keys.autoCalloutSoundsEnabled: true
        ])

        resetLocaleIfNeeded()
    }

    private func resetLocaleIfNeeded() {
        // If the user has selected a locale in the first launch experience, but did not finish the first
        // launch experience and terminated the app half way, reset the chosen locale when re-opening the app.
        if !FirstUseExperience.didComplete(.oobe) && locale != nil {
            locale = nil
        }
    }

    // MARK: Properties

    var appUseCount: Int {
        get {
            return userDefaults.integer(forKey: Keys.appUseCount)
        } set {
            userDefaults.set(newValue, forKey: Keys.appUseCount)
        }
    }

    var newFeaturesLastDisplayedVersion: String {
        get {
            guard let versionString = userDefaults.string(forKey: Keys.newFeaturesLastDisplayedVersion) else {
                userDefaults.set("0.0.0", forKey: Keys.newFeaturesLastDisplayedVersion)
                return "0.0.0"
            }

            return versionString
        }
        set {
            userDefaults.set(newValue, forKey: Keys.newFeaturesLastDisplayedVersion)
        }
    }

    var clientId: String {
        get {
            if let clientId = userDefaults.string(forKey: Keys.clientIdentifier) {
                return clientId
            } else {
                let clientId = UUID().uuidString
                userDefaults.set(clientId, forKey: Keys.clientIdentifier)
                return clientId
            }
        }
        set(newValue) {
            userDefaults.set(newValue, forKey: Keys.clientIdentifier)
        }
    }

    var servicesHostName: String {
        get {
            // Allow URL to be reset to default when it is cleared
            if let servicesHostName = userDefaults.string(forKey: Keys.servicesHostName), !servicesHostName.isEmpty {
                return servicesHostName
            } else {
                let servicesHostName = "https://tiles.soundscape.services"
                userDefaults.set(servicesHostName, forKey: Keys.servicesHostName)
                return servicesHostName
            }
        }
        set(newValue) {
            userDefaults.set(newValue, forKey: Keys.servicesHostName)
        }
    }

    var metricUnits: Bool {
        get {
            return userDefaults.bool(forKey: Keys.metricUnits)
        }
        set(newValue) {
            userDefaults.set(newValue, forKey: Keys.metricUnits)
        }
    }

    /// Cache settings `locale`, as it seems to be expensive to create.
    private var _locale: Locale?

    var locale: Locale? {
        get {
            guard let identifier = userDefaults.string(forKey: Keys.locale) else { return nil }

            if let locale = _locale, locale.identifier == identifier {
                return locale
            }

            let locale = Locale(identifier: identifier)
            _locale = locale

            return locale
        }
        set(newValue) {
            if let newValue = newValue {
                userDefaults.set(newValue.identifier, forKey: Keys.locale)
            } else {
                userDefaults.removeObject(forKey: Keys.locale)
            }
        }
    }

    var speakingRate: Float {
        get {
            return userDefaults.float(forKey: Keys.speakingRate)
        }
        set(newValue) {
            userDefaults.set(newValue, forKey: Keys.speakingRate)
        }
    }

    var beaconVolume: Float {
        get {
            return userDefaults.float(forKey: Keys.beaconVolume)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.beaconVolume)
            NotificationCenter.default.post(name: .beaconVolumeChanged, object: nil)
        }
    }

    var ttsVolume: Float {
        get {
            return userDefaults.float(forKey: Keys.ttsVolume)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.ttsVolume)
            NotificationCenter.default.post(name: .ttsVolumeChanged, object: nil)
        }
    }

    var otherVolume: Float {
        get {
            return userDefaults.float(forKey: Keys.otherVolume)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.otherVolume)
            NotificationCenter.default.post(name: .otherVolumeChanged, object: nil)
        }
    }

    var ttsGain: Float {
        get {
            return userDefaults.float(forKey: Keys.ttsGain)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.ttsGain)
        }
    }

    var beaconGain: Float {
        get {
            return userDefaults.float(forKey: Keys.beaconGain)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.beaconGain)
            NotificationCenter.default.post(name: .beaconGainChanged, object: nil)
        }
    }

    var afxGain: Float {
        get {
            return userDefaults.float(forKey: Keys.afxGain)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.afxGain)
        }
    }

    var telemetryOptout: Bool {
        get {
            return userDefaults.bool(forKey: Keys.telemetryOptout)
        }
        set(newValue) {
            userDefaults.set(newValue, forKey: Keys.telemetryOptout)
        }
    }

    var previewIntersectionsIncludeUnnamedRoads: Bool {
        get {
            return userDefaults.bool(forKey: Keys.previewIntersectionsIncludeUnnamedRoads)
        }
        set(newValue) {
            userDefaults.set(newValue, forKey: Keys.previewIntersectionsIncludeUnnamedRoads)

            NotificationCenter.default.post(name: .previewIntersectionsIncludeUnnamedRoadsDidChange,
                                            object: self,
                                            userInfo: [Keys.enabled: newValue])
        }
    }

    var audioSessionMixesWithOthers: Bool {
        get {
            return userDefaults.bool(forKey: Keys.audioSessionMixesWithOthers)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.audioSessionMixesWithOthers)
        }
    }

    // MARK: Audio Beacon

    var selectedBeacon: String {
        get {
            if let selected = userDefaults.string(forKey: Keys.selectedBeaconName) {
                return selected
            }

            // If the user hasn't selected a new beacon yet, default to the beacon they previously used
            if userDefaults.bool(forKey: Keys.useOldBeacon) {
                return ClassicBeacon.description
            } else {
                return V2Beacon.description
            }
        }
        set {
            userDefaults.set(newValue, forKey: Keys.selectedBeaconName)
        }
    }

    var playBeaconStartAndEndMelodies: Bool {
        get {
            return userDefaults.bool(forKey: Keys.playBeaconStartEndMelody)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.playBeaconStartEndMelody)
        }
    }

    // MARK: Push Notifications

    var apnsDeviceToken: Data? {
        get {
            return userDefaults.data(forKey: Keys.apnsDeviceToken)
        }
        set(newValue) {
            userDefaults.set(newValue, forKey: Keys.apnsDeviceToken)
        }
    }

    var pushNotificationTags: Set<String>? {
        get {
            guard let array = userDefaults.array(forKey: Keys.pushNotificationTags) as? [String] else { return nil }
            return Set(array)
        }
        set(newValue) {
            if let newValue = newValue {
                userDefaults.set(Array(newValue), forKey: Keys.pushNotificationTags)
            } else {
                userDefaults.removeObject(forKey: Keys.pushNotificationTags)
            }
        }
    }

    // MARK: Apple TTS

    var voiceId: String? {
        get {
            return userDefaults.string(forKey: Keys.voiceID)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.voiceID)
        }
    }

    // MARK: Markers and Routes List

    var defaultMarkerSortStyle: SortStyle {
        get {
            guard let sortString = userDefaults.string(forKey: Keys.markerSortStyle),
                  let sort = SortStyle(rawValue: sortString) else {
                return SortStyle.distance
            }

            return sort
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: Keys.markerSortStyle)
        }
    }

    var leaveImmediateVicinityDistance: CLLocationDistance {
        get {
            return userDefaults.double(forKey: Keys.leaveImmediateVicinityDistance) as CLLocationDistance
        }
        set {
            userDefaults.set(newValue, forKey: Keys.leaveImmediateVicinityDistance)
            // Ensure leave is always 15m greater than enter
            userDefaults.set(max(newValue - 15.0, 0.0), forKey: Keys.enterImmediateVicinityDistance)
        }
    }

    var enterImmediateVicinityDistance: CLLocationDistance {
        get {
            return userDefaults.double(forKey: Keys.enterImmediateVicinityDistance) as CLLocationDistance
        }
        set {
            userDefaults.set(newValue, forKey: Keys.enterImmediateVicinityDistance)
            // Ensure leave is always 15m greater than enter
            userDefaults.set(newValue + 15.0, forKey: Keys.leaveImmediateVicinityDistance)
        }
    }
}

extension SettingsContext: AutoCalloutSettingsProvider {
    var calloutSoundsEnabled: Bool {
        get {
            return userDefaults.bool(forKey: Keys.calloutSoundsEnabled)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.calloutSoundsEnabled)
            NotificationCenter.default.post(name: .calloutSoundsEnabledChanged,
                                            object: self,
                                            userInfo: [Keys.enabled: newValue])
        }
    }

    var calloutDelayEnabled: Bool {
        get {
            return userDefaults.bool(forKey: Keys.calloutDelayEnabled)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.calloutDelayEnabled)
            NotificationCenter.default.post(name: .calloutDelayEnabledChanged,
                                            object: self,
                                            userInfo: [Keys.enabled: newValue])
        }
    }

    var calloutDelayInterval: TimeInterval {
        get {
            return userDefaults.double(forKey: Keys.calloutDelayInterval)
        }
        set {
            let clampedValue = min(max(newValue, 0.0), 10.0)
            userDefaults.set(clampedValue, forKey: Keys.calloutDelayInterval)
            NotificationCenter.default.post(name: .calloutDelayIntervalChanged,
                                            object: self,
                                            userInfo: [Keys.interval: clampedValue])
        }
    }

    var automaticCalloutsEnabled: Bool {
        get {
            return userDefaults.bool(forKey: Keys.automaticCalloutsEnabled)
        }
        set(newValue) {
            userDefaults.set(newValue, forKey: Keys.automaticCalloutsEnabled)

            NotificationCenter.default.post(name: .automaticCalloutsEnabledChanged,
                                            object: self,
                                            userInfo: [Keys.enabled: newValue])
        }
    }

    var shakeCalloutsEnabled: Bool {
        get {
            return userDefaults.bool(forKey: Keys.shakeCalloutsEnabled)
        }
        set(newValue) {
            userDefaults.set(newValue, forKey: Keys.shakeCalloutsEnabled)
            NotificationCenter.default.post(name: .shakeCalloutsEnabledChanged,
                                            object: self,
                                            userInfo: [Keys.enabled: newValue])
        }
    }

    var placeSenseEnabled: Bool {
        get {
            return userDefaults.bool(forKey: Keys.sensePlace)
        }
        set(newValue) {
            userDefaults.set(newValue, forKey: Keys.sensePlace)
            NotificationCenter.default.post(name: .autoCalloutCategorySenseChanged, object: self)
        }
    }

    var landmarkSenseEnabled: Bool {
        get {
            return userDefaults.bool(forKey: Keys.senseLandmark)
        }
        set(newValue) {
            userDefaults.set(newValue, forKey: Keys.senseLandmark)
            NotificationCenter.default.post(name: .autoCalloutCategorySenseChanged, object: self)
        }
    }

    var mobilitySenseEnabled: Bool {
        get {
            return userDefaults.bool(forKey: Keys.senseMobility)
        }
        set(newValue) {
            userDefaults.set(newValue, forKey: Keys.senseMobility)
            NotificationCenter.default.post(name: .autoCalloutCategorySenseChanged, object: self)
        }
    }

    var informationSenseEnabled: Bool {
        get {
            return userDefaults.bool(forKey: Keys.senseInformation)
        }
        set(newValue) {
            userDefaults.set(newValue, forKey: Keys.senseInformation)
            NotificationCenter.default.post(name: .autoCalloutCategorySenseChanged, object: self)
        }
    }

    var safetySenseEnabled: Bool {
        get {
            return userDefaults.bool(forKey: Keys.senseSafety)
        }
        set(newValue) {
            userDefaults.set(newValue, forKey: Keys.senseSafety)
            NotificationCenter.default.post(name: .autoCalloutCategorySenseChanged, object: self)
        }
    }

    var intersectionSenseEnabled: Bool {
        get {
            return userDefaults.bool(forKey: Keys.senseIntersection)
        }
        set(newValue) {
            userDefaults.set(newValue, forKey: Keys.senseIntersection)
        }
    }

    var destinationSenseEnabled: Bool {
        get {
            return userDefaults.bool(forKey: Keys.senseDestination)
        }
        set(newValue) {
            userDefaults.set(newValue, forKey: Keys.senseDestination)
        }
    }
}

// MARK: - Convenience utility methods
extension SettingsContext {
    var autoCalloutSoundsEnabled: Bool {
        get {
            return userDefaults.bool(forKey: Keys.autoCalloutSoundsEnabled)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.autoCalloutSoundsEnabled)
            NotificationCenter.default.post(name: .autoCalloutSoundsEnabledChanged,
                                            object: self,
                                            userInfo: [Keys.enabled: newValue])
        }
    }
    /// Export relevant Soundscape settings into a dictionary. This helper returns a dictionary
    /// containing all of the user-tweakable settings maintained by `SettingsContext`.
    func exportSettings() -> [String: Any] {
        var settings: [String: Any] = [:]

        let exportKeys: [String] = [
            Keys.calloutSoundsEnabled,
            Keys.calloutDelayEnabled,
            Keys.calloutDelayInterval,

            Keys.appUseCount,
            Keys.newFeaturesLastDisplayedVersion,
            Keys.metricUnits,
            Keys.locale,
            Keys.voiceID,
            Keys.speakingRate,
            Keys.beaconVolume,
            Keys.ttsVolume,
            Keys.otherVolume,
            Keys.telemetryOptout,
            Keys.selectedBeaconName,
            Keys.useOldBeacon,
            Keys.playBeaconStartEndMelody,
            Keys.automaticCalloutsEnabled,
            Keys.shakeCalloutsEnabled,
            Keys.sensePlace,
            Keys.senseLandmark,
            Keys.senseMobility,
            Keys.senseInformation,
            Keys.senseSafety,
            Keys.senseIntersection,
            Keys.senseDestination,
            Keys.previewIntersectionsIncludeUnnamedRoads,
            Keys.audioSessionMixesWithOthers,
            Keys.markerSortStyle,
            Keys.leaveImmediateVicinityDistance,
            Keys.enterImmediateVicinityDistance,
            Keys.ttsGain,
            Keys.beaconGain,
            Keys.afxGain,
            Keys.apnsDeviceToken,
            Keys.pushNotificationTags
        ]

        for key in exportKeys {
            if let value = userDefaults.object(forKey: key) {
                settings[key] = value
            }
        }

        return settings
    }

    private func boolValue(from value: Any) -> Bool? {
        if let value = value as? Bool {
            return value
        }

        if let value = value as? NSNumber {
            return value.boolValue
        }

        return nil
    }

    private func intValue(from value: Any) -> Int? {
        if let value = value as? Int {
            return value
        }

        if let value = value as? NSNumber {
            return value.intValue
        }

        return nil
    }

    private func floatValue(from value: Any) -> Float? {
        if let value = value as? Float {
            return value
        }

        if let value = value as? NSNumber {
            return value.floatValue
        }

        return nil
    }

    private func doubleValue(from value: Any) -> Double? {
        if let value = value as? Double {
            return value
        }

        if let value = value as? NSNumber {
            return value.doubleValue
        }

        return nil
    }

    /// Import settings previously exported using `exportSettings()`.
    func importSettings(_ settings: [String: Any]) {
        for (key, value) in settings {
            switch key {
            case Keys.calloutSoundsEnabled:
                if let boolValue = boolValue(from: value) {
                    self.calloutSoundsEnabled = boolValue
                }

            case Keys.calloutDelayEnabled:
                if let boolValue = boolValue(from: value) {
                    self.calloutDelayEnabled = boolValue
                }

            case Keys.calloutDelayInterval:
                if let doubleValue = doubleValue(from: value) {
                    self.calloutDelayInterval = doubleValue
                }

            case Keys.appUseCount:
                if let intValue = intValue(from: value) {
                    self.appUseCount = intValue
                }

            case Keys.newFeaturesLastDisplayedVersion:
                if let stringValue = value as? String {
                    self.newFeaturesLastDisplayedVersion = stringValue
                }

            case Keys.metricUnits:
                if let boolValue = boolValue(from: value) {
                    self.metricUnits = boolValue
                }

            case Keys.locale:
                if let identifier = value as? String {
                    self.locale = Locale(identifier: identifier)
                } else {
                    self.locale = nil
                }

            case Keys.voiceID:
                self.voiceId = value as? String

            case Keys.speakingRate:
                if let floatValue = floatValue(from: value) {
                    self.speakingRate = floatValue
                }

            case Keys.beaconVolume:
                if let floatValue = floatValue(from: value) {
                    self.beaconVolume = floatValue
                }

            case Keys.ttsVolume:
                if let floatValue = floatValue(from: value) {
                    self.ttsVolume = floatValue
                }

            case Keys.otherVolume:
                if let floatValue = floatValue(from: value) {
                    self.otherVolume = floatValue
                }

            case Keys.telemetryOptout:
                if let boolValue = boolValue(from: value) {
                    self.telemetryOptout = boolValue
                }

            case Keys.selectedBeaconName:
                if let stringValue = value as? String {
                    self.selectedBeacon = stringValue
                }

            case Keys.useOldBeacon:
                if let boolValue = boolValue(from: value) {
                    self.userDefaults.set(boolValue, forKey: key)
                }

            case Keys.playBeaconStartEndMelody:
                if let boolValue = boolValue(from: value) {
                    self.playBeaconStartAndEndMelodies = boolValue
                }

            case Keys.automaticCalloutsEnabled:
                if let boolValue = boolValue(from: value) {
                    self.automaticCalloutsEnabled = boolValue
                }

            case Keys.shakeCalloutsEnabled:
                if let boolValue = boolValue(from: value) {
                    self.shakeCalloutsEnabled = boolValue
                }

            case Keys.sensePlace:
                if let boolValue = boolValue(from: value) {
                    self.placeSenseEnabled = boolValue
                }

            case Keys.senseLandmark:
                if let boolValue = boolValue(from: value) {
                    self.landmarkSenseEnabled = boolValue
                }

            case Keys.senseMobility:
                if let boolValue = boolValue(from: value) {
                    self.mobilitySenseEnabled = boolValue
                }

            case Keys.senseInformation:
                if let boolValue = boolValue(from: value) {
                    self.informationSenseEnabled = boolValue
                }

            case Keys.senseSafety:
                if let boolValue = boolValue(from: value) {
                    self.safetySenseEnabled = boolValue
                }

            case Keys.senseIntersection:
                if let boolValue = boolValue(from: value) {
                    self.intersectionSenseEnabled = boolValue
                }

            case Keys.senseDestination:
                if let boolValue = boolValue(from: value) {
                    self.destinationSenseEnabled = boolValue
                }

            case Keys.previewIntersectionsIncludeUnnamedRoads:
                if let boolValue = boolValue(from: value) {
                    self.previewIntersectionsIncludeUnnamedRoads = boolValue
                }

            case Keys.audioSessionMixesWithOthers:
                if let boolValue = boolValue(from: value) {
                    self.audioSessionMixesWithOthers = boolValue
                }

            case Keys.markerSortStyle:
                if let rawValue = value as? String,
                   let sort = SortStyle(rawValue: rawValue) {
                    self.defaultMarkerSortStyle = sort
                }

            case Keys.leaveImmediateVicinityDistance:
                if let doubleValue = doubleValue(from: value) {
                    self.leaveImmediateVicinityDistance = doubleValue
                }

            case Keys.enterImmediateVicinityDistance:
                if let doubleValue = doubleValue(from: value) {
                    self.enterImmediateVicinityDistance = doubleValue
                }

            case Keys.ttsGain:
                if let floatValue = floatValue(from: value) {
                    self.ttsGain = floatValue
                }

            case Keys.beaconGain:
                if let floatValue = floatValue(from: value) {
                    self.beaconGain = floatValue
                }

            case Keys.afxGain:
                if let floatValue = floatValue(from: value) {
                    self.afxGain = floatValue
                }

            case Keys.apnsDeviceToken:
                if let data = value as? Data {
                    self.apnsDeviceToken = data
                }

            case Keys.pushNotificationTags:
                if let array = value as? [String] {
                    self.pushNotificationTags = Set(array)
                }

            default:
                continue
            }
        }
    }

    /// Toggle all sense categories on or off with a single call.
    func setAllSensesEnabled(_ enabled: Bool) {
        self.placeSenseEnabled = enabled
        self.landmarkSenseEnabled = enabled
        self.mobilitySenseEnabled = enabled
        self.informationSenseEnabled = enabled
        self.safetySenseEnabled = enabled
        self.intersectionSenseEnabled = enabled
        self.destinationSenseEnabled = enabled
    }

    /// Reset all user-tweakable settings to their default values.
    func resetToDefaults() {
        let keysToReset: [String] = [
            Keys.calloutSoundsEnabled,
            Keys.calloutDelayEnabled,
            Keys.calloutDelayInterval,

            Keys.appUseCount,
            Keys.newFeaturesLastDisplayedVersion,
            Keys.metricUnits,
            Keys.locale,
            Keys.voiceID,
            Keys.speakingRate,
            Keys.beaconVolume,
            Keys.ttsVolume,
            Keys.otherVolume,
            Keys.telemetryOptout,
            Keys.selectedBeaconName,
            Keys.useOldBeacon,
            Keys.playBeaconStartEndMelody,
            Keys.automaticCalloutsEnabled,
            Keys.shakeCalloutsEnabled,
            Keys.sensePlace,
            Keys.senseLandmark,
            Keys.senseMobility,
            Keys.senseInformation,
            Keys.senseSafety,
            Keys.senseIntersection,
            Keys.senseDestination,
            Keys.previewIntersectionsIncludeUnnamedRoads,
            Keys.audioSessionMixesWithOthers,
            Keys.markerSortStyle,
            Keys.leaveImmediateVicinityDistance,
            Keys.enterImmediateVicinityDistance,
            Keys.ttsGain,
            Keys.beaconGain,
            Keys.afxGain,
            Keys.apnsDeviceToken,
            Keys.pushNotificationTags
        ]

        for key in keysToReset {
            userDefaults.removeObject(forKey: key)
        }

        _locale = nil
    }
}
