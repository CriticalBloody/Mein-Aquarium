import SwiftUI
import SwiftData
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif

struct BewohnerCardView: View {
    let bewohner: Bewohner
    @State private var isHovering = false

    func germanAgeString(since date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day, .hour], from: date, to: now)
        if let days = components.day, days > 0 {
            if days == 1 {
                return "1 Tag alt"
            } else {
                return "\(days) Tage alt"
            }
        } else if let hours = components.hour, hours > 0 {
            if hours == 1 {
                return "1 Std. alt"
            } else {
                return "\(hours) Std. alt"
            }
        } else {
            return "Gerade eben"
        }
    }

    var mainImage: Image? {
    #if os(macOS)
        if let imageData = bewohner.images, let nsImage = NSImage(data: imageData) {
            return Image(nsImage: nsImage)
        }
    #elseif os(iOS)
        if let imageData = bewohner.images, let uiImage = UIImage(data: imageData) {
            return Image(uiImage: uiImage)
        }
    #endif
        return nil
    }

    var body: some View {
        ZStack {
            HStack(alignment: .center, spacing: 16) {
                // Profilbild/Icon
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.16))
                        .frame(width: 64, height: 64)
                    if let image = mainImage {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Color.white.opacity(0.3), lineWidth: 2)
                            )
                            .shadow(radius: 2, y: 1)
                    } else {
                        Image(systemName: "fish.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.blue)
                            .frame(width: 36, height: 36)
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(bewohner.name.isEmpty ? "Unbekannt" : bewohner.name)
                        .font(.headline.weight(.bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Text(bewohner.art.isEmpty ? "Art unbekannt" : bewohner.art)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    // Aquarium-Label
                    HStack(spacing: 5) {
                        Image(systemName: "drop.fill")
                            .font(.caption2.weight(.bold))
                            .foregroundColor(.accentColor)
                        Text(bewohner.aquarium?.name ?? "Kein Aquarium")
                            .font(.caption2.weight(.semibold))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color.secondary.opacity(0.08)))
                    .padding(.top, 2)

                    if let birthDate = bewohner.birthDate as Date? {
                        Text(germanAgeString(since: birthDate))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.top, 3)
                    } else {
                        Text("Geburtsdatum unbekannt")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.top, 3)
                    }
                }
                Spacer()
                // Chevron
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white.opacity(0.13))
                    .shadow(radius: 6, y: 2)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .frame(width: 270, height: 92)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.systemBackground.opacity(isHovering ? 0.50 : 0.26))
                .shadow(color: Color.black.opacity(isHovering ? 0.24 : 0.07), radius: isHovering ? 32 : 13, x: 0, y: 5)
        )
        .animation(.easeInOut(duration: 0.25), value: isHovering)
        .scaleEffect(isHovering ? 1.04 : 1.0)
        .shadow(color: Color.accentColor.opacity(isHovering ? 0.23 : 0.0), radius: isHovering ? 12 : 0, y: 4)
        .onHover { hovering in
            self.isHovering = hovering
        }
    }
}
