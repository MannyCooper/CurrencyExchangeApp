//
//  ViewController.swift
//  CurrencyExchangeApp
//
//  Created by 安子璠 on 10/20/21.
//

import UIKit
import SwiftyJSON
import SwiftSpinner
import Alamofire
import PromiseKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
            
    
    let baseURL = "http://api.exchangeratesapi.io/v1/latest"
    let apiKey = "729c96fade601362151c7e0cd8463761"
    
    let currenciesArray = ["USD","CNY","EUR","GBP","AUD","JPY","CAD","TWD","HKD","RUB"]
        
    var fromCurrency: String = ""
    var toCurrency: String = ""
    
    @IBOutlet weak var fromCurrencyPicker: UIPickerView!
    @IBOutlet weak var toCurrencyPicker: UIPickerView!
    
    @IBOutlet weak var lblResult: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        fromCurrency = currenciesArray[3]
        toCurrency = currenciesArray[4]
        fromCurrencyPicker.selectRow(3, inComponent:0, animated:true)
        toCurrencyPicker.selectRow(4, inComponent:0, animated:true)
    }
    
    
    //    Picker
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currenciesArray.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currenciesArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == fromCurrencyPicker{
            self.fromCurrency = self.currenciesArray[row]
        } else if pickerView == toCurrencyPicker{
            self.toCurrency = self.currenciesArray[row]
        }
    }
    
    
    //    Networking
    
    func getExchangeRate(_ fromCurrency: String, _ toCurrency: String) -> Promise<(Float,Float)>{
        return Promise<(Float,Float)>{seal -> Void in
            
            let url = baseURL + "?access_key=" + apiKey + "&symbols=" + fromCurrency + "," + toCurrency
            
            AF.request(url).responseJSON { response in
                switch response.result {
                case .success(let success):
                    let rates = JSON(success)["rates"]
                    let fromCurrencyRate = rates[fromCurrency].floatValue
                    let toCurrencyRate = rates[toCurrency].floatValue
                    seal.fulfill((fromCurrencyRate, toCurrencyRate))
                    
                case .failure(let error):
                    print("error")
                    seal.reject(error)
                }
                
            }
            
        }
    }
    
    // Get Exchange Rate
    @IBAction func getExchangeRate(_ sender: Any) {
        if fromCurrency == "" || toCurrency == ""{
            return
        }
        SwiftSpinner.show("Fetching Data...")
        getExchangeRate(fromCurrency, toCurrency)
            .done { fromCurrencyRate, toCurrencyRate in
                self.lblResult.text = "1 \(self.fromCurrency) = \(toCurrencyRate/fromCurrencyRate) \(self.toCurrency)"
                SwiftSpinner.hide()
            }
            .catch { error in
                SwiftSpinner.show("Failed", animated: false).addTapHandler({
                    SwiftSpinner.hide()
                  }, subtitle: "Tap to hide.")
                print(error)
            }
    }
    
    
    
}

