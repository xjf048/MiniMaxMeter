import SwiftUI
import Charts

struct TrendChart: View {
    let dailyUsage: [DailyUsage]
    @State private var days: Int = 7

    private var data: [DailyUsage] {
        Array(dailyUsage.suffix(days))
    }

    private var maxTokens: Int {
        max(1, data.map(\.tokens).max() ?? 1)
    }

    private var totalTokens: Int {
        data.reduce(0) { $0 + $1.tokens }
    }

    private var humanReadableTotal: String {
        let t = Double(totalTokens)
        if t >= 1_000_000_000 { return String(format: "%.2fB", t / 1_000_000_000) }
        if t >= 1_000_000     { return String(format: "%.1fM", t / 1_000_000) }
        if t >= 1_000         { return String(format: "%.1fK", t / 1_000) }
        return "\(Int(t))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("📈 用量趋势").font(.caption.bold())
                Spacer()
                Picker("天数", selection: $days) {
                    Text("7 天").tag(7)
                    Text("30 天").tag(30)
                }
                .pickerStyle(.segmented)
                .controlSize(.mini)
            }

            if data.isEmpty || data.allSatisfy({ $0.tokens == 0 }) {
                Text("暂无数据")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 60)
            } else {
                chart
                    .frame(height: 80)
                HStack {
                    Text("近 \(data.count) 天合计: \(humanReadableTotal)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("峰值: \(humanReadable(maxTokens))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var chart: some View {
        Chart(data) { item in
            AreaMark(
                x: .value("日期", item.date),
                y: .value("Tokens", item.tokens)
            )
            .interpolationMethod(.monotone)
            .foregroundStyle(
                LinearGradient(
                    colors: [Color.accentColor.opacity(0.4), Color.accentColor.opacity(0.05)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )

            LineMark(
                x: .value("日期", item.date),
                y: .value("Tokens", item.tokens)
            )
            .interpolationMethod(.monotone)
            .foregroundStyle(Color.accentColor)
            .lineStyle(StrokeStyle(lineWidth: 1.5))
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: min(data.count, 5))) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.abbreviated).day(), centered: false)
                    .font(.system(size: 9))
            }
        }
        .chartYAxis {
            AxisMarks(position: .trailing, values: .automatic(desiredCount: 3)) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let v = value.as(Int.self) {
                        Text(humanReadable(v))
                            .font(.system(size: 9))
                    }
                }
            }
        }
    }

    private func humanReadable(_ n: Int) -> String {
        let t = Double(n)
        if t >= 1_000_000_000 { return String(format: "%.1fB", t / 1_000_000_000) }
        if t >= 1_000_000     { return String(format: "%.0fM", t / 1_000_000) }
        if t >= 1_000         { return String(format: "%.0fK", t / 1_000) }
        return "\(n)"
    }
}
