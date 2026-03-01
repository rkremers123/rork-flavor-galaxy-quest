import SwiftUI

struct CalendarProgressView: View {
    let viewModel: AppViewModel
    @State private var selectedMonth: Date = Date()
    @State private var selectedDay: Date?

    private let calendar = Calendar.current
    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedMonth)
    }

    private var daysInMonth: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: selectedMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth)) else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: firstDay) - 1
        var days: [Date?] = Array(repeating: nil, count: firstWeekday)

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }

        while days.count % 7 != 0 {
            days.append(nil)
        }

        return days
    }

    private func activityForDate(_ date: Date) -> DayActivity {
        let dayStart = calendar.startOfDay(for: date)
        let interactions = viewModel.profile.interactions.filter {
            calendar.startOfDay(for: $0.timestamp) == dayStart
        }
        if interactions.isEmpty { return .none }

        let completedFoodCount = Set(interactions.filter { $0.completed }.map { $0.foodId }).count
        let hasMilestoneQuest = viewModel.profile.questProgressItems.contains { progress in
            guard progress.isComplete, let attemptDate = progress.lastAttemptDate else { return false }
            return calendar.startOfDay(for: attemptDate) == dayStart
        }

        if completedFoodCount >= 3 || hasMilestoneQuest { return .milestone }
        return .logged
    }

    var body: some View {
        VStack(spacing: 16) {
            monthNavigator
            weekdayHeader
            calendarGrid

            if let day = selectedDay {
                dayDetailPopup(for: day)
            }

            legendRow
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    private var monthNavigator: some View {
        HStack {
            Button {
                withAnimation(.spring(duration: 0.3)) {
                    selectedMonth = calendar.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.6))
            }

            Spacer()

            Text(monthTitle)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(.white)

            Spacer()

            Button {
                withAnimation(.spring(duration: 0.3)) {
                    selectedMonth = calendar.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .padding(.horizontal, 4)
    }

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(daysOfWeek, id: \.self) { day in
                Text(day)
                    .font(.system(.caption2, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.3))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var calendarGrid: some View {
        let rows = daysInMonth.chunked(into: 7)
        return VStack(spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, week in
                calendarWeekRow(week)
            }
        }
    }

    private func calendarWeekRow(_ week: [Date?]) -> some View {
        HStack(spacing: 0) {
            ForEach(Array(week.enumerated()), id: \.offset) { _, date in
                if let date {
                    calendarDayCell(date)
                } else {
                    Color.clear
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                }
            }
        }
    }

    private func calendarDayCell(_ date: Date) -> some View {
        let activity = activityForDate(date)
        let isToday = calendar.isDateInToday(date)
        let isSelected = selectedDay.map { calendar.isDate($0, inSameDayAs: date) } ?? false
        let dayNumber = calendar.component(.day, from: date)
        let isFuture = date > Date()

        return Button {
            withAnimation(.spring(duration: 0.2)) {
                selectedDay = isSelected ? nil : date
            }
        } label: {
            CalendarDayCellContent(
                dayNumber: dayNumber,
                activity: activity,
                isToday: isToday,
                isSelected: isSelected,
                isFuture: isFuture
            )
        }
    }

    private var legendRow: some View {
        HStack(spacing: 16) {
            HStack(spacing: 6) {
                Circle()
                    .fill(SpaceTheme.planetGreen)
                    .frame(width: 8, height: 8)
                Text("Food logged")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.white.opacity(0.4))
            }
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .font(.system(size: 7))
                    .foregroundStyle(SpaceTheme.starGold)
                Text("Milestone")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(.top, 4)
    }

    private func dayDetailPopup(for date: Date) -> some View {
        let dayStart = calendar.startOfDay(for: date)
        let interactions = viewModel.profile.interactions.filter {
            calendar.startOfDay(for: $0.timestamp) == dayStart && $0.completed
        }
        let foodIds = Set(interactions.map { $0.foodId })
        let allFoods = FoodDatabase.allFoods + viewModel.customFoodItems
        let foods = foodIds.compactMap { id in allFoods.first { $0.id == id } }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        return VStack(alignment: .leading, spacing: 8) {
            Text(formatter.string(from: date))
                .font(.system(.caption, design: .rounded, weight: .bold))
                .foregroundStyle(.white.opacity(0.6))

            if foods.isEmpty {
                Text("No activity")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.3))
            } else {
                ForEach(foods, id: \.id) { food in
                    DayFoodRow(food: food, interactions: interactions)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.white.opacity(0.06))
        )
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
}

struct CalendarDayCellContent: View {
    let dayNumber: Int
    let activity: DayActivity
    let isToday: Bool
    let isSelected: Bool
    let isFuture: Bool

    var body: some View {
        ZStack {
            if isToday {
                Circle()
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            }

            if isSelected {
                Circle()
                    .fill(.white.opacity(0.1))
            }

            activityIndicator

            Text("\(dayNumber)")
                .font(.system(.caption, design: .rounded, weight: isToday ? .bold : .medium))
                .foregroundStyle(textColor)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 36)
    }

    @ViewBuilder
    private var activityIndicator: some View {
        switch activity {
        case .logged:
            Circle()
                .fill(SpaceTheme.planetGreen)
                .frame(width: 8, height: 8)
                .offset(y: 12)
        case .milestone:
            Image(systemName: "star.fill")
                .font(.system(size: 7))
                .foregroundStyle(SpaceTheme.starGold)
                .offset(y: 12)
        case .none:
            EmptyView()
        }
    }

    private var textColor: Color {
        if isFuture { return .white.opacity(0.15) }
        if activity != .none { return .white }
        return .white.opacity(0.4)
    }
}

struct DayFoodRow: View {
    let food: FoodItem
    let interactions: [SensoryInteractionModel]

    var body: some View {
        HStack(spacing: 8) {
            Text(food.emoji)
                .font(.caption)
            Text(food.name)
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundStyle(.white)

            let steps = interactions
                .filter { $0.foodId == food.id }
                .compactMap { SensoryStep(rawValue: $0.sensoryStepRawValue) }
            if !steps.isEmpty {
                Text(steps.map(\.label).joined(separator: ", "))
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
    }
}

nonisolated enum DayActivity {
    case none, logged, milestone
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
