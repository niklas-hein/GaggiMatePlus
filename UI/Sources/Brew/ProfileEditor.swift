import DesignSystem
import SwiftUI

struct ProfileEditor: View {
    @Binding var profile: BrewProfile
    /// Whether the machine has a pressure sensor (`cp`), which pressure and flow targets need.
    let measuresPressure: Bool
    /// The phase open in its editor. Pushed from here, as a link on the row moves to another section when the phase
    /// changes type, which would stop updating its editor.
    @State private var openPhase: BrewPhase.ID?

    var body: some View {
        ScrollView {
            VStack(spacing: .spacing32) {
                VStack(spacing: 0) {
                    EditorRow("Name") {
                        TextField("Name", text: $profile.name)
                    }
                    Divider()
                        .padding(.leading, .spacing20)
                    EditorRow("Temperature") {
                        TextField("Temperature", value: $profile.temperature, format: .number)
                            .keyboardType(.decimalPad)
                        Text("°C")
                    }
                    Divider()
                        .padding(.leading, .spacing20)
                    EditorRow("Dose") {
                        TextField("None", value: $profile.dose, format: .number)
                            .keyboardType(.decimalPad)
                        Text("g")
                    }
                    Divider()
                        .padding(.leading, .spacing20)
                    TextField("Description", text: $profile.description, axis: .vertical)
                        .headlineText()
                        .foregroundStyle(.ink)
                        .padding(.horizontal, .spacing20)
                        .padding(.vertical, .spacing12)
                }
                .background(.snow, in: .rect(cornerRadius: .radius26))
                if !profile.phases.isEmpty {
                    ProfileCurve(phases: profile.phases)
                        .padding(.horizontal, .spacing20)
                        .padding(.vertical, .spacing16)
                        .background(.snow, in: .rect(cornerRadius: .radius26))
                }
                ForEach(sections) { section in
                    VStack(alignment: .leading, spacing: .spacing8) {
                        Text(section.kind.title)
                            .boldSubheadlineText()
                            .foregroundStyle(.slate)
                            .padding(.horizontal, .spacing20)
                        ForEach(profile.phases[section.indices]) { phase in
                            Button {
                                openPhase = phase.id
                            } label: {
                                PhaseRow(phases: profile.phases, phase: phase)
                            }
                            .buttonStyle(.plain)
                        }
                        .reorderable(collectionID: section.id)
                        if section.indices.isEmpty {
                            // A section takes a drop only through a row, so with no phases its add row is one.
                            ForEach([PhaseSection.emptyRow], id: \.self) { _ in
                                addRow(for: section)
                            }
                            .reorderable(collectionID: section.id)
                        } else {
                            addRow(for: section)
                        }
                    }
                }
            }
            .reorderContainer(for: BrewPhase.self, in: PhaseSection.ID.self, move: move)
            .padding(.horizontal, .spacing16)
        }
        .background(.mist)
        .navigationBar(title: LocalizedStringKey(profile.name))
        .navigationDestination(item: $openPhase) { id in
            if let index = profile.phases.firstIndex(where: { $0.id == id }) {
                PhaseEditor(
                    phase: $profile.phases[index],
                    profileTemperature: profile.temperature,
                    measuresPressure: measuresPressure
                ) {
                    withAnimation {
                        profile.phases.removeAll { $0.id == id }
                    }
                }
            }
        }
    }

    private func addRow(for section: PhaseSection) -> some View {
        CardButton(title: section.kind.addTitle, systemImage: "plus") {
            profile.phases.insert(.new(section.kind), at: section.indices.upperBound)
        }
    }

    /// Moves phases to a place in a section; a phase that lands in the other type's section takes that type.
    private func move(_ difference: ReorderDifference<BrewPhase.ID, PhaseSection.ID>) {
        guard let section = sections.first(where: { $0.id == difference.destination.collectionID }) else {
            return
        }
        let isMoved = { (phase: BrewPhase) in difference.sources.contains(phase.id) }
        let moved = profile.phases.filter(isMoved).map { phase in
            var phase = phase
            phase.kind = section.kind
            return phase
        }
        var phases = profile.phases.filter { !isMoved($0) }
        let end = profile.phases[..<section.indices.upperBound].count { !isMoved($0) }
        let index = switch difference.destination.position {
        case let .before(id):
            phases.firstIndex { $0.id == id } ?? end
        case .end:
            end
        }
        phases.insert(contentsOf: moved, at: index)
        profile.phases = phases
    }

    /// Runs of phases of one type, in order; a type with no phases gets an empty section, so it can get its first.
    private var sections: [PhaseSection] {
        var sections: [PhaseSection] = []
        for index in profile.phases.indices {
            let kind = profile.phases[index].kind
            if let last = sections.last, last.kind == kind {
                sections[sections.count - 1].indices = last.indices.lowerBound ..< index + 1
            } else {
                sections.append(PhaseSection(kind: kind, indices: index ..< index + 1))
            }
        }
        if !sections.contains(where: { $0.kind == .preinfusion }) {
            sections.insert(PhaseSection(kind: .preinfusion, indices: 0 ..< 0), at: 0)
        }
        if !sections.contains(where: { $0.kind == .brew }) {
            let end = profile.phases.count
            sections.append(PhaseSection(kind: .brew, indices: end ..< end))
        }
        return sections
    }
}

private struct PhaseSection: Identifiable {
    /// The add row's identity in a section with no phases, where it's the row that takes a drop.
    static let emptyRow = UUID()

    let kind: BrewPhase.Kind
    var indices: Range<Int>

    var id: String { "\(kind)\(indices.lowerBound)" }
}

private extension BrewPhase.Kind {
    var addTitle: LocalizedStringKey {
        switch self {
        case .preinfusion: "Add pre-infusion phase"
        case .brew: "Add brew phase"
        }
    }
}
