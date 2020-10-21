//
//  orderListTableViewController.swift
//  drinkOrder
//
//  Created by 方芸萱 on 2020/9/23.
//

import UIKit

class orderListTableViewController: UITableViewController {

    var orderList = [DrinkOrder]()
    var searchOrderList = [DrinkOrder]()
    var searchController:UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initial()
    }
    override func viewWillAppear(_ animated: Bool) {
//        getOrderListFake()
        getOrderList()
    }
    func initial(){
        title = "訂單資料"
        //refresh
        refreshControl?.addTarget(self, action: #selector(refreshOrderList(refreshControl:)), for: UIControl.Event.valueChanged)
        //search bar
        tableView.tableHeaderView = searchController?.searchBar
        searchController = UISearchController(searchResultsController: nil)
        searchController?.searchResultsUpdater = self
        searchController?.searchBar.delegate = self
        searchController?.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    @objc func refreshOrderList(refreshControl:UIRefreshControl){
        getOrderList()
        refreshControl.endRefreshing()
    }
    func getOrderListFake(){
        print(#function)
        orderList = [drinkOrder.DrinkOrder(name: "flora", drink: "熟成冷露", sugar: "微糖", ice: "去冰", volume: "大杯", bubble: "加白玉", price: 40, orderid: 13), drinkOrder.DrinkOrder(name: "qq", drink: "雪藏紅茶", sugar: "微糖", ice: "去冰", volume: "大杯", bubble: "", price: 55, orderid: 10), drinkOrder.DrinkOrder(name: "Alice", drink: "太妃紅茶", sugar: "半糖", ice: "熱飲", volume: "中杯", bubble: "", price: 30, orderid: 2), drinkOrder.DrinkOrder(name: "Wesley", drink: "熟成紅茶", sugar: "半糖", ice: "去冰", volume: "大杯", bubble: "", price: 30, orderid: 12), drinkOrder.DrinkOrder(name: "favorite yet", drink: "冷露歐蕾", sugar: "無糖", ice: "熱飲", volume: "大杯", bubble: "", price: 40, orderid: 6), drinkOrder.DrinkOrder(name: "favorite yet", drink: "春芽綠茶", sugar: "正常糖", ice: "正常冰", volume: "大杯", bubble: "加白玉", price: 30, orderid: 3), drinkOrder.DrinkOrder(name: "favorite yet", drink: "春芽綠茶", sugar: "正常糖", ice: "正常冰", volume: "大杯", bubble: "加白玉", price: 30, orderid: 5), drinkOrder.DrinkOrder(name: "favorite", drink: "春梅冰茶", sugar: "微糖", ice: "熱飲", volume: "大杯", bubble: "", price: 45, orderid: 1), drinkOrder.DrinkOrder(name: "right", drink: "愛司紅茶", sugar: "微糖", ice: "去冰", volume: "大杯", bubble: "", price: 40, orderid: 678), drinkOrder.DrinkOrder(name: "t", drink: "熟成紅茶", sugar: "無糖", ice: "熱飲", volume: "中杯", bubble: "加白玉", price: 35, orderid: 321), drinkOrder.DrinkOrder(name: "Kuma", drink: "白玉歐蕾", sugar: "半糖", ice: "少冰", volume: "中杯", bubble: "加白玉", price: 60, orderid: 8), drinkOrder.DrinkOrder(name: "emma", drink: "玉薑歐蕾", sugar: "無糖", ice: "熱飲", volume: "中杯", bubble: "加白玉", price: 75, orderid: 998), drinkOrder.DrinkOrder(name: "emma", drink: "金薑歐蕾", sugar: "半糖", ice: "熱飲", volume: "中杯", bubble: "", price: 65, orderid: 9), drinkOrder.DrinkOrder(name: "emma", drink: "愛司紅茶", sugar: "微糖", ice: "去冰", volume: "大杯", bubble: "", price: 40, orderid: 593), drinkOrder.DrinkOrder(name: "t", drink: "熟成紅茶", sugar: "微糖", ice: "去冰", volume: "大杯", bubble: "加白玉", price: 40, orderid: 4), drinkOrder.DrinkOrder(name: "rights of", drink: "金薑歐蕾", sugar: "半糖", ice: "熱飲", volume: "中杯", bubble: "", price: 65, orderid: 54), drinkOrder.DrinkOrder(name: "make", drink: "金薑歐蕾", sugar: "正常糖", ice: "熱飲", volume: "中杯", bubble: "", price: 65, orderid: 7)]
//        print(self.orderList[0].name)
    }
    func getOrderList(){
        print(#function)
        let urlStr = "https://sheetdb.io/api/v1/j9xfkocdgfgjx?cast_numbers=price,orderid"
        if let url = URL(string: urlStr){
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data, let orderList = try? JSONDecoder().decode([DrinkOrder].self, from: data){
                    self.orderList = orderList.reversed()//最新的資料放最上面
//                    print(self.orderList)
//                    print(self.orderList[0].name)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }.resume()
        }
    }
    func deleteOrderList(_ row:Int){
        let deleteById = orderList[row].orderid
        let url = URL(string: "https://sheetdb.io/api/v1/j9xfkocdgfgjx/orderid/\(deleteById)")
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if navigationItem.searchController?.isActive == true{
            if searchOrderList.count == 0{
                return 1
            }
            return searchOrderList.count
        }else{
            if orderList.count == 0{
                return 1
            }
            return orderList.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if navigationItem.searchController?.isActive == true{
            if searchOrderList.count == 0{
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "orderSettlementTotal", for: indexPath) as? orderSettlementTotalCell else{
                    return UITableViewCell()
                }
                cell.totalCountLabel.text = "無訂單資料"
                return cell
            }
        }else{
            if orderList.count == 0{
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "orderSettlementTotal", for: indexPath) as? orderSettlementTotalCell else{
                    return UITableViewCell()
                }
                cell.totalCountLabel.text = "無訂單資料"
                return cell
            }
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "orderListCell", for: indexPath) as? orderListCell else{
            return UITableViewCell()
        }
        if navigationItem.searchController?.isActive == true{
            cell.drinkOrder = searchOrderList[indexPath.row]
        }else{
            cell.drinkOrder = orderList[indexPath.row]
        }
        cell.update()
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
            deleteOrderList(indexPath.row)
            orderList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }*/
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let updateAction = UIContextualAction(style: .normal, title: "修改") { (action, view, completionHandler) in
            //action1:performSegue,execute prepare with sender
//            self.performSegue(withIdentifier: "modifyOrder", sender: indexPath.row)
//            self.title = "取消修改"
            //action2:pushViewController
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "drinkModify") as? drinkOrderViewController{
                print("drinkModify")
                controller.isModifyState = true
                controller.modifyRow = indexPath.row
                if self.navigationItem.searchController?.isActive == true{
                    controller.modifyDrinkOrder = self.searchOrderList[indexPath.row]
                }else{
                    controller.modifyDrinkOrder = self.orderList[indexPath.row]
                }
                self.navigationController?.pushViewController(controller, animated: true)
            }
            completionHandler(true)
        }
        let deleteAction = UIContextualAction(style: .destructive, title: "刪除") { (action, view, completionHandler) in
            
            self.deleteOrderList(indexPath.row)
            self.orderList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            completionHandler(true)
        }
        updateAction.backgroundColor = .systemBlue
        let configuration = UISwipeActionsConfiguration(actions: [updateAction, deleteAction])
        return configuration
    }
    
    @IBSegueAction func orderSettlementSegue(_ coder: NSCoder) -> orderSettlementTableViewController? {
        let controller = orderSettlementTableViewController(coder: coder)
        controller?.orderList = orderList
        return controller
    }
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        print(#function)
        if segue.identifier == "modifyOrder"{
            print("Segue: modifyOrder")
            if let controller = segue.destination as? drinkOrderViewController{
                let row = sender as! Int
                controller.isModifyState = true
                controller.modifyRow = row
                if navigationItem.searchController?.isActive == true{
                    controller.modifyDrinkOrder = searchOrderList[row]
                }else{
                    controller.modifyDrinkOrder = orderList[row]
                }
            }
        }
    }
}

extension orderListTableViewController: UISearchResultsUpdating,UISearchBarDelegate{
    func updateSearchResults(for searchController: UISearchController) {
        print(#function)
        if let searchString = searchController.searchBar.text{
            searchOrderList = orderList.filter({ (drinkOrder) -> Bool in
                drinkOrder.name.lowercased().contains(searchString.lowercased())
            })
            if searchString == ""{
                searchOrderList = orderList
            }
            tableView.reloadData()
        }
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print(#function)
    }
}
