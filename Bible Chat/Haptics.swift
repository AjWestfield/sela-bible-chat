import UIKit

enum Haptics {
    static func selection(enabled: Bool = true) {
        guard enabled else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    static func lightImpact(enabled: Bool = true) {
        impact(.light, enabled: enabled)
    }

    static func mediumImpact(enabled: Bool = true) {
        impact(.medium, enabled: enabled)
    }

    static func streamTick(enabled: Bool = true) {
        guard enabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred(intensity: 0.38)
    }

    static func success(enabled: Bool = true) {
        guard enabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

    private static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle, enabled: Bool) {
        guard enabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}
