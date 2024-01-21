//
//  StoreKitManager.swift
//  UniversalDeonationExample
//
//  Created by Brian Masse on 1/19/24.
//

import Foundation
import StoreKit

@available( iOS 16.0, *)
public class StoreKitManager: ObservableObject {
    
    
    @Published private(set) var coffees: [Product] = []
    @Published private(set) var purchasedCoffees: [Product] = []
    
    private var productDic: Dictionary<String, String> = [
        "smallCoffee": "donation.smallCoffee",
        "mediumCoffee": "donation.mediumCoffee",
        "largeCoffee": "donation.largeCoffee"
        ]
    
    var updateListenerTask: Task<Void, Error>? = nil
    
    public init() {
//        readPropertyList()
        
        Task { await requestProducts() }
        
        updateListenerTask = listenForTransactions()
    }
    
//    MARK: Reading Purchase Options
    private func readPropertyList() {
        if let pListPath = Bundle.main.path(forResource: "Donations", ofType: "plist") {
            
            if let plist = FileManager.default.contents(atPath: pListPath) {
                productDic = ( try? PropertyListSerialization.propertyList(from: plist, format: nil) ) as? [String: String] ?? [:]
            }
        }
    }
    
    @MainActor
    private func requestProducts() async {
        var storeProducts: [Product] = []
        var newCoffees: [Product] = []
        
        do {
            storeProducts = try await Product.products(for: productDic.values)
            
            for product in storeProducts {
                
                switch product.type {
                case .consumable:
                    newCoffees.append( product )
                default:
                    print( "Received an unhandled object from store" )
                }
            }
            
            self.coffees = sortByCost(newCoffees)
            
        } catch {
            print( "failed while requesting Products: \(error.localizedDescription)" )
        }
    }
    
    private func sortByCost(_ products: [Product]) -> [Product] {
        products.sorted { product1, product2 in
            product1.price < product2.price
        }
    }
    
//    MARK: TransactionHandling
//    If part of the transaction is updated while not in a purchase loop, we need to be able to handle that.
//    This could be a family purchasing something in a shared subscription plan, making a purchase on another device, or an update to an auto-renewing or non auto-renewing subscription.
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            //Iterate through any transactions that don't come from a direct call to `purchase()`.
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerifcationResult(result)
                    
                    await self.updateCustomerProductStatus()
                    
                    await transaction.finish()
                } catch {
                    print("Transaction failed verification")
                }
            }
        }
    }
    
    
//    MARK: Purchase Logic
    @MainActor
    func purhcase(product: Product) async throws -> Transaction? {

        let results = try await product.purchase()
        
        switch results {
        case .success(let verificationResult):
            let transaction = try checkVerifcationResult(verificationResult)
            
            await updateCustomerProductStatus()
            
            await transaction.finish()
            
            return transaction
            
            
        case .userCancelled:
            print( "cancelled purchase" )
            return nil
            
        case .pending:
            print("pending")
            return nil
            
        @unknown default: return nil
        }
    }
    
//        check if the JWS passes the storeKit Verification
    private func checkVerifcationResult<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
            
        case .verified(let signedType):
            return signedType
        }
    }
    
    @MainActor
    private func updateCustomerProductStatus() async {
        for await result in Transaction.currentEntitlements {
            
            do {
                let transaction = try checkVerifcationResult(result)
                
                switch transaction.productType {
                    
                case .consumable:
                    if let coffee = coffees.first(where: { product in product.id == transaction.productID }) {
                        purchasedCoffees.append(coffee)
                    }

                default:
                    print( "unhandled product type received when updating customer product status" )
                }
                
                
            } catch {
                print("error validating purchasing in updateStatus: \(error.localizedDescription)")
            }
        }
    }
    
    private enum StoreError: Error {
        case failedVerification
    }
}
