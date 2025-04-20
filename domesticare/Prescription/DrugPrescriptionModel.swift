//
//  DrugPrescriptionModel.swift
//  domesticare
//
//  Created by Sayuru Rehan on 2025-04-20
//
import CoreData
import Foundation

struct DrugPrescriptionModel: Codable, Equatable, Hashable {
    let name: String;
    let dailyDosage: Int64;
}
