//
//  ViewController.swift
//  1011LoginDemo
//
//  Created by 黃筱珮 on 2022/10/11.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    // 這裡的網址要跟剛剛在postman的測試網址一樣，但是localhost必需是數字
    let URL_USER_LOGIN = "http://127.0.0.1:8080/LoginDemo/v1%20/login.php"
    
    // 儲存用戶資料
    let defaultValues = UserDefaults.standard
    
    // 元件繫結
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var textFieldUserName: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 隱藏navigationController
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
        
        
        
        //如果用戶已經登入就切換到灰色畫面
        if defaultValues.string(forKey: "username") != nil{
            let profileViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewcontroller") as! ProfileViewController
            self.navigationController?.pushViewController(profileViewController, animated: true)
            
        }
    }
    
    
    // 元件繫結
    @IBAction func buttonLogin(_ sender: Any) {
        
        // 取得 username and password
        let parameters: Parameters=[
            "username":textFieldUserName.text!,
            "password":textFieldPassword.text!
        ]
        
        // 發出post請求
        Alamofire.request(URL_USER_LOGIN, method: .post, parameters: parameters ).responseJSON{
            response in
            
            print(response)
            
            // 從web server 獲取json值
            if let result = response.result.value {
                let jsonData = result as! NSDictionary
                
                // 如果沒有錯誤
                if(!(jsonData.value(forKey: "error") as! Bool)){
                    
                    // 取得用戶
                    let user = jsonData.value(forKey: "user") as! NSDictionary
                    
                    // 取得用戶資料
                    let userId = user.value(forKey: "id") as! Int
                    let userName = user.value(forKey: "username") as! String
                    let userEmail = user.value(forKey: "email") as! String
                    let userPhone = user.value(forKey: "phone") as! String
                    
                    // 儲存用戶資料
                    self.defaultValues.set(userId, forKey: "userid")
                    self.defaultValues.set(userName, forKey: "username")
                    self.defaultValues.set(userEmail, forKey: "useremail")
                    self.defaultValues.set(userPhone, forKey: "userphone")
                    
                    // 跳頁
                    let profileViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewcontroller") as! ProfileViewController
                    self.navigationController?.pushViewController(profileViewController, animated: true)
                    
                    self.dismiss(animated: false, completion: nil)
                }else{
                    // 取得無效的錯誤訊息
                    self.labelMessage.text = "Invalid username or password"
                }
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // 處理所有可以重新創建的資源。
    }
    
}

