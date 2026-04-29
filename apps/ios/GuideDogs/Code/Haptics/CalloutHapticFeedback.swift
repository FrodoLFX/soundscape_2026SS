import UIKit
import AudioToolbox

struct CalloutHapticFeedback {
    /// 播放一次中等强度的触觉反馈
    static func play() {
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        } else {
            // iOS10 以下兼容：播放系统震动
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
}
