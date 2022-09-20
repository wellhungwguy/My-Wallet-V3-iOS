// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#import "KeychainItemWrapper+Credentials.h"

#define KEYCHAIN_KEY_SHARED_KEY @"sharedKey"
#define KEYCHAIN_KEY_GUID @"guid"
#define KEYCHAIN_KEY_PIN @"pin"

@implementation KeychainItemWrapper (Credentials)

#pragma mark - GUID

+ (nullable NSString *)guid
{
    return [self retrieveStringItemInKeychainWithKey:KEYCHAIN_KEY_GUID];
}

+ (void)setGuidInKeychain:(nullable NSString *)guid
{
    [self setItemInKeychainWithKey:KEYCHAIN_KEY_GUID value:guid];
}

#pragma mark - SharedKey

+ (nullable NSString *)sharedKey
{
    return [self retrieveStringItemInKeychainWithKey:KEYCHAIN_KEY_SHARED_KEY];
}

+ (void)setSharedKeyInKeychain:(nullable NSString *)sharedKey
{
    [self setItemInKeychainWithKey:KEYCHAIN_KEY_SHARED_KEY value:sharedKey];
}

#pragma mark - PIN

+ (nullable NSString *)pin
{
    return [self retrieveStringItemInKeychainWithKey:KEYCHAIN_KEY_PIN];
}

+ (void)setPinInKeychain:(nullable NSString *)pin
{
    [self setItemInKeychainWithKey:KEYCHAIN_KEY_PIN value:pin];
}

#pragma mark - Helper

+ (void)setItemInKeychainWithKey:(nonnull NSString *)itemKey value:(nullable NSString *)stringValue
{
    if (stringValue == nil || stringValue.length == 0) {
        [self reset:itemKey];
        return;
    }
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:itemKey accessGroup:nil];
    [keychain setObject:(__bridge id)kSecAttrAccessibleWhenUnlockedThisDeviceOnly forKey:(__bridge id)kSecAttrAccessible];
    [keychain setObject:itemKey forKey:(__bridge id)kSecAttrAccount];
    [keychain setObject:[stringValue dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
}

+ (void)reset:(nonnull NSString *)itemKey
{
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:itemKey accessGroup:nil];
    [keychainItem resetKeychainItem];
}

+ (nullable NSString *)retrieveStringItemInKeychainWithKey:(nonnull NSString *)itemKey
{
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:itemKey accessGroup:nil];
    NSData *valueData = [keychain objectForKey:(__bridge id)kSecValueData];
    if (valueData == nil || valueData.length == 0) {
        return nil;
    }
    NSString *valueString = [[NSString alloc] initWithData:valueData encoding:NSUTF8StringEncoding];
    if (valueString == nil || valueString.length == 0) {
        return nil;
    }
    return valueString;
}

@end
