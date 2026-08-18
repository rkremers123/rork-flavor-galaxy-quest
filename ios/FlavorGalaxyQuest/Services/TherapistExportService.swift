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
        let margin: CGFloat = 50
        let contentWidth = pageWidth - margin * 2

        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

        let data = pdfRenderer.pdfData { context in
            context.beginPage()
            var yOffset: CGFloat = margin

            let titleFont = UIFont.boldSystemFont(ofSize: 22)
            let headerFont = UIFont.boldSystemFont(ofSize: 16)
            let bodyFont = UIFont.systemFont(ofSize: 12)
            let smallFont = UIFont.systemFont(ofSize: 10)
            let boldSmallFont = UIFont.boldSystemFont(ofSize: 10)

            let titleAttrs: [NSAttributedString.Key: Any] = [.font: titleFont, .foregroundColor: UIColor.black]
            let headerAttrs: [NSAttributedString.Key: Any] = [.font: headerFont, .foregroundColor: UIColor.darkGray]
            let bodyAttrs: [NSAttributedString.Key: Any] = [.font: bodyFont, .foregroundColor: UIColor.black]
            let smallAttrs: [NSAttributedString.Key: Any] = [.font: smallFont, .foregroundColor: UIColor.gray]
            let boldSmallAttrs: [NSAttributedString.Key: Any] = [.font: boldSmallFont, .foregroundColor: UIColor.black]

            let title = "Sensory Galaxy — Sensory Progress Report"
            title.draw(at: CGPoint(x: margin, y: yOffset), withAttributes: titleAttrs)
            yOffset += 30

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            let dateStr = "Generated: \(dateFormatter.string(from: Date()))"
            dateStr.draw(at: CGPoint(x: margin, y: yOffset), withAttributes: smallAttrs)
            yOffset += 25

            let line = UIBezierPath()
            line.move(to: CGPoint(x: margin, y: yOffset))
            line.addLine(to: CGPoint(x: pageWidth - margin, y: yOffset))
            UIColor.lightGray.setStroke()
            line.lineWidth = 0.5
            line.stroke()
            yOffset += 15

            "Child Profile".draw(at: CGPoint(x: margin, y: yOffset), withAttributes: headerAttrs)
            yOffset += 22

            let profileLines = [
                "Name: \(profile.name.isEmpty ? "Not provided" : profile.name)",
                "Age: \(profile.age) years old",
                "Explorer: \(profile.explorerDisplayName) (\(profile.explorerType.title))",
                "Days Active: \(sensoryProfile.daysActive)",
                "Total Foods Consumed: \(sensoryProfile.totalFoodsConsumed)",
                "Sensory Archetype: \(sensoryProfile.archetype)"
            ]
            for pLine in profileLines {
                pLine.draw(at: CGPoint(x: margin + 10, y: yOffset), withAttributes: bodyAttrs)
                yOffset += 18
            }
            yOffset += 10

            "Sensory Profile Summary".draw(at: CGPoint(x: margin, y: yOffset), withAttributes: headerAttrs)
            yOffset += 22

            "Texture Distribution:".draw(at: CGPoint(x: margin + 10, y: yOffset), withAttributes: boldSmallAttrs)
            yOffset += 16
            for texture in FoodTexture.allCases {
                let agg = sensoryProfile.textureAggregates[texture]
                let count = agg?.count ?? 0
                let pct = agg?.percentage ?? 0
                let inZone = agg?.isInSuccessZone ?? false
                let marker = inZone ? "✓" : "○"
                let line = "\(marker) \(texture.label): \(count) foods (\(Int(pct))%)"
                line.draw(at: CGPoint(x: margin + 20, y: yOffset), withAttributes: smallAttrs)
                yOffset += 14
            }
            yOffset += 8

            "Flavor Distribution:".draw(at: CGPoint(x: margin + 10, y: yOffset), withAttributes: boldSmallAttrs)
            yOffset += 16
            for flavor in FoodFlavor.allCases {
                let agg = sensoryProfile.flavorAggregates[flavor]
                let count = agg?.count ?? 0
                let pct = agg?.percentage ?? 0
                let inZone = agg?.isInSuccessZone ?? false
                let marker = inZone ? "✓" : "○"
                let fLine = "\(marker) \(flavor.label): \(count) foods (\(Int(pct))%)"
                fLine.draw(at: CGPoint(x: margin + 20, y: yOffset), withAttributes: smallAttrs)
                yOffset += 14
            }
            yOffset += 8

            "Temperature Distribution:".draw(at: CGPoint(x: margin + 10, y: yOffset), withAttributes: boldSmallAttrs)
            yOffset += 16
            for temp in FoodTemperature.allCases {
                let agg = sensoryProfile.temperatureAggregates[temp]
                let count = agg?.count ?? 0
                let pct = agg?.percentage ?? 0
                let tLine = "\(temp.label): \(count) foods (\(Int(pct))%)"
                tLine.draw(at: CGPoint(x: margin + 20, y: yOffset), withAttributes: smallAttrs)
                yOffset += 14
            }
            yOffset += 10

            if !sensoryProfile.successZoneTextures.isEmpty || !sensoryProfile.successZoneFlavors.isEmpty {
                "Success Zones".draw(at: CGPoint(x: margin, y: yOffset), withAttributes: headerAttrs)
                yOffset += 22
                let textures = sensoryProfile.successZoneTextures.map(\.label).joined(separator: ", ")
                let flavors = sensoryProfile.successZoneFlavors.map(\.label).joined(separator: ", ")
                let temps = sensoryProfile.successZoneTemperatures.map(\.label).joined(separator: ", ")
                if !textures.isEmpty {
                    "Textures: \(textures)".draw(at: CGPoint(x: margin + 10, y: yOffset), withAttributes: bodyAttrs)
                    yOffset += 18
                }
                if !flavors.isEmpty {
                    "Flavors: \(flavors)".draw(at: CGPoint(x: margin + 10, y: yOffset), withAttributes: bodyAttrs)
                    yOffset += 18
                }
                if !temps.isEmpty {
                    "Temperatures: \(temps)".draw(at: CGPoint(x: margin + 10, y: yOffset), withAttributes: bodyAttrs)
                    yOffset += 18
                }
                yOffset += 10
            }

            if !sensoryProfile.avoidanceZoneTextures.isEmpty || !sensoryProfile.avoidanceZoneFlavors.isEmpty {
                "Avoidance Zones".draw(at: CGPoint(x: margin, y: yOffset), withAttributes: headerAttrs)
                yOffset += 22
                let avoidT = sensoryProfile.avoidanceZoneTextures.map(\.label).joined(separator: ", ")
                let avoidF = sensoryProfile.avoidanceZoneFlavors.map(\.label).joined(separator: ", ")
                if !avoidT.isEmpty {
                    "Textures: \(avoidT)".draw(at: CGPoint(x: margin + 10, y: yOffset), withAttributes: bodyAttrs)
                    yOffset += 18
                }
                if !avoidF.isEmpty {
                    "Flavors: \(avoidF)".draw(at: CGPoint(x: margin + 10, y: yOffset), withAttributes: bodyAttrs)
                    yOffset += 18
                }
                yOffset += 10
            }

            if yOffset > pageHeight - 200 {
                context.beginPage()
                yOffset = margin
            }

            "Food Quest Progress".draw(at: CGPoint(x: margin, y: yOffset), withAttributes: headerAttrs)
            yOffset += 22

            let quests = profile.questProgressItems
                .filter { !$0.completedStepValues.isEmpty }
                .sorted { ($0.lastAttemptDate ?? .distantPast) > ($1.lastAttemptDate ?? .distantPast) }

            for quest in quests {
                guard let food = allFoods.first(where: { $0.id == quest.foodId }) else { continue }
                if yOffset > pageHeight - 60 {
                    context.beginPage()
                    yOffset = margin
                }
                let steps = quest.completedSteps.map(\.label).joined(separator: ", ")
                let status = quest.isComplete ? "Complete" : "\(quest.completedStepValues.count)/\(SensoryStep.allCases.count) steps"
                let questLine = "\(food.name) — \(status)"
                questLine.draw(at: CGPoint(x: margin + 10, y: yOffset), withAttributes: bodyAttrs)
                yOffset += 16
                if !steps.isEmpty {
                    "  Completed: \(steps)".draw(at: CGPoint(x: margin + 20, y: yOffset), withAttributes: smallAttrs)
                    yOffset += 14
                }
            }
            yOffset += 15

            if yOffset > pageHeight - 100 {
                context.beginPage()
                yOffset = margin
            }

            "Key Metrics".draw(at: CGPoint(x: margin, y: yOffset), withAttributes: headerAttrs)
            yOffset += 22

            let metrics = [
                "Current Streak: \(profile.currentStreak) days",
                "Longest Streak: \(profile.longestStreak) days",
                "Total Interactions: \(profile.interactions.count)",
                "Star Dust Earned: \(profile.totalStarDust)",
                "Safe Foods: \(profile.safeFoodIds.count)"
            ]
            for metric in metrics {
                metric.draw(at: CGPoint(x: margin + 10, y: yOffset), withAttributes: bodyAttrs)
                yOffset += 18
            }
            yOffset += 20

            let footer = "This report was generated by Sensory Galaxy and is based on the SOS (Sequential Oral Sensory) Approach."
            let footerRect = CGRect(x: margin, y: pageHeight - 40, width: contentWidth, height: 20)
            (footer as NSString).draw(in: footerRect, withAttributes: [.font: UIFont.italicSystemFont(ofSize: 8), .foregroundColor: UIColor.gray])
        }

        return data
    }
}
