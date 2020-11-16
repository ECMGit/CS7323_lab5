//
//  PaintingViewController.swift
//  CS7323Lab5
//
//  Created by 沈俊豪 on 11/11/20.
//  Copyright © 2020 Eric Larson. All rights reserved.
//
let SERVER_URL = "http://192.168.1.129:8000"


import UIKit
import Alamofire

class PaintingPaintingViewController: UIViewController{
    // MARK: Outlets
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!
    @IBOutlet weak var bottomStackView: UIStackView!
    @IBOutlet weak var predictButtonKNN: UIButton!
    @IBOutlet weak var predictButtonSVM: UIButton!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var KNNparamsTextBox: UITextField!
    @IBOutlet weak var valueSwitcher: UISegmentedControl!
    @IBOutlet weak var dsidTextBox: UITextField!
    
    
//    struct HTTPBinResponse: Decodable { let url: String }
    
    var lastPoint = CGPoint.zero
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var brushWidth: CGFloat = 20.0
    var opacity: CGFloat = 1.0
    var swiped = false
    var expanse = false
    var userid = "01"
    let targetSize = CGSize(width: 28, height: 28)
    var KNNNeighbors:Int = 5
    var label = 0
    var dsid = 0
    
    let colors: [(CGFloat, CGFloat, CGFloat)] = [
        (0, 0, 0),
        (105.0 / 255.0, 105.0 / 255.0, 105.0 / 255.0),
        (1.0, 0, 0),
        (0, 0, 1.0),
        (51.0 / 255.0, 204.0 / 255.0, 1.0),
        (102.0 / 255.0, 204.0 / 255.0, 0),
        (102.0 / 255.0, 1.0, 0),
        (160.0 / 255.0, 82.0 / 255.0, 45.0 / 255.0),
        (1.0, 102.0 / 255.0, 0),
        (1.0, 1.0, 0),
        (1.0, 1.0, 1.0),
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.KNNparamsTextBox.keyboardType = .numberPad
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
//        let tap = UITapGestureRecognizer(target: self, action: #selector(self.expandAll))
//        tap.delegate = self as? UIGestureRecognizerDelegate
//        tap.numberOfTapsRequired = 2
//        self.view.addGestureRecognizer(tap)
        
//        tutorialView.frame = CGRect(x:0, y:0, width:self.view.frame.width, height:self.view.frame.height)
//        self.view.addSubview(tutorialView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.expanse == false {
//            sbConstraint.constant = 0.0
//            botConstraint.constant = 0.0
            
            UIView.animate(withDuration: 0.6,
                           delay: 0.0,
                           options: UIView.AnimationOptions.curveEaseIn,
                           animations: { () -> Void in
                            self.view.layoutIfNeeded()
            }, completion: { (finished) -> Void in
                self.expanse = true
            })
        }
    }
    
    @objc
    func dismissKeyboard(){
        self.dsid = Int(self.dsidTextBox.text!) ?? 0
        view.endEditing(true)
    }
    
    
    // MARK: - Actions
    
//    @objc func expandAll() {
//
//        UIView.animate(withDuration: 0.6,
//                       delay: 0.0,
//                       options: UIView.AnimationOptions.curveEaseIn,
//                       animations: { () -> Void in
//
//                        if self.expanse == true {
//                            self.sbConstraint.constant = -50.0
//                            self.botConstraint.constant = -100.0
//                            self.wrapButton.alpha = 0.0
//                        } else {
//                            self.sbConstraint.constant = 0.0
//                            self.botConstraint.constant = 0.0
//                            self.wrapButton.alpha = 1.0
//                        }
//
//                        self.view.layoutIfNeeded()
//        }, completion: { (finished) -> Void in
//            self.expanse = !self.expanse
//        })
//    }
    
    @IBAction func logout(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "status")
        Switcher.updateRootVC()
    }
    
    @IBAction func buttonPressed(_ sender: AnyObject) {
        var index = sender.tag ?? 0
        if index < 0 || index >= colors.count {
            index = 0
        }
        
        (red, green, blue) = colors[index]
        
        if index == 1 {
            opacity = 1.0
        }
    }
    
    
    @IBAction func erase(_ sender: Any) {
        self.resultLabel.text = ""
        self.mainImageView.image = nil
    }
    

    @IBAction func switchLabelValue(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.label = 0
        case 1:
            self.label = 1
        case 2:
            self.label = 2
        case 3:
            self.label = 3
        case 4:
            self.label = 4
        case 5:
            self.label = 5
        case 6:
            self.label = 6
        case 7:
            self.label = 7
        case 8:
            self.label = 8
        case 9:
            self.label = 9
        default:
            break
        }
        print("change label to:", self.label)
    }
    
    @IBAction func calibrate(_ sender: Any) {
        
        let params : [String: String] = [
            "dsid": String(dsid),
            "label": String(self.label)
        ]
        AF.request("\(SERVER_URL)/AddDataPoint",
                   method: .post,
                   parameters: params,
                   encoder: JSONParameterEncoder.default).responseJSON { response in
            debugPrint(response)
        }
    }
    
    @IBAction func updateKNN(_ sender: Any) {
        self.KNNNeighbors = Int(self.KNNparamsTextBox.text!) ?? 5
        let params : [String: String] = [
            "modeltype": "KNN",
            "dsid": String(dsid),
            "neighbors": String(self.KNNNeighbors)
        ]
        AF.request("\(SERVER_URL)/UpdateModel",
                   method: .post,
                   parameters: params,
                   encoder: JSONParameterEncoder.default).responseJSON { response in
            debugPrint(response)
        }
    }
    
    
    @IBAction func updateSVM(_ sender: Any) {
        let params : [String: String] = [
            "modeltype": "SVM",
            "dsid": String(dsid)
        ]
        AF.request("\(SERVER_URL)/UpdateModel",
                   method: .post,
                   parameters: params,
                   encoder: JSONParameterEncoder.default).responseJSON { response in
            debugPrint(response)
        }
    }
    
    
    
    @IBAction func predictNumber(_ sender: Any) {
        let params : [String: String] = [
            "dsid": String(self.dsid)
        ]
        AF.request("\(SERVER_URL)/PredictOne",
                   method: .post,
                   parameters: params,
                   encoder: JSONParameterEncoder.default).responseJSON { response in
                               print("============ get response ============")
                               debugPrint(response)
                               switch response.result {
                               case .success:
                                   let json = response.value as! NSDictionary
                   //                print(JSON["prediction"])
                                   let result_num = json["prediction"] as? String
                                   self.resultLabel.text = result_num ?? ""
                               case let .failure(error):
                                   print(error)
                               }
                           }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = false
        if let touch = touches.first {
            lastPoint = touch.location(in: self.view)
        }
//        DispatchQueue.once(token: "Remove Tutorial") {
//            tutorialView.removeFromSuperview()
//        }
    }
    
    func drawLineFrom(_ fromPoint: CGPoint, toPoint: CGPoint) {
        
        // 1
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        
        // 2
        context?.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
        context?.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
        
        // 3
        context?.setLineCap(.round)
        context?.setLineWidth(brushWidth)
        context?.setStrokeColor(red: red, green: green, blue: blue, alpha: 1.0)
        context?.setBlendMode(.normal)
        
        // 4
        context?.strokePath()
        
        // 5
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity
        UIGraphicsEndImageContext()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 6
        swiped = true
        if let touch = touches.first {
            let currentPoint = touch.location(in: view)
            drawLineFrom(lastPoint, toPoint: currentPoint)
            // 7
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if !swiped {
            // draw a single point
            drawLineFrom(lastPoint, toPoint: lastPoint)
        }
        
        // Merge tempImageView into mainImageView
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        
        mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: CGBlendMode.normal, alpha: 1.0)
        
        tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: CGBlendMode.normal, alpha: opacity)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        tempImageView.image = nil
    }
    
    @IBAction func sendDigitImage(_ sender: Any) {
        UIGraphicsBeginImageContext(mainImageView.bounds.size)
        mainImageView.image?.draw(in: CGRect(x: 0, y: 0,
                                             width: mainImageView.frame.size.width, height: mainImageView.frame.size.height))

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let sendImage = convertImage(image: image!)
        let baseURL = "\(SERVER_URL)/UploadImage"
        let imageData = sendImage.jpegData(compressionQuality: 0.2)!
        let params : Parameters = ["userid": userid] //Optional for extra parameter
        AF.upload(multipartFormData:
            {
                (multipartFormData) in
                multipartFormData.append(imageData,
                                         withName: "image",
                                         fileName: "file.jpeg",
                                         mimeType: "image/jpeg")
                for (key, value) in params
                {
                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
        }, to:baseURL,headers:nil).responseJSON { response in
            print("============ get response ============")
            debugPrint(response)
        }
        
    }
    
    // MARK: convert Image
    // convert image into 28 x 28 image
    // then convert image into 2d array and convert 2d to 1d -- on server-side
    func convertImage(image: UIImage)->UIImage{
        UIGraphicsBeginImageContext(CGSize(width: targetSize.width, height: targetSize.height))
        image.draw(in: CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    
    
}

public extension DispatchQueue {
    
    private static var _onceTracker = [String]()
    class func once(token: String, block:()->Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        
        if _onceTracker.contains(token) {
            return
        }
        _onceTracker.append(token)
        block()
    }
}
