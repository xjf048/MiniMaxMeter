import Foundation

/// 本地缓存上次成功拉到的 snapshot，离线 / 接口失败时降级使用
enum Cache {
    private static let key = "MiniMaxMeter.snapshot"

    static func save(_ s: UsageSnapshot) {
        guard let data = try? JSONEncoder().encode(EncodableSnapshot(s)) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    static func load() -> UsageSnapshot? {
        guard let data = UserDefaults.standard.data(forKey: key),
              let dec = try? JSONDecoder().decode(EncodableSnapshot.self, from: data) else { return nil }
        return dec.toSnapshot()
    }
}

// 重新编码：Quota 不直接 Codable（computed property），用包装
private struct EncodableSnapshot: Codable {
    let fiveHourUsed: Int
    let fiveHourRemaining: Int
    let fiveHourTotal: Int
    let fiveHourRemainingSeconds: Double
    let fiveHourResetAt: Date
    let fiveHourStatus: Int

    let weeklyUsed: Int
    let weeklyRemaining: Int
    let weeklyTotal: Int
    let weeklyRemainingSeconds: Double
    let weeklyResetAt: Date
    let weeklyStatus: Int

    let fetchedAt: Date

    init(_ s: UsageSnapshot) {
        fiveHourUsed = s.fiveHour.usedPercent
        fiveHourRemaining = Int(s.fiveHour.remainingFraction * 100)
        fiveHourTotal = s.fiveHour.totalPercent
        fiveHourRemainingSeconds = s.fiveHour.remainingSeconds
        fiveHourResetAt = s.fiveHour.resetAt
        fiveHourStatus = s.fiveHour.status

        weeklyUsed = s.weekly.usedPercent
        weeklyRemaining = Int(s.weekly.remainingFraction * 100)
        weeklyTotal = s.weekly.totalPercent
        weeklyRemainingSeconds = s.weekly.remainingSeconds
        weeklyResetAt = s.weekly.resetAt
        weeklyStatus = s.weekly.status

        fetchedAt = s.fetchedAt
    }

    func toSnapshot() -> UsageSnapshot {
        let f = Quota(
            usedFraction: Double(fiveHourUsed) / Double(fiveHourTotal),
            remainingFraction: Double(fiveHourRemaining) / 100.0,
            totalPercent: fiveHourTotal,
            usedPercent: fiveHourUsed,
            remainingSeconds: fiveHourRemainingSeconds,
            resetAt: fiveHourResetAt,
            status: fiveHourStatus
        )
        let w = Quota(
            usedFraction: Double(weeklyUsed) / Double(weeklyTotal),
            remainingFraction: Double(weeklyRemaining) / 100.0,
            totalPercent: weeklyTotal,
            usedPercent: weeklyUsed,
            remainingSeconds: weeklyRemainingSeconds,
            resetAt: weeklyResetAt,
            status: weeklyStatus
        )
        return UsageSnapshot(fiveHour: f, weekly: w, fetchedAt: fetchedAt)
    }
}
