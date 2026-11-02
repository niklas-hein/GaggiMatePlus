import DesignSystem
import SwiftUI

/// A cleaning task's reminder on the machine; it has no counters to show, only whether it's due.
enum CleaningReminder {
    /// The machine is set to ignore it, so it never becomes due.
    case off
    case notDue
    case due
}

struct CleaningState {
    var reminder: CleaningReminder
    var isRunning = false
}

/// The machine's two cleaning programs, each run as a system profile.
enum CleaningTask {
    case backflush
    case descaling

    var title: LocalizedStringKey {
        switch self {
        case .backflush: "Backflush"
        case .descaling: "Descale"
        }
    }

    var startTitle: LocalizedStringKey {
        switch self {
        case .backflush: "Start backflush"
        case .descaling: "Start descaling"
        }
    }

    func iconName(isDue: Bool) -> String {
        switch self {
        case .backflush: isDue ? "bubbles.and.sparkles" : "bubbles.and.sparkles.fill"
        case .descaling: isDue ? "flask" : "flask.fill"
        }
    }

    /// What to prepare; the descaling steps follow GaggiMate's program, which pumps through the steam wand.
    var steps: [LocalizedStringKey] {
        switch self {
        case .backflush:
            [
                "Put the blind basket in the portafilter",
                "Add a scoop of detergent",
                "Lock it into the group head",
            ]
        case .descaling:
            [
                "Mix descaler into a full water tank",
                "Put a large container under the steam wand and open it",
                "When it pauses, rinse the tank and fill it with fresh water",
            ]
        }
    }

    var skipsPreparationKey: String {
        switch self {
        case .backflush: "skipsBackflushPreparation"
        case .descaling: "skipsDescalingPreparation"
        }
    }
}

struct CleaningRow: View {
    let task: CleaningTask
    let state: CleaningState

    @AppStorage private var skipsPreparation: Bool
    @State private var showsPreparation = false

    init(task: CleaningTask, state: CleaningState) {
        self.task = task
        self.state = state
        _skipsPreparation = AppStorage(wrappedValue: false, task.skipsPreparationKey)
    }

    var body: some View {
        HStack(spacing: 0) {
            // The long-press menu lifts everything but the button, which renders badly in its preview.
            HStack(spacing: .spacing12) {
                IconDisc(systemName: task.iconName(isDue: state.reminder == .due))
                Text(task.title)
                    .headlineText()
                    .foregroundStyle(.espresso)
                Spacer(minLength: 0)
                status
            }
            .padding(.leading, .spacing20)
            .padding(.trailing, .spacing12)
            .padding(.vertical, .spacing12)
            .background(.milk)
            .contentShape(.contextMenuPreview, .rect(cornerRadius: .radius26))
            .contextMenu {
                if state.reminder != .off && !state.isRunning {
                    // Nothing connects to a machine yet.
                    Button("Mark as done", systemImage: "checkmark") {}
                }
            }
            button
                .buttonStyle(.inlineAction)
                .boldSubheadlineText()
                .padding(.trailing, .spacing20)
        }
        .sheet(isPresented: $showsPreparation) {
            CleaningSheet(task: task)
        }
    }

    @ViewBuilder
    private var status: some View {
        if state.isRunning {
            // Nothing connects to a machine yet, so a program has no start time to count from.
            Text("0:06")
                .subheadlineText()
                .monospacedDigit()
                .foregroundStyle(.denim)
        } else {
            switch state.reminder {
            case .off:
                EmptyView()
            case .notDue:
                Text("Not due")
                    .subheadlineText()
                    .foregroundStyle(.jade)
            case .due:
                Text("Due")
                    .subheadlineText()
                    .foregroundStyle(.terracotta)
            }
        }
    }

    @ViewBuilder
    private var button: some View {
        if state.isRunning {
            // Aborting will send req:process:deactivate: undocumented, but GaggiMate's own dashboard stops with it.
            // Nothing connects to a machine yet.
            Button("Abort") {}
                .foregroundStyle(.raspberry)
        } else {
            Button("Start") {
                // Nothing connects to a machine yet, so skipping the sheet starts nothing.
                if !skipsPreparation {
                    showsPreparation = true
                }
            }
            .foregroundStyle(.espresso)
        }
    }
}

private struct CleaningSheet: View {
    let task: CleaningTask

    @Environment(\.dismiss)
    private var dismiss
    @AppStorage private var skipsPreparation: Bool
    @State private var stopsAsking = false
    @State private var height: CGFloat = 0

    init(task: CleaningTask) {
        self.task = task
        _skipsPreparation = AppStorage(wrappedValue: false, task.skipsPreparationKey)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: .spacing8) {
                Text(task.title)
                    .boldTitle2Text()
                    .foregroundStyle(.espresso)
                Text("Before you start")
                    .subheadlineText()
                    .foregroundStyle(.cocoa)
                VStack(alignment: .leading, spacing: .spacing12) {
                    ForEach(task.steps.indices, id: \.self) { index in
                        Label(task.steps[index], systemImage: "\(index + 1).circle.fill")
                    }
                }
                .headlineText()
                .foregroundStyle(.espresso)
                .padding(.vertical, .spacing12)
                Toggle("Don't ask again", isOn: $stopsAsking)
                    .subheadlineText()
                    .foregroundStyle(.cocoa)
                    .tint(.jade)
                    .padding(.vertical, .spacing12)
                Button {
                    if stopsAsking {
                        skipsPreparation = true
                    }
                    // Nothing connects to a machine yet.
                    dismiss()
                } label: {
                    Text(task.startTitle)
                        .headlineText()
                        .frame(maxWidth: .infinity)
                        // Espresso, the tint, is near white in dark mode.
                        .foregroundStyle(.milk)
                }
                .buttonStyle(.primaryAction)
                .controlSize(.large)
            }
            .padding(.horizontal, .spacing20)
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.size.height + proxy.safeAreaInsets.top + proxy.safeAreaInsets.bottom
            } action: { height = $0 }
            .frame(maxHeight: .infinity, alignment: .top)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.height(height)])
    }
}
