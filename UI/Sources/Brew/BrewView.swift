import DesignSystem
import Models
import SwiftUI

struct BrewView: View {
    // Nothing connects to a machine yet.
    let status = MachineStatus.ready(temperature: 92.8)
    let measuresPressure = true
    /// Edits stay here until the app saves them to the machine.
    @State private var profiles = BrewProfile.samples
    /// A profile just added, open in its editor.
    @State private var newProfile: BrewProfile.ID?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .spacing32) {
                Text(status.subtitle)
                    .boldHeadlineText()
                    .foregroundStyle(status.ink)
                    .shimmering(status.isInProgress)
                VStack(spacing: 0) {
                    ForEach($profiles) { $profile in
                        if profile.id != profiles.first?.id {
                            Divider()
                                .padding(.leading, .spacing20)
                        }
                        NavigationLink {
                            ProfileEditor(profile: $profile, measuresPressure: measuresPressure)
                        } label: {
                            ProfileRow(profile: profile)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .background(.snow, in: .rect(cornerRadius: .radius26))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, .spacing16)
        }
        .background(.mist)
        .navigationBar(title: "Brew")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("New profile", systemImage: "plus") {
                    let profile = BrewProfile.new()
                    profiles.append(profile)
                    newProfile = profile.id
                }
            }
        }
        .navigationDestination(item: $newProfile) { id in
            if let index = profiles.firstIndex(where: { $0.id == id }) {
                ProfileEditor(profile: $profiles[index], measuresPressure: measuresPressure)
            }
        }
    }
}

private struct ProfileRow: View {
    let profile: BrewProfile

    var body: some View {
        HStack(spacing: .spacing12) {
            Text(profile.name)
                .headlineText()
                .foregroundStyle(.ink)
            Spacer(minLength: 0)
            // Nothing connects to a machine yet.
            Button("Start") {}
                .buttonStyle(.inlineAction)
                .boldSubheadlineText()
                .foregroundStyle(.ink)
        }
        .padding(.horizontal, .spacing20)
        .padding(.vertical, .spacing12)
        .contentShape(.rect)
    }
}

private extension MachineStatus {
    var ink: Color {
        switch self {
        case .ready: .jade
        case .heating, .warning, .needsUpdate: .terracotta
        case .error: .raspberry
        case .updating, .flushing, .backflushing, .descaling: .denim
        case .offline, .connecting, .starting, .autotuning, .standby, .steam, .hotWater, .updateAvailable: .slate
        }
    }
}
