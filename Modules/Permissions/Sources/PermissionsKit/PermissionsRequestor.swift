// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import AVKit
import DIKit
import ToolKit
import UserNotifications

/// `PermissionsRequestor` is for requesting access to the user's camera
/// as well as requesting access to push notifications. At the moment
/// we are only requesting for camera permissions in KYC.
public class PermissionsRequestor {

    public enum Permission {
        case camera
        case notification
        case microphone
    }

    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let settings: PermissionSettingsAPI

    public init(
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        settings: PermissionSettingsAPI = resolve()
    ) {
        self.analyticsRecorder = analyticsRecorder
        self.settings = settings
    }

    // MARK: Public Functions

    public func requestPermissions(_ permissions: [Permission], callback: @escaping () -> Void) {
        let shouldDisplayCameraRequest = PermissionsRequestor.shouldDisplayCameraPermissionsRequest()
        let shouldDisplayNotificationsRequest = PermissionsRequestor.shouldDisplayNotificationsPermissionsRequest()
        let shouldDisplayMicrophoneRequest = PermissionsRequestor.shouldDisplayMicrophonePermissionsRequest()

        let camera = permissions.contains { $0 == .camera }
        let microphone = permissions.contains { $0 == .microphone }
        let notification = permissions.contains { $0 == .notification }

        // If we've asked the user for camera and/or notification permissions
        // we want to call the completion handler.
        switch (camera, microphone, notification) {
        case (true, true, true):
            let all = shouldDisplayCameraRequest && shouldDisplayNotificationsRequest && shouldDisplayMicrophoneRequest
            guard all == true else { callback(); return }
        case (true, true, false):
            guard shouldDisplayCameraRequest == true else { callback(); return }
            guard shouldDisplayMicrophoneRequest == true else { callback(); return }
        case (false, true, true):
            guard shouldDisplayMicrophoneRequest == true else { callback(); return }
            guard shouldDisplayNotificationsRequest == true else { callback(); return }
        case (true, false, true):
            guard shouldDisplayCameraRequest == true else { callback(); return }
            guard shouldDisplayNotificationsRequest == true else { callback(); return }
        case (false, false, true):
            guard shouldDisplayNotificationsRequest == true else { callback(); return }
        case (true, false, false):
            guard shouldDisplayCameraRequest == true else { callback(); return }
        case (false, true, false):
            guard shouldDisplayMicrophoneRequest == true else { callback(); return }
        default:
            callback()
            return
        }

        if camera {
            queue.addOperation(cameraOperation)
            settings.didRequestCameraPermissions = true
        }

        if microphone {
            queue.addOperation(microphoneOperation)
            settings.didRequestMicrophonePermissions = true
        }

        if notification {
            queue.addOperation(pushOperation)
            settings.didRequestNotificationPermissions = true
        }

        queue.addOperation {
            DispatchQueue.main.async {
                callback()
            }
        }
    }

    // MARK: Private Lazy Properties (Operations)

    private lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    private lazy var cameraOperation: AsyncBlockOperation = {
        let camera = AsyncBlockOperation { [weak self] done in
            DispatchQueue.main.async {
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        self?.analyticsRecorder.record(
                            event: AnalyticsEvents.Permission.permissionSysCameraApprove
                        )
                    } else {
                        self?.analyticsRecorder.record(
                            event: AnalyticsEvents.Permission.permissionSysCameraDecline
                        )
                    }
                    done()
                }
            }
        }
        return camera
    }()

    private lazy var pushOperation: AsyncBlockOperation = {
        let push = AsyncBlockOperation { done in
            DispatchQueue.main.async {
                UNUserNotificationCenter.current().requestAuthorization(
                    options: [.alert, .sound],
                    completionHandler: { _, _ in
                        done()
                    }
                )
            }
        }
        return push
    }()

    private lazy var microphoneOperation: AsyncBlockOperation = {
        let microphone = AsyncBlockOperation { [weak self] done in
            DispatchQueue.main.async {
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    if granted {
                        self?.analyticsRecorder.record(
                            event: AnalyticsEvents.Permission.permissionSysMicApprove
                        )
                    } else {
                        self?.analyticsRecorder.record(
                            event: AnalyticsEvents.Permission.permissionSysMicDecline
                        )
                    }
                    done()
                }
            }
        }
        return microphone
    }()

    // MARK: Private Static Functions

    private static func validatePermissionsAvailability(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let enabled = cameraPermissionsUndetermined() && settings.authorizationStatus == .authorized
            completion(enabled)
        }
    }

    // MARK: Public Static Functions

    static func shouldDisplayCameraPermissionsRequest() -> Bool {
        let settings: PermissionSettingsAPI = resolve()
        return !settings.didRequestCameraPermissions
    }

    static func shouldDisplayNotificationsPermissionsRequest() -> Bool {
        let settings: PermissionSettingsAPI = resolve()
        return !settings.didRequestNotificationPermissions
    }

    static func shouldDisplayMicrophonePermissionsRequest() -> Bool {
        let settings: PermissionSettingsAPI = resolve()
        return !settings.didRequestMicrophonePermissions
    }

    /// This is when the system hasn't asked the user for camera permissions
    static func cameraPermissionsUndetermined() -> Bool {
        AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined
    }

    static func cameraEnabled() -> Bool {
        AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }

    static func cameraRefused() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        return status == .denied || status == .restricted
    }

    static func microphonePermissionsUndetermined() -> Bool {
        AVAudioSession.sharedInstance().microphonePermissionsUndetermined()
    }

    static func microphoneEnabled() -> Bool {
        AVAudioSession.sharedInstance().microphoneEnabled()
    }

    static func microphoneRefused() -> Bool {
        AVAudioSession.sharedInstance().microphoneRefused()
    }
}

extension AVAudioSession {
    func microphoneEnabled() -> Bool {
        recordPermission == .granted
    }

    func microphonePermissionsUndetermined() -> Bool {
        recordPermission == .undetermined
    }

    func microphoneRefused() -> Bool {
        recordPermission == .denied
    }
}
