import UIKit
import CloudKit

class LoginController: UIViewController {

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        checkICloudLogin()
    }

    func checkICloudLogin() {
        let container = CKContainer.defaultContainer()
        container.accountStatusWithCompletionHandler { status, error in
            switch status {
                case .Available:
                    dispatch_async(dispatch_get_main_queue()) {
                        self.performSegueWithIdentifier("loginSuccess", sender: self)
                    }
                default:
                    let alert = UIAlertController(
                        title: "iCloud Login Failed",
                        message: "iCloud account not available. Please check and try again.",
                        preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Retry", style: .Default) {
                        _ in self.checkICloudLogin()
                    })
                    dispatch_async(dispatch_get_main_queue()) {
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
            }
        }
    }
}
