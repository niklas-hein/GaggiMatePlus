import DesignSystem
import SwiftUI

struct WaterAndCleaningSection: View {
    let isWaterLow: Bool
    let isFlushing: Bool
    let backflush: CleaningState
    let descaling: CleaningState

    var body: some View {
        VStack(alignment: .leading, spacing: .spacing8) {
            Text("Water and cleaning")
                .boldSubheadlineText()
                .foregroundStyle(.cocoa)
                .padding(.horizontal, .spacing20)
            VStack(spacing: 0) {
                WaterTankRow(isLow: isWaterLow)
                Divider()
                    .padding(.leading, .spacing20)
                FlushRow(isFlushing: isFlushing)
                Divider()
                    .padding(.leading, .spacing20)
                CleaningRow(task: .backflush, state: backflush)
                Divider()
                    .padding(.leading, .spacing20)
                CleaningRow(task: .descaling, state: descaling)
            }
            .background(.milk, in: .rect(cornerRadius: .radius26))
        }
    }
}

private struct WaterTankRow: View {
    let isLow: Bool

    var body: some View {
        HStack(spacing: .spacing12) {
            IconDisc(systemName: isLow ? "drop" : "drop.fill")
            Text("Water tank")
                .headlineText()
                .foregroundStyle(.espresso)
            Spacer(minLength: 0)
            Text(isLow ? "Low" : "OK")
                .subheadlineText()
                .foregroundStyle(isLow ? Color.terracotta : Color.jade)
        }
        .padding(.horizontal, .spacing20)
        .padding(.vertical, .spacing12)
    }
}

private struct FlushRow: View {
    let isFlushing: Bool

    var body: some View {
        HStack(spacing: .spacing12) {
            IconDisc(systemName: "water.waves")
            Text("Group head")
                .headlineText()
                .foregroundStyle(.espresso)
            Spacer(minLength: 0)
            if isFlushing {
                // Nothing connects to a machine yet, so a flush has no start time to count from.
                Text("0:04")
                    .subheadlineText()
                    .monospacedDigit()
                    .foregroundStyle(.denim)
            }
            // Nothing connects to a machine yet.
            Button(isFlushing ? "Stop" : "Flush" as LocalizedStringKey) {}
                .buttonStyle(.inlineAction)
                .boldSubheadlineText()
                .foregroundStyle(isFlushing ? Color.raspberry : Color.espresso)
        }
        .padding(.horizontal, .spacing20)
        .padding(.vertical, .spacing12)
    }
}

struct IconDisc: View {
    let systemName: String

    var body: some View {
        // A square symbol sizes the disc, so every icon gets the same one whatever its width.
        Image(systemName: "square")
            .hidden()
            .overlay {
                Image(systemName: systemName)
            }
            .foregroundStyle(.espresso)
            .padding(.spacing8)
            .background(.cream, in: .circle)
    }
}

#Preview("Water and cleaning") {
    ScrollView {
        VStack(spacing: .spacing16) {
            WaterAndCleaningSection(
                isWaterLow: false,
                isFlushing: false,
                backflush: CleaningState(reminder: .notDue),
                descaling: CleaningState(reminder: .off)
            )
            WaterAndCleaningSection(
                isWaterLow: true,
                isFlushing: true,
                backflush: CleaningState(reminder: .due, isRunning: true),
                descaling: CleaningState(reminder: .due)
            )
        }
        .padding(.horizontal, .spacing16)
    }
    .background(.cream)
}
