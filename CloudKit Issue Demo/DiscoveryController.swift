import UIKit
import CloudKit

class DiscoveryController: UITableViewController {

    var userRecords: [CKDiscoveredUserInfo] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setHidesBackButton(true, animated: false)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        discoverUsers()
    }

    func discoverUsers() {
        let container = CKContainer.defaultContainer()
        container.requestApplicationPermission(.PermissionUserDiscoverability) {
            status, error in
            switch status {
                case .Granted:
                    let progressController = UIAlertController(
                        title: "Discovering users…", message: nil, preferredStyle: .Alert)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.presentViewController(progressController, animated: true, completion: nil)
                    }
                    container.discoverAllContactUserInfosWithCompletionHandler {
                        discoveredUsers, error in
                        if error == nil {
                            self.userRecords = discoveredUsers as! [CKDiscoveredUserInfo]
                            dispatch_async(dispatch_get_main_queue()) {
                                self.dismissViewControllerAnimated(true, completion: nil)
                                self.tableView.reloadData()
                            }
                        } else {
                            let alert = UIAlertController(
                                title: "Discovery Failed",
                                message: error.localizedDescription,
                                preferredStyle: .Alert)
                            alert.addAction(UIAlertAction(title: "Retry", style: .Default) {
                                _ in self.discoverUsers()
                            })
                            dispatch_async(dispatch_get_main_queue()) {
                                self.dismissViewControllerAnimated(false, completion: nil)
                                self.presentViewController(alert, animated: true, completion: nil)
                            }
                        }
                    }
                default:
                    let alert = UIAlertController(
                        title: "CloudKit Permissions Rejected",
                        message: "The app does not have the permissions to discover users.",
                        preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Retry", style: .Default) {
                        _ in self.discoverUsers()
                    })
                    dispatch_async(dispatch_get_main_queue()) {
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
            }
        }
    }
}

extension DiscoveryController: UITableViewDataSource {

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userRecords.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let userCellID = "userInfoCell"
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: userCellID)
        let cell = tableView.dequeueReusableCellWithIdentifier(userCellID) as? UITableViewCell
        let userInfo = userRecords[indexPath.row]
        cell?.textLabel?.text = "\(userInfo.firstName) \(userInfo.lastName)"
        return cell!
    }
}