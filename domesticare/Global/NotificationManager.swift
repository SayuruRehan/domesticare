//
//  NotificationManager.swift
//  domesticare
//
//  Created by Sayuru Rehan on 2025-04-21.
//

import UserNotifications

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {

    static let shared = NotificationManager()

    // MARK: – Setup
    func configure() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            if !granted { NSLog("⛔️ Notification permission not granted") }
        }
    }

    // MARK: – Refill reminder
    func scheduleRefillReminder(for drug: DrugInventoryModel,
                                dailyDose: Int64) {

        guard dailyDose > 0,
              drug.remainingQuantity <= dailyDose * 3 else { return }

        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("Time to Refill", comment: "")
        content.body  = String(
            format: NSLocalizedString("%@ is running low – only %d left.", comment: ""),
            drug.name, drug.remainingQuantity
        )
        content.sound = .default

        // create the trigger explicitly
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(
            identifier: "refill-\(drug.uuid.uuidString)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }


    // MARK: – Foreground display
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler handler:
                                @escaping (UNNotificationPresentationOptions) -> Void) {
        handler([.banner, .sound])
    }
}
