 
import UIKit
import Backendless

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private let APPLICATION_ID = "FA232ED0-5CF6-F70C-FF59-4179EE2DA300"
    private let API_KEY = "371BD173-3CB9-B6AB-FFC4-7885E1FD6C00"
    private let SERVER_URL = "https://api.backendless.com"

    var window: UIWindow?
    
    func initBackendless() {
        Backendless.shared.hostUrl = SERVER_URL
        Backendless.shared.initApp(applicationId: APPLICATION_ID, apiKey: API_KEY)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        initBackendless()
        return true
    }
}
                