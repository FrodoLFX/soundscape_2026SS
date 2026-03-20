//
//  AutoCalloutSettingsProvider.swift
//  Soundscape
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.
//

protocol AutoCalloutSettingsProvider: AnyObject {
    var automaticCalloutsEnabled: Bool { get set }
    var placeSenseEnabled: Bool { get set }
    var landmarkSenseEnabled: Bool { get set }
    var mobilitySenseEnabled: Bool { get set }
    var informationSenseEnabled: Bool { get set }
    var safetySenseEnabled: Bool { get set }
    var intersectionSenseEnabled: Bool { get set }
    var destinationSenseEnabled: Bool { get set }
    // 新增：控制呼叫前缀声音是否启用
    var calloutSoundsEnabled: Bool { get set }
    // 新增：控制自动呼叫间隔延迟是否启用
    var calloutDelayEnabled: Bool { get set }
}
