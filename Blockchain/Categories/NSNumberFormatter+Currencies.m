// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#import "NSNumberFormatter+Currencies.h"
#import "BlockchainApp-Swift.h"

@import FeatureSettingsDomain;

@implementation NSNumberFormatter (Currencies)

#pragma mark - Format helpers

+ (NSString*)formatMoney:(uint64_t)value
{
    return [self formatMoney:value localCurrency:BlockchainSettingsApp.shared.symbolLocal];
}

// Format amount in satoshi as NSString (with symbol)
+ (NSString*)formatMoney:(uint64_t)value
           localCurrency:(BOOL)fsymbolLocal
{
    if (fsymbolLocal && WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local.conversion) {
        @try {
            CurrencySymbol *currencySymbol = WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local;
            NSDecimalNumber *valueDecimal = (NSDecimalNumber*)[NSDecimalNumber numberWithLongLong:value];
            NSDecimalNumber *number = [valueDecimal decimalNumberByDividingBy:currencySymbol.conversion];
            NSString *valueString = [NSNumberFormatter.localCurrencyFormatterWithGroupingSeparator stringFromNumber:number];
            return [currencySymbol.symbol stringByAppendingString:valueString];
        } @catch (NSException * e) {
            DLog(@"Exception: %@", e);
        }
    }
    return [NSNumberFormatter formatBTC:value];
}

+ (NSString*)formatBTC:(uint64_t)value
{
    NSDecimalNumber *satoshi = (NSDecimalNumber *)[NSDecimalNumber numberWithDouble:SATOSHI];
    NSDecimalNumber *number = [(NSDecimalNumber*)[NSDecimalNumber numberWithLongLong:value] decimalNumberByDividingBy:satoshi];
    NSString *string = [NSNumberFormatter.bitcoinFormatterWithGroupingSeparator stringFromNumber:number];
    return [string stringByAppendingString:@" BTC"];
}

#pragma mark - Bitcoin Cash

+ (NSString *)formatBCHAmountInAutomaticLocalCurrency:(uint64_t)amount {
    BOOL inLocalCurrency = BlockchainSettingsApp.shared.symbolLocal;
    return [NSNumberFormatter formatBCHAmount:amount includeSymbol:YES inLocalCurrency:inLocalCurrency];
}

// Format BCH amount in satoshi as NSString, option to include Symbol, option to show in fiat.
+ (NSString *)formatBCHAmount:(uint64_t)amount includeSymbol:(BOOL)includeSymbol inLocalCurrency:(BOOL)localCurrency
{
    NSString *returnValue = @"";
    
    if (localCurrency && [WalletManager.sharedInstance.wallet bitcoinCashExchangeRate]) {
        @try {
            NSString *lastRate = [WalletManager.sharedInstance.wallet bitcoinCashExchangeRate];
            NSDecimalNumber *lastRateDecimalNumber = [NSDecimalNumber decimalNumberWithString:lastRate];
            NSDecimalNumber *satoshi = (NSDecimalNumber *)[NSDecimalNumber numberWithDouble:SATOSHI];
            NSDecimalNumber *conversion = [satoshi decimalNumberByDividingBy:lastRateDecimalNumber];
            NSDecimalNumber *amountDecimalNumber = (NSDecimalNumber*)[NSDecimalNumber numberWithLongLong:amount];
            NSDecimalNumber *resultAmount = [amountDecimalNumber decimalNumberByDividingBy:conversion];
            returnValue = [[NSNumberFormatter localCurrencyFormatterWithGroupingSeparator] stringFromNumber:resultAmount];

            if (includeSymbol) {
                NSString *currencyCode = WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local.symbol;
                returnValue = [currencyCode stringByAppendingFormat:@" %@", returnValue];
            }
        } @catch (NSException * e) {
            DLog(@"Exception: %@", e);
        }
    } else {
        @try {
            NSDecimalNumber *amountDecimalNumber = (NSDecimalNumber*)[NSDecimalNumber numberWithLongLong:amount];
            NSDecimalNumber *satoshi = (NSDecimalNumber *)[NSDecimalNumber numberWithDouble:SATOSHI];
            NSDecimalNumber *resultAmount = [amountDecimalNumber decimalNumberByDividingBy:satoshi];
            returnValue = [NSNumberFormatter.bitcoinFormatterWithGroupingSeparator stringFromNumber:resultAmount];

            if (includeSymbol) {
                returnValue = [returnValue stringByAppendingString:@" BCH"];
            }
        } @catch (NSException * e) {
            DLog(@"Exception: %@", e);
        }
    }

    
    return returnValue;
}

@end
