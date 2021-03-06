//
//  RegisterPageViewController.swift
//  Lock_v1
//
//  Created by Nikhil vedi on 22/01/2017.
//  Copyright © 2017 Nikhil Vedi. All rights reserved.
//

import UIKit
import SwiftyJSON

class RegisterPageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //hide keyboard when anywhere tapped
         self.hideKeyboardWhenTappedAround()
        name.borderStyle = UITextBorderStyle.none;
        email.borderStyle = UITextBorderStyle.none;
        password.borderStyle = UITextBorderStyle.none;
        password2.borderStyle = UITextBorderStyle.none;
        LockID.borderStyle = UITextBorderStyle.none;
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var password2: UITextField!
    @IBOutlet weak var LockID: UITextField!
    
    
    @IBAction func registerButton(_ sender: Any) {
        
        let userName = name.text
        let userEmail = email.text
        let userPassword = password.text
        let userPasswordConfirm = password2.text
        
        //validation before sending to server 
        
        if((userEmail?.isEmpty)! || (userPassword?.isEmpty)! || (userPasswordConfirm?.isEmpty)! || (userName?.isEmpty)!)
        {
            
            // Display alert message
            
            displayMyAlertMessage("All fields are required");
            
            return;
        }
        
        //Check if passwords match
        if(userPassword != userPasswordConfirm)
        {
            // Display an alert message
            displayMyAlertMessage("Passwords do not match");
            return;
            
        }
        //validate email - test this fully
       if (isValidEmail(testStr: userEmail!) == true)
       {
        //if password is valid string here too, then register
     //   if (isValidPassword(testStr: userPassword!) == true)
       // {
            register()
        //}
       // else {
        //     displayMyAlertMessage("Password must contain an Uppercase, Lowercase and Special character")
        //}
         
        }
        else
       {
        displayMyAlertMessage("Please enter a valid email address")
        }

    }
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    //one of xzy and two numbers - think
    //for lockID - ^(?=.*[0-9].*[0-9])(?=.*[xzy])$
    
    
    // Start anchor - password regex
    //Ensure string has an uppercase letter.
    //Ensure string has one special case letter.

    //Ensure string has a lowercase letter.
    //End anchor.
    
    func isValidPassword(testStr:String) -> Bool {
        print("validate calendar: \(testStr)")
        let passwordRegEx = "^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[a-z])$"
        
        let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
       return passwordTest.evaluate(with: testStr)
    }

    
    func register()
    {
        //store everything in user defaults
        
        UserDefaults.standard.set(name.text!, forKey: "name")
        UserDefaults.standard.set(email.text!, forKey: "email")
        UserDefaults.standard.set(password.text!, forKey: "password")
        UserDefaults.standard.synchronize()
        
        if (LockID.text?.isEmpty)!
        {
            print("no lockID")
            
              UserDefaults.standard.set(false, forKey: "LockIDPresent")
              UserDefaults.standard.synchronize()
         //   sets and sends lockID as an empty string so the field is initialised
            LockID.text = nil;
        }
            //not working - fix this
  //      else if (LockID.text?.hasPrefix("x") != true){
            //make sure LockID starts with x
         //   displayMyAlertMessage("Please check LockID and try again")
   //         }
        else
        {
            print(LockID.text as Any)
             UserDefaults.standard.set(LockID.text!, forKey: "LockID")
                UserDefaults.standard.set(true, forKey: "LockIDPresent")
               UserDefaults.standard.synchronize()
        }
        
        if (UserDefaults.standard.value(forKey: "userIP") == nil)
        {
            //make this a print out and stop the program crashing by assigning user defaults a value for IP
            UserDefaults.standard.set("localhost", forKey: "userIP")
            
            print("Local host programatically set");
        }
        
        let u = UserDefaults.standard.value(forKey: "userIP")!
        var request = URLRequest(url: URL(string: "http://\(u):3000/users")!)
        request.httpMethod = "POST"
        let postString = "name=\(email.text!)&password=\(password.text!)&LockID=\(LockID.text!)&firstname=\(name.text!)"
        print(postString)
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                                                          // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {                // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
             print("responseString = \(responseString)")
            
            if let data = responseString?.data(using: String.Encoding.utf8) {
                let resString = JSON(data: data)
                
                if resString["success"].stringValue == "true"
                {
                    DispatchQueue.main.async() {
                    self.displayMyAlertMessage(resString["message"].stringValue)
                    //close the  registration page and prompt for login if successful response from server
                         self.dismiss(animated: true, completion: nil)
                    }
                    
                }
                else if resString["success"].stringValue == "false"
                {
                    //error handling for already signed up users

                    print(resString["message"].stringValue);
                    DispatchQueue.main.async() {
                        self.displayMyAlertMessage(resString["message"].stringValue)
                    }
                }
            }
            
        }
        task.resume()
        //set fields to empty
        email.text = "";
        password.text="";
        password2.text="";
        LockID.text="";
        name.text="";
    }
    
    
    func displayMyAlertMessage(_ userMessage:String)
    {
        
        let myAlert = UIAlertController(title:"Alert", message:userMessage, preferredStyle: UIAlertControllerStyle.alert);
        
        let okAction = UIAlertAction(title:"Ok", style:UIAlertActionStyle.default, handler:nil);
        
        myAlert.addAction(okAction);
        
        self.present(myAlert, animated:true, completion:nil);
        
    }
    
    @IBAction func HaveAccount(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
