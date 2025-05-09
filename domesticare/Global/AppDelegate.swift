//
//  AppDelegate.swift
//  domesticare
//
//  Created by Sayuru Rehan on 2025-04-20
//

import UIKit
import CoreData
import BackgroundTasks
import UserNotifications

let appDelegate = UIApplication.shared.delegate as! AppDelegate

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let navController = UINavigationController()
    lazy var coordinator = MainCoordinator(navigationController: self.navController)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow()
        window?.tintColor = .systemRed
        window?.backgroundColor = .systemBackground
        window?.makeKeyAndVisible()
        window?.rootViewController = navController
        coordinator.start()
        NotificationManager.shared.configure()
        registerBackgroundTasks()
        scheduleAutoDecrement()
        return true
    }

    // MARK: UISceneSession Lifecycle

//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentCloudKitContainer(name: "domesticare")
        
        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        try? container.initializeCloudKitSchema(options: [])
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    

    // Identifier must also be added to Info.plist > BGTaskSchedulerPermittedIdentifiers
    private let autoDecrementTaskID = "com.sayururehan.domesticare.autodecrement"

    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: autoDecrementTaskID,
                                        using: nil) { [weak self] task in
            self?.handleAutoDecrement(task: task as! BGAppRefreshTask)
        }
    }

    private func scheduleAutoDecrement() {
        let request = BGAppRefreshTaskRequest(identifier: autoDecrementTaskID)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60 * 24) // ~24 h
        try? BGTaskScheduler.shared.submit(request)
    }
    
    private func handleAutoDecrement(task: BGAppRefreshTask) {
        scheduleAutoDecrement()   // schedule the next one

        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1

        let op = InventoryAutoDecrementOperation()
        task.expirationHandler = { queue.cancelAllOperations() }

        op.completionBlock = {
            let success = !op.isCancelled
            task.setTaskCompleted(success: success)
        }
        queue.addOperation(op)
    }
    
    // Reschedule when app goes to the background
    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleAutoDecrement()
    }

}

