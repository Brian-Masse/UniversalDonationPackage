//
//  DonationView.swift
//  UniversalDeonationExample
//
//  Created by Brian Masse on 1/20/24.
//

import Foundation
import SwiftUI
import StoreKit
import UIUniversals

//MARK: Social
private struct Social: Equatable, Identifiable {
    let title: String
    let icon: String
    let url: String
    
    init( _ title: String, _ icon: String, _ url: String ) {
        self.title = title
        self.icon = icon
        self.url = url
    }
    
    var id: String {
        self.url
    }
}


@available( iOS 16.0, *)
public struct DonationView: View {
//    MARK: Vars
    @StateObject var storeKit = StoreKitManager()
    
    @State var scrollPosition: CGPoint = .zero
    
    private let aboutMeText = "🔖 I’m an independent developer based in Reading Massachusetts. I've specialized in front-end development, with a concentration in App UI, UX, and system modeling, throughout the past 6 years."
    
    private let supportMeText = "If you want to support the work that I do, consider buying me a coffee!"
    
    private let socials: [Social] = [
        .init( "medium", "newspaper", "https://medium.com/@brianmasse_94741" ),
        .init( "instagram", "rectangle.split.2x2", "https://www.instagram.com/bmasse_gd/"),
        .init( "threads", "rectangle.3.group", "https://www.threads.net/@brian_masse" ),
        .init( "github", "chevron.left.forwardslash.chevron.right", "https://github.com/Brian-Masse" )
    ]
    
    private let apps: [Social] = [
        .init("UIUniversals", "uiuniversals", "https://github.com/Brian-Masse/UIUniversals"),
        .init("Recall.", "recall", "https://apps.apple.com/us/app/recall/id6466136108"),
        .init("Echeveria", "echeveria", "https://apps.apple.com/us/app/echeveria/id6451054692" ),
        .init("Fetch Remastered", "fetch-remastered", "https://apps.apple.com/us/app/fetch-remastered/id1525953394")
        
    ]
    
    public init() {}
    
//    MARK: StructMethods
    private func buyCofffee(_ product: Product) async {
        do {
            if try await storeKit.purhcase(product: product) != nil {
                print("succcess")
            }
        } catch {
            print( "error buying coffee:  \( error.localizedDescription )" )
        }
    }
    
    private func getCoffeeIcon( _ product: Product ) -> String {
        switch product.id {
        case "donation.smallCoffee": return "cup.and.saucer"
        case "donation.mediumCoffee": return "mug"
        case "donation.largeCoffee": return "takeoutbag.and.cup.and.straw"
        default: return "cup.and.saucer"
        }
    }
    
//    MARK: ViewBuilders
    @ViewBuilder
    private func makeHeader() -> some View {
        
        VStack(alignment: .leading) {
            UniversalText("About Me: \nBrian Masse",
                          size: Constants.UIMainHeaderTextSize,
                          font: Constants.titleFont,
                          case: .uppercase,
                          wrap: false,
                          scale: true,
                          lineSpacing: -25)
            
            UniversalText( aboutMeText,
                           size: Constants.UISmallTextSize,
                           font: Constants.mainFont,
                           textAlignment: .leading)
            .padding(.leading)
            .padding(.trailing, 30)
            
            universalImage("headShot")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .clipped()
                .cornerRadius(Constants.UIDefaultCornerRadius)
                .shadow(color: .black.opacity(0.3), radius: 20, y: 20)
                .rotation3DEffect(.degrees( CGFloat(scrollPosition.y / 20) ),
                                  axis: (x: 1, y: -0.5, z: -0.2))
            
        }
        
    }
    
//    MARK: Purchases
    @ViewBuilder
    private func makePurchasesView() -> some View {
        
        VStack(alignment: .leading) {
            
            UniversalText( "Support \nmy work",
                           size: Constants.UIHeaderTextSize,
                           font: Constants.titleFont,
                           case: .uppercase,
                           lineSpacing: -15)
            
            UniversalText( supportMeText,
                           size: Constants.UISmallTextSize,
                           font: Constants.mainFont)
            
            ForEach( storeKit.coffees ) { product in
                makeProductView(product, icon: getCoffeeIcon(product))
            }
        }
    }
    
    @ViewBuilder
    private func makeProductView(_ product: Product, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
            
            UniversalText( product.displayName,
                           size: Constants.UIDefaultTextSize,
                           font: Constants.mainFont)
            
            Spacer()
            
            LargeRoundedButton("", icon: "arrow.forward", style: .accent) {
                Task { await buyCofffee(product) }
            }
            .foregroundStyle(.black)
            .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
        }
        .rectangularBackground(style: .secondary)
    }
    
    @ViewBuilder
    private func makeSocialsView(geo: GeometryProxy) -> some View {
        VStack(alignment: .leading) {
            UniversalText("Check out \nmy Socials",
                          size: Constants.UIHeaderTextSize,
                          font: Constants.titleFont,
                          case: .uppercase,
                          lineSpacing: -15)
            
            
            ForEach(socials) { social in
                makeSocialLink( social: social)
                    .padding(.bottom, 7)
                    .padding(.trailing, 30)

            }
        }
    }
    
    @ViewBuilder
    private func makeSocialLink( social: Social ) -> some View {
        UniversalButton {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    UniversalText( social.title,
                                   size: Constants.UISubHeaderTextSize,
                                   font: Constants.mainFont,
                                   case: .uppercase)
                    
                    ResizableIcon("arrow.up.right", size: Constants.UIDefaultTextSize)
                }
                Divider(strokeWidth: 3)
            }
            .opacity(0.6)
            
        } action: {
            guard let url = URL(string: social.url) else { return }
            
            UIApplication.shared.open(url)
        }
    }
    
    @ViewBuilder
    private func makeAppsView() -> some View {
        
        VStack(alignment: .leading) {
            
            UniversalText( "Check out \nmy other work",
                           size: Constants.UIHeaderTextSize,
                           font: Constants.titleFont,
                           case: .uppercase,
                           lineSpacing: -15)
            
            ForEach(apps) { app in
                makeAppPreview(app)
            }
        }
    }
    
    @ViewBuilder
    private func makeAppPreview(_ app: Social) -> some View {
        HStack {
         
            universalImage( app.icon )
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
            
            VStack {
                UniversalText( app.title,
                               size: Constants.UIDefaultTextSize,
                               font: Constants.mainFont)
            }
            
            Spacer()
            
            LargeRoundedButton("", icon: "arrow.forward", style: .primary) {
                guard let url = URL(string: app.url) else { return }
                
                UIApplication.shared.open(url)
            }
            .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
            .universalTextStyle()
        }
        .padding(.trailing, 7)
        .rectangularBackground(5, style: .secondary)
        
    }
    
    
//    MARK: Body
    public var body: some View {
        GeometryReader { geo in
            ScrollReader($scrollPosition, showingIndicator: false) {
                VStack(alignment: .leading) {
                    
                    makeHeader()
                        .padding(.bottom)
                    
                    Divider()
                    
                    makePurchasesView()
                        .padding(.bottom)
                    
                    Divider()
                    
                    makeAppsView()
                        .padding(.bottom)
                    
                    Divider()
                    
                    makeSocialsView(geo: geo)
                        .padding(.bottom)
                    
                }
                .padding()
            }
        }
        .universalBackground()
    }
}

//MARK: UniversalImage
@available(iOS 15.0, *)
public func universalImage(_ name: String) -> Image {
    if let UIImage = UIImage(named: name, in: .module, with: nil) {
        return Image(uiImage: UIImage )
    }
    return Image( "papernoise" )
}
