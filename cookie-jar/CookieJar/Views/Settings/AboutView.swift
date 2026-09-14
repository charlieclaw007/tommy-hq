import SwiftUI

/// Short text from the field guide, the verbatim disclaimer, and privacy.
struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 12) {
                    CookieSprite(diameter: 48)
                    Text(Copy.aboutTitle)
                        .font(Theme.titleSerif)
                        .foregroundStyle(Theme.ink)
                }

                aboutSection("Start here", Copy.aboutStartHere)
                aboutSection("Why it works", Copy.aboutWhyItWorks)
                aboutSection("Streaks without shame", Copy.aboutStreaks)
                aboutSection("Where the name comes from", Copy.aboutOrigin)
                aboutSection("Privacy", Copy.aboutPrivacy)

                VStack(alignment: .leading, spacing: 8) {
                    Eyebrow(text: "Please read")
                    Text(Copy.disclaimer)
                        .font(.footnote)
                        .foregroundStyle(Theme.inkSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
                .background(CardBackground())
            }
            .padding(20)
            .padding(.bottom, 24)
        }
        .background(Theme.cream.ignoresSafeArea())
        .navigationTitle(Copy.settingsAbout)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.cream, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private func aboutSection(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Eyebrow(text: title)
            Text(body)
                .font(.body)
                .foregroundStyle(Theme.ink)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    NavigationStack { AboutView() }
}
