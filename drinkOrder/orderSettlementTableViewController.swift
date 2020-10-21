//
//  orderSettlementTableViewController.swift
//  drinkOrder
//
//  Created by 方芸萱 on 2020/10/15.
//

import UIKit

class orderSettlementTableViewController: UITableViewController {
    var orderList = [DrinkOrder]()
    var drinkList = [DrinkSettlement]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        print(#function)
        countDrink()
    }
    func countDrink(){
        print(#function)
        print(orderList)
        if orderList.count == 0{
            print("OrderList is empity")
            print(drinkList)
            return
        }
        for i in 0...orderList.count-1 {
            let drinkDetail = "\(orderList[i].drink) \(orderList[i].sugar) \(orderList[i].ice) \(orderList[i].volume) \(orderList[i].bubble)"
            if i == 0{
                drinkList.append(DrinkSettlement(drinkDetail: drinkDetail, count: 1, price: orderList[i].price))
                continue
            }
            for y in 0...drinkList.count-1 {
                if drinkDetail == drinkList[y].drinkDetail{
                    drinkList[y].count += 1
                    break
                }
                if y == drinkList.count-1{
                    drinkList.append(DrinkSettlement(drinkDetail: drinkDetail, count: 1, price: orderList[i].price))
                }
            }
        }
        print(drinkList)
//        let sortArr = orderList.sorted {
//            $0.price > $1.price
//        }
//        print(sortArr)
        
//        let arr = [1,4,2,5,3]
//        let sortArr = arr.sorted { $0 < $1 }
//        print(sortArr)
        
//        drinkList.forEach { (DrinkSettlement) in
//            if DrinkSettlement.count == 0{
//
//            }
//        }
//        for i in 0...drinkList.count-1 {
//            if drinkList[i].count == 0{
//                drinkList.remove(at: i)
//            }
//        }
    }
    @IBAction func deleteOrderList(_ sender: Any) {
        print(#function)
        let alert = UIAlertController(title: "清空訂單", message: "請問是否要清空全部的訂單資料？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "清空", style: .destructive){ (_) in
            print("delete all")
            self.deleteAllOrderList()
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    func deleteAllOrderList(){
        orderList.removeAll()
        drinkList.removeAll()
        tableView.reloadData()
        let url = URL(string: "https://sheetdb.io/api/v1/j9xfkocdgfgjx/all")
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "DELETE"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: urlRequest) { (retData, res, err) in
            let decoder = JSONDecoder()
            if let data = retData, let dic = try? decoder.decode([String:Int].self, from: data){
                print(dic)
            }
        }.resume()
    }
    func checkTotal()->Int{
        var price = 0
        drinkList.forEach { (DrinkSettlement) in
//            print(DrinkSettlement.drinkDetail)
//            print(DrinkSettlement.price)
//            print(DrinkSettlement.count)
            price += (DrinkSettlement.price * DrinkSettlement.count)
        }
        return price
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return drinkList.count+1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == drinkList.count{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "orderSettlementTotal", for: indexPath) as? orderSettlementTotalCell else{
                return UITableViewCell()
            }
            if drinkList.count == 0{
                cell.totalCountLabel.text = "無訂單資料"
                tableView.rowHeight = 95
                tableView.estimatedRowHeight = 0
                print(tableView.rowHeight)
                return cell
            }
            let price = checkTotal()
            cell.totalCountLabel.text = "總共\(orderList.count)杯  總金額\(price)元"
//            cell.drinkSettlementLabel.text = "total ???"
//            cell.drinkCountLabel.text = "81000"
            return cell
        }
       guard let cell = tableView.dequeueReusableCell(withIdentifier: "orderSettlement", for: indexPath) as? orderSettlementCell else{
            return UITableViewCell()
        }
        cell.drinkSettlementLabel.text = drinkList[indexPath.row].drinkDetail
        cell.drinkCountLabel.text = "\(drinkList[indexPath.row].count)杯"
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
