//
//  drinkOrderViewController.swift
//  drinkOrder
//
//  Created by 方芸萱 on 2020/9/23.
//

import UIKit

class drinkOrderViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var drinkPickerTextField: UITextField!
    @IBOutlet weak var sugarSegment: UISegmentedControl!
    @IBOutlet weak var iceSegment: UISegmentedControl!
    @IBOutlet weak var volumeSegment: UISegmentedControl!
    @IBOutlet weak var bubbleSwitch: UISwitch!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var submitLabel: UIButton!
    
    var orderList = [DrinkOrder]()
    var drinkMenus = [DrinkMenu]()
    var pickerField:UITextField!
    var pickerSelection = 0
    var pickerSelectionUnconfirm = 0
    var isModifyState = false
    var modifyRow = 0
    var modifyDrinkOrder = DrinkOrder(name: "", drink: "", sugar: "", ice: "", volume: "", bubble: "", price: 0, orderid: 0)

    let sugarGroup = ["無糖", "微糖", "半糖", "正常糖"]
    let iceGroup = ["熱飲", "去冰", "少冰", "正常冰"]
    let volumeGroup = ["中杯", "大杯"]
    let bubbleGroup = ["", "加白玉"]

    override func viewDidLoad() {
        super.viewDidLoad()
        initial()
        getMenu()
    }
    override func viewWillAppear(_ animated: Bool) {
        getOrderList()//for getOrderid use, need execute at viewWillAppear and postOrderList
        if isModifyState == true{
            initialModify()
        }
    }
    func initial(){
        drinkPickerTextField.delegate = self
        nameTextField.delegate = self
        title = "可不可"
    }
    func initialModify(){
        print("modify: \(modifyRow)")
        print(modifyDrinkOrder)
        nameTextField.text = modifyDrinkOrder.name
        for i in 0...drinkMenus.count-1{
            if modifyDrinkOrder.drink == drinkMenus[i].name{
                pickerSelection = i
                drinkPickerTextField.text = drinkMenus[i].name
            }
        }
        for i in 0...sugarGroup.count-1{
            if modifyDrinkOrder.sugar == sugarGroup[i]{
                sugarSegment.selectedSegmentIndex = i
            }
        }
        for i in 0...iceGroup.count-1{
            if modifyDrinkOrder.ice == iceGroup[i]{
                iceSegment.selectedSegmentIndex = i
            }
        }
        for i in 0...volumeGroup.count-1{
            if modifyDrinkOrder.volume == volumeGroup[i]{
                volumeSegment.selectedSegmentIndex = i
            }
        }
        for i in 0...bubbleGroup.count-1{
            if modifyDrinkOrder.bubble == bubbleGroup[i]{
                bubbleSwitch.isOn = (i != 0)
            }
        }
        checkOnlyHotVolume()
        checkPrice()
        submitLabel.setTitle("修改訂單", for: .normal)
    }
    func getMenu(){
        let url = Bundle.main.url(forResource: "drinkMenu", withExtension: "plist")!
        if let data = try? Data(contentsOf: url), let drinkMenus = try? PropertyListDecoder().decode([DrinkMenu].self, from: data){
            self.drinkMenus = drinkMenus
        }
        drinkPickerTextField.text = drinkMenus[pickerSelection].name
        checkPrice()
    }
    func initDrinkPicker(){
        print(#function)
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectRow(pickerSelection, inComponent: 0, animated: false)
        
        let toolbar = UIToolbar()
        toolbar.barStyle = UIBarStyle.default
        toolbar.tintColor = .systemBlue
        toolbar.sizeToFit()
        let confirmButton = UIBarButtonItem(title: "確認", style: .plain, target: self, action: #selector(confirmPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancelPicker))
        toolbar.setItems([cancelButton, spaceButton, confirmButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        pickerField = UITextField(frame: CGRect.zero)
        view.addSubview(pickerField)
        pickerField.inputView = pickerView
        pickerField.inputAccessoryView = toolbar
        pickerField.becomeFirstResponder()
    }
    @objc func confirmPicker(){
        pickerSelection = pickerSelectionUnconfirm
        drinkPickerTextField.text = drinkMenus[pickerSelection].name
        pickerField.resignFirstResponder()
        checkOnlyHotVolume()
    }
    @objc func cancelPicker(){
        pickerField.resignFirstResponder()
    }
    @IBAction func submitOrder(_ sender: UIButton) {
        //check name of nameTextField
        guard nameTextField.text != "" else{
            //alert: name is empty
            let alert = UIAlertController(title: "請填寫訂購人姓名", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        //create drinkOrder
        let name = nameTextField.text!
        let drink = drinkPickerTextField.text!
        let sugar = sugarGroup[sugarSegment.selectedSegmentIndex]
        let ice = iceGroup[iceSegment.selectedSegmentIndex]
        let volume = volumeGroup[volumeSegment.selectedSegmentIndex]
        var bubble = ""
        if bubbleSwitch.isOn{ bubble = bubbleGroup[1] }
        let price = Int(priceLabel.text!)!
        let orderid = getOrderid()
        let drinkOrder = DrinkOrder(name: name, drink: drink, sugar: sugar, ice: ice, volume: volume, bubble: bubble, price: price, orderid: orderid)
        
        //POST(create) or PUT(update), then alert: submit success
        if isModifyState == true{
            putOrderList(drinkOrder)
            let alert = UIAlertController(title: "訂單已修改", message: "請至購物車確認", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default){ (_) in self.popOrderListController()})
            present(alert, animated: true, completion: nil)
        }else{
            postOrderList(drinkOrder)
            let alert = UIAlertController(title: "訂單已送出", message: "請至購物車確認", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    func popOrderListController(){
        print(#function)
        navigationController?.popViewController(animated: true)
    }
    func getOrderid()->Int{
        if orderList.count == 0{
            return 0
        }
        var idConfirm = false
        var id = 0
        while idConfirm == false {
//            id = String(Int.random(in: 0...999))//generate random id everytime
            id = id + 1//generate id from 0, add 1 everytime
            for i in 0...(orderList.count-1){
                if id == orderList[i].orderid{
                    break
                }else if i == orderList.count-1{
                    idConfirm = true
                }
            }
        }
        return id
    }
    func getOrderList(){
        print(#function)
        let urlStr = "https://sheetdb.io/api/v1/j9xfkocdgfgjx?cast_numbers=price,orderid"
        if let url = URL(string: urlStr){
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data, let orderList = try? JSONDecoder().decode([DrinkOrder].self, from: data){
                    self.orderList = orderList.reversed()
                    print(self.orderList)
//                    print(self.orderList[0].name)
                }
            }.resume()
        }
    }
    func putOrderList(_ drintOrder:DrinkOrder){
        print(#function)
        print(drintOrder)
        print(modifyDrinkOrder.orderid)
        let drinkOrderData = DrinkOrderData(data: drintOrder)
        let updateById = modifyDrinkOrder.orderid
        let url = URL(string: "https://sheetdb.io/api/v1/j9xfkocdgfgjx/orderid/\(updateById)")
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "PUT"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        if let data = try? jsonEncoder.encode(drinkOrderData){
            URLSession.shared.uploadTask(with: urlRequest, from: data) { (retData, res, err) in
                let decoder = JSONDecoder()
                if let retData = retData, let dic = try? decoder.decode([String:Int].self, from: retData), dic["updated"] == 1{
                    print("update success")
                    self.getOrderList()
                }else{
                    print("update fail")
                }
            }.resume()
        }
    }
    func postOrderList(_ drinkOrder:DrinkOrder){
        print(#function)
        print(drinkOrder)
        let drinkOrderData = DrinkOrderData(data: drinkOrder)
        let url = URL(string: "https://sheetdb.io/api/v1/j9xfkocdgfgjx")
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let jsonEncoder = JSONEncoder()
        if let data = try? jsonEncoder.encode(drinkOrderData){
            URLSession.shared.uploadTask(with: urlRequest, from: data) { (retData, res, err) in
                let decoder = JSONDecoder()
                if let retData = retData, let dic = try? decoder.decode([String:Int].self, from: retData), dic["created"] == 1{
                    print("upload success")
                    self.getOrderList()
                }else{
                    print("upload fail")
                }
            }.resume()
        }
    }
    @IBAction func editVolumeSegment(_ sender: UISegmentedControl) {
        checkPrice()
    }
    @IBAction func editBubbleSwitch(_ sender: UISwitch) {
        checkPrice()
    }
    func checkOnlyHotVolume(){
        if drinkMenus[pickerSelection].onlyHot == true{
            iceSegment.selectedSegmentIndex = 0
            iceSegment.isEnabled = false
        }else{
            iceSegment.isEnabled = true
        }
        if drinkMenus[pickerSelection].priceL == 0{
            volumeSegment.selectedSegmentIndex = 0
            volumeSegment.isEnabled = false
        }else{
            volumeSegment.isEnabled = true
        }
        checkPrice()
    }
    func checkPrice(){
        //price: drink, volume and bubble
        var price = 0
        if volumeSegment.selectedSegmentIndex == 0{
            price += drinkMenus[pickerSelection].priceM
        }else{
            price += drinkMenus[pickerSelection].priceL
        }
        if bubbleSwitch.isOn{
            price += 10
        }
        priceLabel.text = price.description
    }
}
extension drinkOrderViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        drinkMenus.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        drinkMenus[row].name
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerSelectionUnconfirm = row
    }
}
extension drinkOrderViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print(#function)
        if textField == nameTextField{
            nameTextField.becomeFirstResponder()
        }else{
            DispatchQueue.main.async {
                self.initDrinkPicker()
            }
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print(#function)
        textField.resignFirstResponder()
        return true
    }
}
