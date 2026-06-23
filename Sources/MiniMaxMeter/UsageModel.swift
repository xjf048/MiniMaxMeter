import Foundation

// MARK: - API Response

struct UsageResponse: Codable {
    let modelRemains: [ModelRemain]
    let baseResp: BaseResp

    enum CodingKeys: String, CodingKey {
        case modelRemains = "model_remains"
        case baseResp = "base_resp"
    }
}

struct BaseResp: Codable {
    let statusCode: Int
    let statusMsg: String

    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case statusMsg = "status_msg"
    }
}

struct ModelRemain: Codable {
    let startTime: Int64
    let endTime: Int64
    let remainsTime: Int64
    let currentIntervalTotalCount: Int
    let currentIntervalUsageCount: Int
    let modelName: String
    let currentWeeklyTotalCount: Int
    let currentWeeklyUsageCount: Int
    let weeklyStartTime: Int64
    let weeklyEndTime: Int64
    let weeklyRemainsTime: Int64
    let currentIntervalStatus: Int
    let currentIntervalRemainingPercent: Int
    let currentWeeklyStatus: Int
    let currentWeeklyRemainingPercent: Int
    let weeklyBoostPermille: Int?

    enum CodingKeys: String, CodingKey {
        case startTime = "start_time"
        case endTime = "end_time"
        case remainsTime = "remains_time"
        case currentIntervalTotalCount = "current_interval_total_count"
        case currentIntervalUsageCount = "current_interval_usage_count"
        case modelName = "model_name"
        case currentWeeklyTotalCount = "current_weekly_total_count"
        case currentWeeklyUsageCount = "current_weekly_usage_count"
        case weeklyStartTime = "weekly_start_time"
        case weeklyEndTime = "weekly_end_time"
        case weeklyRemainsTime = "weekly_remains_time"
        case currentIntervalStatus = "current_interval_status"
        case currentIntervalRemainingPercent = "current_interval_remaining_percent"
        case currentWeeklyStatus = "current_weekly_status"
        case currentWeeklyRemainingPercent = "current_weekly_remaining_percent"
        case weeklyBoostPermille = "weekly_boost_permille"
    }
}

// MARK: - Domain Model

struct Quota {
    /// 0.0 ~ 1.0
    let usedFraction: Double
    /// 0.0 ~ 1.0，原始字段是 0-100，归一化
    let remainingFraction: Double
    /// 总额度百分比（如 100、150）
    let totalPercent: Int
    /// 已用百分比 = totalPercent - totalPercent * remainingFraction
    let usedPercent: Int
    /// 倒计时（秒）
    let remainingSeconds: TimeInterval
    /// 重置时间（绝对时间）
    let resetAt: Date
    /// 状态: 1=active, 3=disabled
    let status: Int

    var isActive: Bool { status == 1 }

    var remainingText: String {
        Quota.format(remainingSeconds: remainingSeconds)
    }
}

struct UsageSnapshot {
    let fiveHour: Quota
    let weekly: Quota
    let fetchedAt: Date

    static let placeholder = UsageSnapshot(
        fiveHour: Quota(
            usedFraction: 0, remainingFraction: 1.0, totalPercent: 100,
            usedPercent: 0, remainingSeconds: 0, resetAt: .distantFuture, status: 3
        ),
        weekly: Quota(
            usedFraction: 0, remainingFraction: 1.0, totalPercent: 150,
            usedPercent: 0, remainingSeconds: 0, resetAt: .distantFuture, status: 3
        ),
        fetchedAt: .distantPast
    )
}

extension Quota {
    /// 把 `model_remains[model_name == "general"]` 解析成 5h + 周 两个 Quota
    static func from(_ r: ModelRemain, now: Date = Date()) -> (fiveHour: Quota, weekly: Quota)? {
        guard r.modelName == "general" else { return nil }

        let fiveHour = Quota(
            usedFraction: 1.0 - Double(r.currentIntervalRemainingPercent) / 100.0,
            remainingFraction: Double(r.currentIntervalRemainingPercent) / 100.0,
            totalPercent: 100,
            usedPercent: max(0, 100 - r.currentIntervalRemainingPercent),
            remainingSeconds: TimeInterval(r.remainsTime) / 1000.0,
            resetAt: Date(timeIntervalSince1970: TimeInterval(r.endTime) / 1000.0),
            status: r.currentIntervalStatus
        )

        let weeklyTotal = (r.weeklyBoostPermille ?? 1000) / 10
        let weeklyUsed = Int(round(Double(weeklyTotal) * (1.0 - Double(r.currentWeeklyRemainingPercent) / 100.0)))

        let weekly = Quota(
            usedFraction: 1.0 - Double(r.currentWeeklyRemainingPercent) / 100.0,
            remainingFraction: Double(r.currentWeeklyRemainingPercent) / 100.0,
            totalPercent: weeklyTotal,
            usedPercent: weeklyUsed,
            remainingSeconds: TimeInterval(r.weeklyRemainsTime) / 1000.0,
            resetAt: Date(timeIntervalSince1970: TimeInterval(r.weeklyEndTime) / 1000.0),
            status: r.currentWeeklyStatus
        )

        return (fiveHour, weekly)
    }

    static func format(remainingSeconds: TimeInterval) -> String {
        let s = max(0, Int(remainingSeconds))
        let days = s / 86_400
        let hours = (s % 86_400) / 3_600
        let mins = (s % 3_600) / 60
        if days > 0 { return "\(days) 天 \(hours) 小时" }
        if hours > 0 { return "\(hours) 小时 \(mins) 分" }
        return "\(mins) 分"
    }
}
