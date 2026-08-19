import Foundation
import UIKit
import PDFKit

struct TherapistExportService {

    static func generatePDFData(
        profile: ChildProfileModel,
        sensoryProfile: SensoryProfile,
        allFoods: [FoodItem]
    ) -> Data {
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 48
        let contentWidth = pageWidth - margin * 2
        let footerReserve: CGFloat = 56

        let titleFont = UIFont.boldSystemFont(ofSize: 20)
        let headerFont = UIFont.boldSystemFont(ofSize: 13)
        let bodyFont = UIFont.systemFont(ofSize: 11)
        let smallFont = UIFont.systemFont(ofSize: 10)
        let italicFont = UIFont.italicSystemFont(ofSize: 9)

        let titleColor = UIColor.black
        let headerColor = UIColor(red: 0.15, green: 0.22, blue: 0.32, alpha: 1)
        let bodyColor = UIColor.black
        let mutedColor = UIColor.darkGray

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .omitted

        let exportedOn = Date()
        let rangeStart = earliestLogDate(profile: profile)
        let rangeEnd = latestLogDate(profile: profile) ?? exportedOn

        _ = sensoryProfile
        let firstName = childFirstName(profile.name)
        let likedFoods = profile.safeFoodIds.compactMap { id in allFoods.first { $0.id == id } }
        let loggedQuests = profile.questProgressItems
            .filter { hasRealLoggedSteps($0) }
            .sorted { ($0.lastAttemptDate ?? .distantPast) > ($1.lastAttemptDate ?? .distantPast) }
        let allergenLabels = profile.excludedAllergens.map(\.label).sorted()
        let doNotGiveNames = profile.neverOfferFoodIds.compactMap { id in
            allFoods.first { $0.id == id }?.name
        }

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))
        return renderer.pdfData { context in
            context.beginPage()
            var y: CGFloat = margin

            func ensureSpace(_ needed: CGFloat) {
                if y + needed > pageHeight - margin - footerReserve {
                    drawFooter(in: context)
                    context.beginPage()
                    y = margin
                }
            }

            func draw(_ text: String, font: UIFont, color: UIColor, indent: CGFloat = 0, extraGap: CGFloat = 3) {
                let width = contentWidth - indent
                let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
                let ns = text as NSString
                let bounds = ns.boundingRect(
                    with: CGSize(width: width, height: 2000),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: attrs,
                    context: nil
                )
                let height = ceil(bounds.height)
                ensureSpace(height + extraGap)
                ns.draw(in: CGRect(x: margin + indent, y: y, width: width, height: height), withAttributes: attrs)
                y += height + extraGap
            }

            func hairline() {
                ensureSpace(12)
                let path = UIBezierPath()
                path.move(to: CGPoint(x: margin, y: y))
                path.addLine(to: CGPoint(x: pageWidth - margin, y: y))
                UIColor.lightGray.setStroke()
                path.lineWidth = 0.5
                path.stroke()
                y += 10
            }

            draw("Sensory Galaxy — Progress summary", font: titleFont, color: titleColor, extraGap: 8)

            if let firstName {
                draw("Child: \(firstName), age \(profile.age)", font: bodyFont, color: bodyColor)
            } else {
                draw("Age: \(profile.age)", font: bodyFont, color: bodyColor)
            }
            draw("Explorer: \(profile.explorerDisplayName)", font: bodyFont, color: bodyColor)
            draw("Exported on: \(dateFormatter.string(from: exportedOn))", font: smallFont, color: mutedColor)
            if Calendar.current.isDate(rangeStart, inSameDayAs: rangeEnd) {
                draw("Date range: \(dateFormatter.string(from: rangeStart))", font: smallFont, color: mutedColor)
            } else {
                draw(
                    "Date range: \(dateFormatter.string(from: rangeStart)) – \(dateFormatter.string(from: rangeEnd))",
                    font: smallFont,
                    color: mutedColor
                )
            }

            hairline()

            draw(
                "Lick is not ate. A food is marked eaten only when Taste was logged and a parent confirmed it was swallowed.",
                font: italicFont,
                color: mutedColor,
                extraGap: 10
            )

            draw("Foods they already like", font: headerFont, color: headerColor, extraGap: 4)
            draw(
                "Marked as already-like during setup. Not mastered. Not eaten.",
                font: italicFont,
                color: mutedColor
            )
            if likedFoods.isEmpty {
                draw("None recorded.", font: bodyFont, color: mutedColor, indent: 8)
            } else {
                for food in likedFoods {
                    draw("• \(food.name) — already-like", font: bodyFont, color: bodyColor, indent: 8)
                }
            }
            y += 6

            draw("Foods with logged steps", font: headerFont, color: headerColor, extraGap: 4)
            draw(
                "Real steps only. Setup likes and look-only foods are not listed as explored planets.",
                font: italicFont,
                color: mutedColor
            )
            if loggedQuests.isEmpty {
                draw("No steps logged yet beyond look-only or setup likes.", font: bodyFont, color: mutedColor, indent: 8)
            } else {
                for quest in loggedQuests {
                    guard let food = allFoods.first(where: { $0.id == quest.foodId }) else { continue }
                    let stepNames = SensoryStep.allCases
                        .filter { quest.completedSteps.contains($0) }
                        .map(\.label)
                    let stepsText = stepNames.joined(separator: " / ")
                    let eatenNote: String
                    if wasSwallowed(quest, interactions: profile.interactions) {
                        eatenNote = "  · eaten (taste + swallowed)"
                    } else if quest.completedSteps.contains(.taste) {
                        eatenNote = "  · tasted, not confirmed swallowed. Lick is not ate"
                    } else if quest.completedSteps.contains(.lick) {
                        eatenNote = "  · Lick is not ate"
                    } else {
                        eatenNote = ""
                    }
                    draw("• \(food.name) — \(stepsText)\(eatenNote)", font: bodyFont, color: bodyColor, indent: 8)
                }
            }
            y += 6

            if !allergenLabels.isEmpty || !doNotGiveNames.isEmpty {
                draw("Allergen / do-not-give", font: headerFont, color: headerColor, extraGap: 4)
                if !allergenLabels.isEmpty {
                    draw("Allergens: \(allergenLabels.joined(separator: ", "))", font: bodyFont, color: bodyColor, indent: 8)
                }
                if !doNotGiveNames.isEmpty {
                    draw("Do not give: \(doNotGiveNames.joined(separator: ", "))", font: bodyFont, color: bodyColor, indent: 8)
                }
                y += 6
            }

            if let next = nextSittingLine(profile: profile, allFoods: allFoods) {
                draw(next, font: headerFont, color: headerColor, extraGap: 8)
            }

            drawFooter(in: context)
        }
    }

    static func suggestedFileName(profile: ChildProfileModel) -> String {
        if let first = childFirstName(profile.name) {
            let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
            let cleaned = String(first.unicodeScalars.filter { allowed.contains($0) })
            if !cleaned.isEmpty {
                return "Sensory-Galaxy-progress-\(cleaned).pdf"
            }
        }
        return "Sensory-Galaxy-progress.pdf"
    }

    static func writeShareFile(pdfData: Data, profile: ChildProfileModel) -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(suggestedFileName(profile: profile))
        try? pdfData.write(to: url, options: .atomic)
        return url
    }

    private static func childFirstName(_ raw: String) -> String? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return trimmed.split(whereSeparator: { $0.isWhitespace }).first.map(String.init)
    }

    private static func hasRealLoggedSteps(_ quest: QuestProgressModel) -> Bool {
        guard !quest.isPreCompleted else { return false }
        return quest.completedSteps.contains { $0 != .look }
    }

    /// Same rule as SensoryProfileCalculator: taste + swallowed. Lick is not ate.
    private static func wasSwallowed(
        _ quest: QuestProgressModel,
        interactions: [SensoryInteractionModel]
    ) -> Bool {
        guard !quest.isPreCompleted else { return false }
        guard quest.completedSteps.contains(.taste) else { return false }
        return interactions.contains { interaction in
            interaction.foodId == quest.foodId
                && interaction.sensoryStep == .taste
                && interaction.completed
                && interaction.tasteVerification == .swallowed
        }
    }

    private static func earliestLogDate(profile: ChildProfileModel) -> Date {
        let interactionDates = profile.interactions.map(\.timestamp)
        let questDates = profile.questProgressItems.compactMap(\.lastAttemptDate)
        return ([profile.createdDate] + interactionDates + questDates).min() ?? profile.createdDate
    }

    private static func latestLogDate(profile: ChildProfileModel) -> Date? {
        let interactionDates = profile.interactions.map(\.timestamp)
        let questDates = profile.questProgressItems.compactMap(\.lastAttemptDate)
        return (interactionDates + questDates).max()
    }

    private static func nextSittingLine(profile: ChildProfileModel, allFoods: [FoodItem]) -> String? {
        let inProgress = profile.questProgressItems
            .filter { !$0.isPreCompleted && !$0.isComplete }
            .sorted { ($0.lastAttemptDate ?? .distantPast) > ($1.lastAttemptDate ?? .distantPast) }
            .first
        if let quest = inProgress, let food = allFoods.first(where: { $0.id == quest.foodId }) {
            return formatNextSitting(step: quest.currentStep ?? .look, foodName: food.name)
        }

        if let targetId = profile.targetFoodId, let food = allFoods.first(where: { $0.id == targetId }) {
            let quest = profile.questProgressItems.first { $0.foodId == targetId }
            return formatNextSitting(step: quest?.currentStep ?? .look, foodName: food.name)
        }

        for raw in [profile.goalFoodName, profile.targetFoodName] {
            let name = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            if !name.isEmpty {
                return formatNextSitting(step: .look, foodName: name)
            }
        }
        return nil
    }

    private static func formatNextSitting(step: SensoryStep, foodName: String) -> String {
        if step == .look {
            return "Next sitting: look at \(foodName)"
        }
        return "Next sitting: \(step.label.lowercased()) \(foodName)"
    }

    private static func drawFooter(in context: UIGraphicsPDFRendererContext) {
        let page = context.pdfContextBounds
        let margin: CGFloat = 48
        let footer = "Inspired by SOS. Not official SOS. Not affiliated with Dr. Kay Toomey. Not a medical record. For conversation with your OT, not instead of their notes."
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.italicSystemFont(ofSize: 8),
            .foregroundColor: UIColor.gray
        ]
        let rect = CGRect(x: margin, y: page.height - 44, width: page.width - margin * 2, height: 28)
        (footer as NSString).draw(in: rect, withAttributes: attrs)
    }
}
