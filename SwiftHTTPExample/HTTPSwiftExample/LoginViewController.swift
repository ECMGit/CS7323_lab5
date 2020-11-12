//
//  LoginViewController.swift
//  HTTPSwiftExample
//
//  Created by Reid Russell on 11/12/20.
//  Copyright © 2020 Eric Larson. All rights reserved.
//

import UIKit




class LoginViewController: UIViewController, URLSessionDelegate {
    
    // MARK: Class Properties
    lazy var session: URLSession = {
        let sessionConfig = URLSessionConfiguration.ephemeral
        
        sessionConfig.timeoutIntervalForRequest = 5.0
        sessionConfig.timeoutIntervalForResource = 8.0
        sessionConfig.httpMaximumConnectionsPerHost = 1
        
        return URLSession(configuration: sessionConfig,
            delegate: self,
            delegateQueue:self.operationQueue)
    }()
    let operationQueue = OperationQueue()
    let SERVER_URL = "http://192.168.1.129:8000" // change this for your server name!!!

    @IBOutlet weak var ErrorLabel: UILabel!
    @IBOutlet weak var UsernameBox: UITextField!
    @IBOutlet weak var PasswordBox: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func login(){
        // create a GET request for server to update the ML model with current data
        let baseURL = "\(SERVER_URL)/Login"
        let getUrl = URL(string: "\(baseURL)")
        
        // create a custom HTTP GET request
        var request = URLRequest(url: getUrl!)
        
        // data to send in body of post request (send arguments as json)
        let jsonUpload:NSDictionary = ["username":self.UsernameBox.text, "password":self.PasswordBox.text]
        
        
        let requestBody:Data? = self.convertDictionaryToData(with:jsonUpload)
        
        request.httpMethod = "GET"
        request.httpBody = requestBody
        
        let postTask : URLSessionDataTask = self.session.dataTask(with: request,
                                                                  completionHandler:{
                        (data, response, error) in
                        if(error != nil){
                            if let res = response{
                                print("Response:\n",res) // TODO: Change to set error label as the response
                            }
                        }
                        else{ // no error we are aware of
                            let jsonDictionary = self.convertDataToDictionary(with: data)
                            
                            let labelResponse = jsonDictionary["prediction"]!
                            print(labelResponse)

                        }
                                                                    
        })
        
        postTask.resume() // start the task
    }
    
    func register(){
        // create a GET request for server to update the ML model with current data
        let baseURL = "\(SERVER_URL)/Register"
        let postUrl = URL(string: "\(baseURL)")
        
        // create a custom HTTP GET request
        var request = URLRequest(url: postUrl!)
        
        // data to send in body of post request (send arguments as json)
        let jsonUpload:NSDictionary = ["username":self.UsernameBox.text, "password":self.PasswordBox.text]
        
        
        let requestBody:Data? = self.convertDictionaryToData(with:jsonUpload)
        
        request.httpMethod = "POST"
        request.httpBody = requestBody
        
        let postTask : URLSessionDataTask = self.session.dataTask(with: request,
                                                                  completionHandler:{
                        (data, response, error) in
                        if(error != nil){
                            if let res = response{
                                print("Response:\n",res) // TODO: Change to set error label as the response
                            }
                        }
                        else{ // no error we are aware of
                            let jsonDictionary = self.convertDataToDictionary(with: data)
                            
                            let labelResponse = jsonDictionary["prediction"]!
                            print(labelResponse)

                        }
                                                                    
        })
        
        postTask.resume() // start the task
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
        login()
    }
    

    @IBAction func RegisterButton(_ sender: UIButton) {
        register()
    }
    
    
    //MARK: JSON Conversion Functions
    func convertDictionaryToData(with jsonUpload:NSDictionary) -> Data?{
        do { // try to make JSON and deal with errors using do/catch block
            let requestBody = try JSONSerialization.data(withJSONObject: jsonUpload, options:JSONSerialization.WritingOptions.prettyPrinted)
            return requestBody
        } catch {
            print("json error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func convertDataToDictionary(with data:Data?)->NSDictionary{
        do { // try to parse JSON and deal with errors using do/catch block
            let jsonDictionary: NSDictionary =
                try JSONSerialization.jsonObject(with: data!,
                                              options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            
            return jsonDictionary
            
        } catch {
            
            if let strData = String(data:data!, encoding:String.Encoding(rawValue: String.Encoding.utf8.rawValue)){
                            print("printing JSON received as string: "+strData)
            }else{
                print("json error: \(error.localizedDescription)")
            }
            return NSDictionary() // just return empty
        }
    }

}

