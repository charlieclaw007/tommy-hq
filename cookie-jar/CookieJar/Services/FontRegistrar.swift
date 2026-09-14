import CoreText
import Foundation

/// Registers the bundled Fraunces faces at launch. Registering at runtime
/// keeps the generated Info.plist untouched; if a file is missing the app
/// silently falls back to the system serif design.
enum FontRegistrar {
    static let bundledFonts = ["Fraunces-Bold", "Fraunces-Black"]

    static func registerBundledFonts() {
        for name in bundledFonts {
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else { continue }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}
