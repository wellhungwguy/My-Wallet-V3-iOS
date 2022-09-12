// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#import "KeychainItemWrapper.h"

@interface KeychainItemWrapper (Credentials)

#pragma mark - GUID

+ (nullable NSString *)guid;
+ (void)setGuidInKeychain:(nullable NSString *)guid;

#pragma mark - SharedKey

+ (nullable NSString *)sharedKey;
+ (void)setSharedKeyInKeychain:(nullable NSString *)sharedKey;

#pragma mark - PIN

+ (nullable NSString *)pin;
+ (void)setPinInKeychain:(nullable NSString *)pin;

@end
