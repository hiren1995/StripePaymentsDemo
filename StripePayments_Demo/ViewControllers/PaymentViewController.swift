//
//  PaymentViewController.swift
//  StripePayments_Demo
//
//  Created by LogicalWings Mac on 01/11/18.
//  Copyright © 2018 LogicalWings Mac. All rights reserved.
//

import UIKit

class PaymentViewController: BaseViewController {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtCardNumber: UITextField!
    @IBOutlet weak var txtCVC: UITextField!
    @IBOutlet weak var txtRupeesAmt: UITextField!
    @IBOutlet weak var txtMonth: UITextField!
    @IBOutlet weak var txtYear: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Stripe Payment Demo".localized()
        
        addDoneButtonOnNumpad(textField: txtCardNumber)
        addDoneButtonOnNumpad(textField: txtRupeesAmt)
        addDoneButtonOnNumpad(textField: txtCVC)
        addDoneButtonOnNumpad(textField: txtYear)
        addDoneButtonOnNumpad(textField: txtMonth)
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnSend(_ sender: UIButton) {
        
        if ((txtEmail.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!){
            self.serverResponseMessages("Enter Valid Email")
        }
        else if((txtCardNumber.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!){
            self.serverResponseMessages("Enter Valid Card Number")
        }
        else if((txtMonth.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!){
            self.serverResponseMessages("Enter Valid Month")
        }
        else if((txtYear.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!){
            self.serverResponseMessages("Enter Valid Year")
        }
        else if ((txtCVC.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!){
            self.serverResponseMessages("Enter Valid CVC")
        }
        else if ((txtRupeesAmt.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!){
            self.serverResponseMessages("Enter Valid Amount")
        }
        else if !((txtEmail.text?.isValidEmail())!){
            self.serverResponseMessages("Enter Valid Email")
        }
        else if ((txtRupeesAmt.text! as NSString).floatValue) < 50.0{
            self.serverResponseMessages("Enter amount not less than 50")
        }
        else {
            
            
            var stripCardParam = STPCardParams()
            
            stripCardParam.number = txtCardNumber.text!
            stripCardParam.cvc = txtCVC.text!
            stripCardParam.expMonth = UInt((txtMonth.text! as NSString).floatValue)
            stripCardParam.expYear = UInt(txtYear.text!)!
            
            STPAPIClient.shared().createToken(withCard: stripCardParam) { (token, error) in
                
                if error != nil{
                    print(error)
                    return
                }
                
                self.postStripeToken(token: token!)
            }
            
        }
    }
    
    func postStripeToken(token: STPToken) {
        
        print(token)
        
        print((txtRupeesAmt.text! as NSString).floatValue * 100)
        //converting rupees to cents
        
        HttpManager.defaultManager.executeHttpRequest(apiRequest: .debitAPI(stripeToken: token.tokenId, amount: ((txtRupeesAmt.text! as NSString).floatValue * 100), currency: "inr", description: txtEmail.text!), apiCallbacks: self)
    }
    
    override func onHttpResponse(request: ApiRequest, data: Any) {
        
        let decoder = JSONDecoder()
        
        switch request {
        case .debitAPI:
            
            do{
                let response = try decoder.decode(DebitResponseModelBase.self, from: data as! Data)
                print(response)
                
                if response.status == "Success"{
                    
                    let alertVC = UIAlertController(title: "Payment Status", message: response.message, preferredStyle: .alert)
                    
                    alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    
                    self.present(alertVC, animated: true, completion: nil)
                }
                
            }catch(let error){
                print(error)
            }
            
            break
        default:
            return
        }
    }
}

extension PaymentViewController:UITextFieldDelegate{
  
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var txtString = String()
        
        if textField == txtMonth{
            
            txtString = (txtMonth.text! as NSString).replacingCharacters(in: range, with: string)
            
            let length = txtString.count
            if length > 2 {
                return false
            }
        }
        else if textField == txtYear{
            
            txtString = (txtYear.text! as NSString).replacingCharacters(in: range, with: string)
            
            let length = txtString.count
            if length > 2 {
                return false
            }
        }
        else if textField == txtCVC{
            
            txtString = (txtYear.text! as NSString).replacingCharacters(in: range, with: string)
            
            let length = txtString.count
            if length > 4 {
                return false
            }
        }
        
        return true
    }
}
