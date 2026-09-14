import UIKit

enum HapticService {
    /// The one haptic in the app: the fourth promise kept today.
    @MainActor
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

    @MainActor
    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
