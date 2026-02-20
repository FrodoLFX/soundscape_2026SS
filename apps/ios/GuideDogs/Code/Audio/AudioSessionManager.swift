//
//  AudioSessionManager.swift
//  Soundscape
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.
//

import UIKit
import AVFoundation
import MediaPlayer

protocol AudioSessionManagerDelegate: AnyObject {
    func sessionDidActivate()
    func interruptionBegan()
    func interruptionEnded(shouldResume: Bool)
    func mediaServicesWereReset()
    func onOutputRouteOverriden(_ override: AVAudioSession.PortOverride)
}

/// A class that manages the app's audio session (`AVAudioSession`) for audio output.
class AudioSessionManager {

    weak var delegate: AudioSessionManagerDelegate?

    // MARK: Properties

    let session = AVAudioSession.sharedInstance()

    var needsActivation: Bool = true

    private var isInSpeakerMode: Bool = false

    /// This will contain a value if there was an error activating the audio session
    @objc var activationError: NSError?

    /// Returns `true` if the current audio session can support remote control events
    private var canInvokeRemoteControlEvents: Bool {
        return !isMixingWithOthers
    }

    /// Returns `true` if the current audio session should mix with others
    var mixWithOthers: Bool {
        didSet {
            if oldValue != mixWithOthers {
                configureAudioSession()
            }
        }
    }

    /// Returns `true` if the current audio session supports mixing with others
    private var isMixingWithOthers: Bool {
        return session.categoryOptions.contains(.mixWithOthers)
    }

    /// A Boolean value that indicates whether another application is playing audio.
    private var isOtherAudioPlaying: Bool {
        // Apple recommends using this instead of `isOtherAudioPlaying`
        return session.secondaryAudioShouldBeSilencedHint
    }

    /// Returns the current port type description
    var outputType: String {
        guard let output = session.currentRoute.outputs.first else { return "unknown" }
        return output.portType.rawValue
    }

    // NEW: Convenience for detecting built-in speaker output
    var isSpeakerOutput: Bool {
        return outputType == AVAudioSession.Port.builtInSpeaker.rawValue
    }

    /// Returns a dictionary of current state information, useful for telemetry.
    var currentStateInfo: [String: String] {
        return ["output_type": outputType,
                "is_other_audio_playing": String(isOtherAudioPlaying),
                "is_mixing_with_others": String(isMixingWithOthers)]
    }

    // MARK: Initialization

    init(mixWithOthers: Bool) {
        self.mixWithOthers = mixWithOthers

        registerObservers()
        configureAudioSession()
    }

    deinit {
        removeObservers()
    }

    // MARK: Observers

    private func registerObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleMediaServicesWereReset(_:)),
                                               name: AVAudioSession.mediaServicesWereResetNotification,
                                               object: session)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAudioSessionInterruption(_:)),
                                               name: AVAudioSession.interruptionNotification,
                                               object: session)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAudioSessionRouteChange(_:)),
                                               name: AVAudioSession.routeChangeNotification,
                                               object: session)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAudioSessionSilenceSecondaryAudioHint(_:)),
                                               name: AVAudioSession.silenceSecondaryAudioHintNotification,
                                               object: session)
    }

    private func removeObservers() {
        NotificationCenter.default.removeObserver(self,
                                                  name: AVAudioSession.mediaServicesWereResetNotification,
                                                  object: session)

        NotificationCenter.default.removeObserver(self,
                                                  name: AVAudioSession.interruptionNotification,
                                                  object: session)

        NotificationCenter.default.removeObserver(self,
                                                  name: AVAudioSession.routeChangeNotification,
                                                  object: session)

        NotificationCenter.default.removeObserver(self,
                                                  name: AVAudioSession.silenceSecondaryAudioHintNotification,
                                                  object: session)
    }

    // MARK: Methods

    /// - Returns: `true` if audio session configuration was successful, `false` otherwise.
    @discardableResult
    private func configureAudioSession() -> Bool {
        do {
            try session.setCategory(.playback,
                                    mode: .default,
                                    options: mixWithOthers ? [.mixWithOthers] : [])
            GDLogAudioSessionInfo("Category set (playback, default, options: \(mixWithOthers ? "mixWithOthers" : "none"))")
        } catch let error as NSError {
            let avError = AVAudioSession.ErrorCode(rawValue: error.code) ?? .unspecified

            GDLogAudioSessionWarn("An error occured setting the audio session category: \(error) \(avError.description)")

            var telemetryInfo = currentStateInfo
            telemetryInfo["error.code"] = String(error.code)
            telemetryInfo["error.description"] = error.description
            telemetryInfo["av_error.description"] = avError.description
            GDATelemetry.track("audio_session.set_category.error", with: telemetryInfo)

            return false
        }

        return true
    }

    private func shouldActivate() -> Bool {
        // If we are not mixing with others and there is another app playing audio, only allow activating when we are in the foreground.
        // - note: the audio engine trys to activate the audio session when it trys to output audio.
        // If we allow for this to happen anytime, other apps that play audio (Music, Podcasts) will be deactivated even if they are in the foreground.
        if !mixWithOthers && isOtherAudioPlaying {
            return AppContext.isActive
        }

        return needsActivation
    }

    /// Activate the audio session.
    /// - Parameter force: Force activation, discarding the `shouldActivate()` check.
    /// - Returns: `true` if audio session activation was successful, `false` otherwise.
    @discardableResult
    func activate(force: Bool = false) -> Bool {
        guard force || shouldActivate() else {
            GDLogAudioSessionWarn("Audio session does not currently need activation. Skipping...")
            return false
        }

        do {
            try session.setActive(true, options: [])
        } catch let error as NSError {
            let avError = AVAudioSession.ErrorCode(rawValue: error.code) ?? .unspecified

            GDLogAudioSessionWarn("An error occured activating the audio session: \(error) \(avError.description)")

            var telemetryInfo = currentStateInfo
            telemetryInfo["error.code"] = String(error.code)
            telemetryInfo["error.description"] = error.description
            telemetryInfo["av_error.description"] = avError.description
            GDATelemetry.track("audio_session.activate.error", with: telemetryInfo)

            activationError = error
            return false
        }

        activationError = nil
        needsActivation = false

        // Remote control events are only needed in contexts where we can invoke them
        if canInvokeRemoteControlEvents {
            UIApplication.shared.beginReceivingRemoteControlEvents()
        }

        delegate?.sessionDidActivate()
        return true
    }

    /// Deactivate the audio session.
    /// - Parameter force: Force deactivation.
    /// - Returns: `true` if audio session deactivation was successful, `false` otherwise.
    @discardableResult
    func deactivate(force: Bool = false) -> Bool {
        guard force || (!needsActivation && !isOtherAudioPlaying) else {
            GDLogAudioSessionWarn("Audio session does not currently need deactivation. Skipping...")
            return false
        }

        do {
            try session.setActive(false, options: [])
        } catch let error as NSError {
            let avError = AVAudioSession.ErrorCode(rawValue: error.code) ?? .unspecified

            GDLogAudioSessionWarn("An error occured deactivating the audio session: \(error) \(avError.description)")

            var telemetryInfo = currentStateInfo
            telemetryInfo["error.code"] = String(error.code)
            telemetryInfo["error.description"] = error.description
            telemetryInfo["av_error.description"] = avError.description
            GDATelemetry.track("audio_session.deactivate.error", with: telemetryInfo)

            return false
        }

        needsActivation = true

        // Remote control events are only needed in contexts where we can invoke them
        if canInvokeRemoteControlEvents {
            UIApplication.shared.endReceivingRemoteControlEvents()
        }

        return true
    }

    func overrideOutputAudioPort(_ override: AVAudioSession.PortOverride, force: Bool = false) -> Bool {
        guard force || (isInSpeakerMode && override == .none) || (!isInSpeakerMode && override == .speaker) else {
            GDLogAudioSessionInfo("Audio port override already applied (\(override)). Skipping...")
            return false
        }

        do {
            try session.overrideOutputAudioPort(override)
            isInSpeakerMode = override == .speaker
            delegate?.onOutputRouteOverriden(override)
            GDLogAudioSessionInfo("Audio port override applied (\(override)).")
            return true
        } catch let error as NSError {
            let avError = AVAudioSession.ErrorCode(rawValue: error.code) ?? .unspecified

            GDLogAudioSessionWarn("An error occured overriding the audio port: \(error) \(avError.description)")

            var telemetryInfo = currentStateInfo
            telemetryInfo["override"] = override == .speaker ? "speaker" : "none"
            telemetryInfo["error.code"] = String(error.code)
            telemetryInfo["error.description"] = error.description
            telemetryInfo["av_error.description"] = avError.description
            GDATelemetry.track("audio_session.override_output_port.error", with: telemetryInfo)

            return false
        }
    }

    // MARK: Notifications

    @objc private func handleMediaServicesWereReset(_ notification: Notification) {
        GDLogAudioSessionInfo("Media services were reset.")

        // Reset to the default state
        needsActivation = true

        // Reconfigure the session
        configureAudioSession()

        delegate?.mediaServicesWereReset()
    }

    @objc private func handleAudioSessionInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        switch type {
        case .began:
            GDLogAudioSessionInfo("Audio session interruption began.")
            delegate?.interruptionBegan()

        case .ended:
            let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue ?? 0)

            GDLogAudioSessionInfo("Audio session interruption ended (should resume: \(options.contains(.shouldResume))).")
            delegate?.interruptionEnded(shouldResume: options.contains(.shouldResume))
        @unknown default:
            break
        }
    }

    @objc private func handleAudioSessionRouteChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }

        switch reason {
        case .newDeviceAvailable:
            GDLogAudioSessionInfo("New audio device available. Current output: \(outputType)")
        case .oldDeviceUnavailable:
            GDLogAudioSessionInfo("Old audio device unavailable. Current output: \(outputType)")
        case .categoryChange:
            GDLogAudioSessionInfo("Audio session category changed. Current output: \(outputType)")
        case .override:
            GDLogAudioSessionInfo("Audio session route override. Current output: \(outputType)")
            if isInSpeakerMode {
                // The audio route override can be reset by the system (e.g. when a call comes in). Reapply.
                isInSpeakerMode = false
                _ = overrideOutputAudioPort(.speaker, force: true)
            }
        case .wakeFromSleep:
            GDLogAudioSessionInfo("Wake from sleep. Current output: \(outputType)")
        case .noSuitableRouteForCategory:
            GDLogAudioSessionInfo("No suitable route for category. Current output: \(outputType)")
        case .routeConfigurationChange:
            GDLogAudioSessionInfo("Route configuration changed. Current output: \(outputType)")
        case .unknown:
            GDLogAudioSessionInfo("Unknown route change reason. Current output: \(outputType)")
        @unknown default:
            break
        }
    }

    @objc private func handleAudioSessionSilenceSecondaryAudioHint(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionSilenceSecondaryAudioHintTypeKey] as? UInt,
              let type = AVAudioSession.SilenceSecondaryAudioHintType(rawValue: typeValue) else {
            return
        }

        switch type {
        case .begin:
            GDLogAudioSessionInfo("Secondary audio should be silenced.")
        case .end:
            GDLogAudioSessionInfo("Secondary audio can resume.")
        @unknown default:
            break
        }
    }
}
