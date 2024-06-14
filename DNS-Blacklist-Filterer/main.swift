//
//  main.swift
//  DNS-Blacklist-Filterer
//
//  Created by Tundzhay Dzhansaz on 14/06/2024.
//

import Foundation


// File paths
let inputFilePath = "/Users/tundzhaydzhansaz/Desktop/DNS-Blacklist-Filterer/MaximumProtection-PRO-BlacklistedURLs.txt"
let outputFilePath = "/Users/tundzhaydzhansaz/Desktop/DNS-Blacklist-Filterer/output.txt"

// File paths
//let inputFilePath = "/path/to/your/input/file.txt"
//let outputFilePath = "/path/to/your/output/file.txt"

// Function to extract the main domain from a subdomain
func getMainDomain(from domain: String) -> String? {
    let components = domain.split(separator: ".")
    guard components.count >= 2 else { return nil }
    return "\(components[components.count - 2]).\(components.last!)"
}

// Initialize dictionaries to track domains
var mainDomains: Set<String> = []
var subDomains: [String: Set<String>] = [:]

do {
    // Read the input file
    let fileContent = try String(contentsOfFile: inputFilePath, encoding: .utf8)
    let lines = fileContent.split(separator: "\n")
    
    for line in lines {
        let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let mainDomain = getMainDomain(from: trimmedLine) {
            if trimmedLine == mainDomain || trimmedLine == "www.\(mainDomain)" {
                mainDomains.insert(mainDomain)
            } else {
                if subDomains[mainDomain] == nil {
                    subDomains[mainDomain] = []
                }
                subDomains[mainDomain]?.insert(trimmedLine)
            }
        } else {
            mainDomains.insert(trimmedLine)
        }
    }
    
    // Prepare the output list
    var outputList: Set<String> = []
    
    // Add main domains and their wildcard entries
    for mainDomain in mainDomains {
        outputList.insert(mainDomain)
        outputList.insert("*.\(mainDomain)")
    }
    
    // Add any additional subdomains that do not match exactly
    for (mainDomain, subDomainSet) in subDomains {
        outputList.formUnion(subDomainSet.filter { !$0.hasSuffix(mainDomain) && $0 != "www.\(mainDomain)" })
    }
    
    // Write the result to the output file
    let result = outputList.sorted().joined(separator: "\n")
    try result.write(toFile: outputFilePath, atomically: true, encoding: .utf8)
    
    print("File processing complete. Output written to \(outputFilePath).")
    
} catch {
    print("Error: \(error)")
}
