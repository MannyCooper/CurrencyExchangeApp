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
    
    
    let baseURL = "http://api.exchangeratesapi.io/v1/"
    let apiKey = "729c96fade601362151c7e0cd8463761"
    
    var currenciesArray = ["USD","CNY","EUR","GBP","AUD","JPY","CAD","TWD","HKD","RUB"]
    
    var fromCurrency: String = "USD"
    var toCurrency: String = "CNY"
    
    @IBOutlet weak var fromCurrencyPicker: UIPickerView!
    @IBOutlet weak var toCurrencyPicker: UIPickerView!
    
    @IBOutlet weak var lblResult: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
                                
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getAllCurrencies()
            .done { getAllCurrencies in
                self.currenciesArray = getAllCurrencies
                self.fromCurrencyPicker.reloadAllComponents()
                self.toCurrencyPicker.reloadAllComponents()
                
                if let fromIndex = self.currenciesArray.firstIndex(of: self.fromCurrency) {
                    print(fromIndex)
                    self.fromCurrencyPicker.selectRow(fromIndex, inComponent:0, animated:false)
                }
                if let toIndex = self.currenciesArray.firstIndex(of: self.toCurrency) {
                    self.toCurrencyPicker.selectRow(toIndex, inComponent:0, animated:false)
                }
            }
            .catch { _ in
                self.fromCurrencyPicker.selectRow(3, inComponent:0, animated:true)
                self.toCurrencyPicker.selectRow(4, inComponent:0, animated:true)
            }
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
        
        SwiftSpinner.show("Fetching data...")
        
        return Promise<(Float,Float)>{seal -> Void in
            
            let url = baseURL + "latest?access_key=" + apiKey + "&symbols=" + fromCurrency + "," + toCurrency
            
            AF.request(url).responseJSON { response in
                switch response.result {
                case .success(let success):
                    SwiftSpinner.hide()
                    let rates = JSON(success)["rates"]
                    let fromCurrencyRate = rates[fromCurrency].floatValue
                    let toCurrencyRate = rates[toCurrency].floatValue
                    seal.fulfill((fromCurrencyRate, toCurrencyRate))
                    
                case .failure(let error):
                    SwiftSpinner.show("Failed", animated: false).addTapHandler({
                        SwiftSpinner.hide()
                    }, subtitle: "Tap to hide.")
                    print("error")
                    seal.reject(error)
                }
                
            }
            
        }
    }
    
    func getAllCurrencies() -> Promise<Array<String>>{
        SwiftSpinner.show("Fetching currencies list...")
        
        return Promise<Array<String>>{seal -> Void in
            
            let url = baseURL + "symbols?access_key=" + apiKey
            
            AF.request(url).responseJSON { response in
                switch response.result {
                case .success(let success):
                    SwiftSpinner.hide()
                    let currenciesArray = JSON(success)["symbols"].dictionaryValue.keys.sorted()
                    seal.fulfill(currenciesArray)
                    
                case .failure(let error):
                    print(error)
                    SwiftSpinner.show("Failed to fetch currencies list, using local list.", animated: false).addTapHandler({
                        SwiftSpinner.hide()
                    }, subtitle: "Tap to hide.")
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
        getExchangeRate(fromCurrency, toCurrency)
            .done { fromCurrencyRate, toCurrencyRate in
                self.lblResult.text = "1 \(self.fromCurrency) = \(toCurrencyRate/fromCurrencyRate) \(self.toCurrency)"
                
            }
            .catch { error in
                print(error)
            }
    }
    
    
    
}

