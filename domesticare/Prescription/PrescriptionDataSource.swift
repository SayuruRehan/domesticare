//
//  PrescriptionDataSource.swift
//  domesticare
//
//  Created by Sayuru Rehan on 2025-04-20
//

import Foundation
import UIKit

class PrescriptionDataSource: NSObject, UITableViewDataSource {
    var fetch_offset = 0
    let Rows_Each_Load = 20
    let drugPrescriptionService: DrugPrescriptionServiceProvider
    
    init(fetch_offset: Int = 0, drugPrescriptionService: DrugPrescriptionServiceProvider) {
        self.drugPrescriptionService = drugPrescriptionService
    }
    
    var drugs: Array<DrugPrescriptionModel> = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drugs.count
    }
    
    func getDrug(at index: IndexPath) -> DrugPrescriptionModel {
        return drugs[index.row]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrescriptionListCell", for: indexPath) as! PrescriptionListCell
        cell.medicationLabel.text = drugs[indexPath.row].name
        
        let dailyDosage = drugs[indexPath.row].dailyDosage
        
        switch Locale.current.language.languageCode?.identifier {
        case "zh":
            cell.dosageLabel.text = "每日\(dailyDosage)粒"
        default:
            cell.dosageLabel.text = "\(dailyDosage) pill\(dailyDosage == 1 ? "" : "s") per day"
        }
        
        
        if (indexPath.row >= drugs.count - 1) {
            loadTableData(tableView)
        }
        
        return cell
    }
    
    func loadTableData(_ tableView: UITableView) {
        var fetched_drugs: [DrugPrescriptionModel] = []
        fetch_offset += Rows_Each_Load
        
        drugPrescriptionService.fetchDrugsBackground(fetch_offset: fetch_offset) { (result) in
            for data in result {
                fetched_drugs.append(DrugPrescriptionModel(name: data.value(forKey: "name") as! String, dailyDosage: data.value(forKey: "dailyDosage") as! Int64))
            }
            if self.drugs != fetched_drugs {
                self.drugs = fetched_drugs
                DispatchQueue.main.async {
                    tableView.reloadData()
                }
            }
        }
    }
    
    func deleteRowAt(_ tableView: UITableView, indexPath: IndexPath, completionHandler: @escaping (Bool) -> Void) {
        NSLog("[\(type(of: self))] delete detected!")
        drugPrescriptionService.removeDrugBackground(drugName: drugs[indexPath.row].name, completionHandler: completionHandler)
        self.drugs.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath, ], with: .left)
    }
    

}
