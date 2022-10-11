//
//  ProfileViewController.swift
//  1011LoginDemo
//
//  Created by 黃筱珮 on 2022/10/11.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var labelUserName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //隱藏navigation的返回按鈕
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
        
        //從默認值中獲取使用者資料
        let defaultValues = UserDefaults.standard
        if let name = defaultValues.string(forKey: "username"){
            
            labelUserName.text = name
        }else{
            //send back to login view controller
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // 處理所有可以重新創建的資源。
    }
    
    @IBAction func buttonLogout(_ sender: Any) {
        //刪除默認值
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
        
        //切換到登入頁面
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.navigationController?.pushViewController(loginViewController, animated: true)
        self.dismiss(animated: false, completion: nil)
    }
}
