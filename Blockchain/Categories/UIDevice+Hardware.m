// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.0 Edition
 BSD License, Use at your own risk
 */

#import "UIDevice+Hardware.h"

#define UNSAFE_CHECK_PATH_CYDIA @"/Applications/Cydia.app"
#define UNSAFE_CHECK_PATH_MOBILE_SUBSTRATE @"/Library/MobileSubstrate/MobileSubstrate.dylib"
#define UNSAFE_CHECK_PATH_BIN_BASH @"/bin/bash"
#define UNSAFE_CHECK_PATH_USR_SBIN_SSHD @"/usr/sbin/sshd"
#define UNSAFE_CHECK_PATH_ETC_APT @"/etc/apt"
#define UNSAFE_CHECK_PATH_WRITE_TEST @"/private/test.txt"
#define UNSAFE_CHECK_CYDIA_URL @"cydia://package/com.example.package"

@implementation UIDevice (Hardware)

- (BOOL)isUnsafe
{
    if (TARGET_IPHONE_SIMULATOR) {
        return NO;
    }

    NSFileManager *defaultManager = NSFileManager.defaultManager;

    if ([defaultManager fileExistsAtPath:UNSAFE_CHECK_PATH_CYDIA]) {
        return YES;
    } else if([defaultManager fileExistsAtPath:UNSAFE_CHECK_PATH_MOBILE_SUBSTRATE]) {
        return YES;
    } else if([defaultManager fileExistsAtPath:UNSAFE_CHECK_PATH_BIN_BASH]) {
        return YES;
    } else if([defaultManager fileExistsAtPath:UNSAFE_CHECK_PATH_USR_SBIN_SSHD]) {
        return YES;
    } else if([defaultManager fileExistsAtPath:UNSAFE_CHECK_PATH_ETC_APT]) {
        return YES;
    }

    NSError *error;
    NSString *stringToBeWritten = @"TEST";
    [stringToBeWritten writeToFile:UNSAFE_CHECK_PATH_WRITE_TEST
                        atomically:YES
                          encoding:NSUTF8StringEncoding
                             error:&error];
    if (error == nil) {
        return YES;
    } else {
        [defaultManager removeItemAtPath:UNSAFE_CHECK_PATH_WRITE_TEST error:nil];
    }

    if ([UIApplication.sharedApplication canOpenURL:[NSURL URLWithString:UNSAFE_CHECK_CYDIA_URL]]) {
        return YES;
    }

    return NO;
}

@end
