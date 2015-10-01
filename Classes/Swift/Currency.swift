//
//  Currency.swift
//  iTestMoneyDesignPatternSwift
//
//  Created by Aleksandar Petrov on 7/27/15.
//  Copyright (c) 2015 Aleksandar Petrov. All rights reserved.
//

import Foundation

//
// This class is simple NSNumberFormatter wrapper
//

class Currency {

    //
    // MARK: Public
    //
    
    static let  availableDecimalSeparators  = Set<String>(["٫", ",", "."])
    static let  availableGroupingSeparators = Set<String>([",", "٬", " ", "’", "\'", "."])

    // Currency code
    var code: String {
        get {
            return self.formatter.currencyCode
        }
        set {
            if (NSLocale.ISOCurrencyCodes() ).contains(newValue) == true {
                self.formatter.currencyCode = newValue
            }
        }
    }

    // Currency symbol
    var symbol: String {
        get {
            return self.formatter.currencySymbol ?? ""
        }
        set {
            self.formatter.currencySymbol = newValue
        }
    }

    // Currency fraction digits
    var maximumFractionDigits: Int {
        get {
            return self.formatter.maximumFractionDigits
        }
        set {
            if newValue > 0 && newValue <= 3 {
                self.formatter.maximumFractionDigits = newValue
            }
        }
    }

    // Currency Decimal Separator
    var decimalSeparator: String {
        get {
            return self.formatter.currencyDecimalSeparator ?? ""
        }
        set {
            if Currency.availableDecimalSeparators.contains(newValue) {
                self.formatter.currencyDecimalSeparator = newValue
            }
        }
    }
    
    // Currency Grouping Separator
    var groupingSeparator: String? {
        get {
            return self.formatter.currencyGroupingSeparator
        }
        set {
            if newValue == nil || Currency.availableGroupingSeparators.contains((newValue!)) {
                self.formatter.currencyDecimalSeparator = newValue
                self.formatter.usesGroupingSeparator    = (newValue != nil)
            }
        }
    }
    
    // Currency formatter
    lazy var formatter: NSNumberFormatter = {
        var formatter           = NSNumberFormatter()
        formatter.numberStyle   = .CurrencyStyle
        formatter.locale        = self.locale
        return formatter
    }()
    
    //
    // MARK: Initialization
    //
    
    // Set locale as constructor DI
    init?(locale: NSLocale) {
        // always set locale to avoid compiler errors
        self.locale = locale
        
        // fail if we can't get currency code from locale
        if !Currency.isLocaleAssociatedWithCurrencyCode(locale) {
            return nil
        }        
    }

    // init with current locale
    convenience init?() {
        self.init(locale: NSLocale.currentLocale())
    }
    
    //
    // MARK: Private
    //
    
    private let locale: NSLocale
}

//
// Class functions extension
//

extension Currency {
    
    // Try to create currency object from locale identifier
    class func currencyForLocaleIdentifier(localeIdentifier string: String) -> Currency? {
        // Check for valid identifier
        if (NSLocale.availableLocaleIdentifiers() ).contains(string) == false {
            return nil
        }
        
        let locale = NSLocale(localeIdentifier: string)
        let currency = Currency(locale: locale)
        return currency
    }

    // Try to create currency object from currency code
    class func currencyWithCurrencyCode(currencyCode string: String) -> Currency? {
        let availableLocaleIdentifiers: [String]    =
            NSLocale.availableLocaleIdentifiers() 
        
        for localeIdentifier in availableLocaleIdentifiers {
            let locale = NSLocale(localeIdentifier: localeIdentifier)
            
            // check if locale currency code is equal to filter
            if let localeCurrencyCode = locale.objectForKey(NSLocaleCurrencyCode) as? String
                where localeCurrencyCode == string {
                    return Currency(locale: locale)
            }            
        }
        
        return nil
    }
    
    // Check if Locale object is Associated With Currency Code
    class func isLocaleAssociatedWithCurrencyCode(locale: NSLocale) -> Bool {
        let string  = locale.objectForKey(NSLocaleCurrencyCode) as? String
        return (string != nil && !string!.isEmpty)
    }
}

//
// MARK: Implement Printable
//

extension Currency: CustomStringConvertible {
    var description: String {
        return "[code = \(self.code), symbol = \(self.symbol), " +
            "maximum fraction digits: \(self.maximumFractionDigits), " +
            "decimal separator = \(self.decimalSeparator), " +
            "grouping separator = \(self.groupingSeparator)]"
    }
}

//
// Implement Hashable
//

extension Currency: Hashable {
    var hashValue : Int {
        get {
            // decimal and grouping separator are only for presentation 
            // and should not be a part of equality check
            return self.locale.hashValue ^ self.code.hashValue ^
                self.symbol.hashValue ^ self.maximumFractionDigits
        }
    }
}

//
// MARK: Implement Equatable
//

extension Currency {
    // value objects are equal if all their fields are equal
    func equals(other: Currency) -> Bool {
        return self.locale == other.locale &&
            self.code == other.code &&
            self.symbol == other.symbol &&
            self.maximumFractionDigits == other.maximumFractionDigits
    }
}

func ==(lhs: Currency, rhs: Currency) -> Bool {
    return lhs.equals(rhs)
}