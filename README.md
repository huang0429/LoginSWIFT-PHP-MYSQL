


這篇的實作會以[這個範例](https://github.com/huang0429/Register-SWIFT-PHP)PHP檔案做延續

## 系統

macOS Monterey 12.6  
XAMPP 8.1.6  
XCode 14  

## PHP程式碼-用戶驗證

首先要利用資料庫做用戶驗證並登入  

以下程式碼寫到 include 的DbOperation.php檔案中的 Constructor 方法之後：  

```php=

//登入2
    // 這個方法會幫我們取得用戶和密碼並在資料庫驗證它
    public function userLogin($username, $pass)
    {
        $password = md5($pass);
        $stmt = $this->conn->prepare("SELECT id FROM users WHERE username = ? AND password = ?");
        $stmt->bind_param("ss", $username, $password);
        $stmt->execute();
        $stmt->store_result();
        return $stmt->num_rows > 0;
    }

    //取得用戶名2
    // 如果登入成功，會以array型式回傳用戶資料
    public function getUserByUsername($username)
    {
        $stmt = $this->conn->prepare("SELECT id, username, email, phone FROM users WHERE username = ?");
        $stmt->bind_param("s", $username);
        $stmt->execute();
        $stmt->bind_result($id, $uname, $email, $phone);
        $stmt->fetch();
        $user = array();
        $user['id'] = $id;
        $user['username'] = $uname;
        $user['email'] = $email;
        $user['phone'] = $phone;
        return $user;
    }

```

接著到 v1 資料夾底下新增一個檔案： login.php

![](https://i.imgur.com/iUFKnfU.jpg)

```php=

require_once '../includes/DbOperation.php';

$response = array();

if ($_SERVER['REQUEST_METHOD'] == 'POST') {

    if (isset($_POST['username']) && isset($_POST['password'])) {

        $db = new DbOperation();

        if ($db->userLogin($_POST['username'], $_POST['password'])) {
            $response['error'] = false;
            $response['user'] = $db->getUserByUsername($_POST['username']);
        } else {
            $response['error'] = true;
            $response['message'] = 'Invalid username or password';
        }

    } else {
        $response['error'] = true;
        $response['message'] = 'Parameters are missing';
    }

} else {
    $response['error'] = true;
    $response['message'] = "Request not allowed";
}

echo json_encode($response);

```

## API測試 - POSTMAN

![](https://i.imgur.com/I7SUyOL.jpg)


## XCode 登入畫面

新增一個XCode專案，並將 alamofire 加入

### 製作畫面

拉元件

![](https://i.imgur.com/0Mii0FW.jpg)


然後將元件跟程式碼繫結起來  
名稱：

```swift=
import UIKit
import Alamofire

class ViewController: UIViewController {
    
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var textFieldUserName: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func buttonLogin(_ sender: Any) {
    }
    
}


```


### Storyboard ID

並給個ID  
這邊取為：ViewController  

![](https://i.imgur.com/jDoPniV.jpg)


### Navigation Controller

把這個頁面設成 Navigation Controller

![](https://i.imgur.com/gzkImJa.jpg)

結果：  

![](https://i.imgur.com/EjeHKY5.jpg)



### 跳轉頁面

再來拉一個 View Controller  

並加上三個元件  


![](https://i.imgur.com/m2v4M7w.jpg)

### 登入程式碼 View Controller.swift的程式碼

> URL_USER_LOGIN要跟剛剛postman輸入的一樣，但是localhost必需是數字，如我的就是127.0.0.1，如果不知道可以用ifconfig查詢。

```swift=
//
//  ViewController.swift
//  1011LoginDemo
//
//  Created by 黃筱珮 on 2022/10/11.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    // 這裡的網址要跟剛剛在postman的測試網址一樣
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


```

### 創一個類別

不要忘了，灰色頁面還沒有類別  

這個類別取名：ProfileViewController.swift  

並在裡面加入一段程式碼：  

```swift=
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // 處理所有可以重新創建的資源。
    }
```

### ProfileViewController的程式碼

```swift=
//
//  ProfileViewController.swift
//  1008LoginDemo
//
//  Created by 黃筱珮 on 2022/10/9.
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // 處理所有可以重新創建的資源。
    }
    
}

```

並把它們做繫結  

![](https://i.imgur.com/pcPPCxh.jpg)

## Storyboard ID設定

```swift=
ProfileViewcontroller
```

![](https://i.imgur.com/A9xrxGl.jpg)

### 跳頁程式 ProfileViewController.swift

```swift=
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


```

## 測試

如果剛剛在postman可以，到這邊應該是沒問題。  

https://youtube.com/shorts/n7ryquRRPWo

{% youtube n7ryquRRPWo %}