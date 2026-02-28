//  SpeakerMonoModeTests.swift
//
//  这个测试覆盖了 Issue #227 的核心行为：
//  1. `AudioSessionManager` 在扬声器输出时应该返回 `isSpeakerOutput == true`。
//  2. `AudioEngine.connectNodes()` 在扬声器输出时应该设置 `isInMonoMode = true`。
//  3. `TTSSound` 在扬声器输出时应选择 `.standard` 而非空间化类型。

import XCTest
import AVFoundation
@testable import GuideDogs

final class SpeakerMonoModeTests: XCTestCase {

    /// 模拟SessionManager，通过重写 outputType强制返回内置扬声器
    private final class MockSessionManager: AudioSessionManager {
        override var outputType: String {
            return AVAudioSession.Port.builtInSpeaker.rawValue
        }
    }

    /// 验证isSpeakerOutput 在扬声器时为true
    func testAudioSessionManagerSpeakerDetection() {
        let manager = MockSessionManager(mixWithOthers: false)
        XCTAssertTrue(manager.isSpeakerOutput, "isSpeakerOutput 应在扬声器输出时返回 true")
    }

    /// 验证 AudioEngine 在扬声器模式下进入单声道模式。
    func testAudioEngineMonoModeOnSpeaker() {
        let session = MockSessionManager(mixWithOthers: false)
        // 构造 AudioEngine 时需要传入导航服务/传感器，具体类型请根据项目调整。
        let engine = AudioEngine(navigator: nil, sensorData: SensorData())
        engine.sessionManager = session
        engine.connectNodes()
        XCTAssertTrue(engine.isInMonoMode, "内置扬声器输出时 AudioEngine 应配置为 2D（单声道）模式")
    }

    /// 验证在扬声器模式下 TTS 声音类型为 .standard
    func testTTSSoundUsesStandardOnSpeaker() {
        // 扩展 TTSSound 以便测试时覆盖静态属性 isBuiltInSpeakerOutput。
        // 通过动态注入一个临时属性实现测试，如果项目已有测试注入框架则可采用其它方法。
        // 以下是简单方案：临时添加可测试的扩展，仅在测试目标中编译。
        class TTSSoundTest: TTSSound {
            static var testIsSpeaker: Bool = false
            override class var isBuiltInSpeakerOutput: Bool {
                return testIsSpeaker
            }
        }

        TTSSoundTest.testIsSpeaker = true
        let loc = CLLocation(latitude: 0, longitude: 0)
        let tts = TTSSoundTest("测试文本", at: loc)
        switch tts.type {
        case .standard:
            XCTAssertTrue(true)
        default:
            XCTFail("在扬声器输出时，TTSSound 初始化应返回 .standard 类型")
        }
    }
}