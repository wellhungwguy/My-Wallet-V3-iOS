// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#import "AccountsAndAddressesNavigationController.h"
#import "AccountsAndAddressesViewController.h"
#import "AccountsAndAddressesDetailViewController.h"
#import "UIView+ChangeFrameAttribute.h"
#import "BlockchainApp-Swift.h"

@interface AccountsAndAddressesNavigationController () <WalletAddressesDelegate>
@end

@implementation AccountsAndAddressesNavigationController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    WalletManager.sharedInstance.addressesDelegate = self;
}

- (void)reload
{
    if (![self.visibleViewController isMemberOfClass:[AccountsAndAddressesViewController class]] &&
        ![self.visibleViewController isMemberOfClass:[AccountsAndAddressesDetailViewController class]]) {
        [self popViewControllerAnimated:YES];
    }
    
    if (!self.view.window) {
        [self popToRootViewControllerAnimated:NO];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_RELOAD_ACCOUNTS_AND_ADDRESSES object:nil];
}

#pragma mark WalletAddressesDelegate

- (void)returnToAddressesScreen
{
    [self popToRootViewControllerAnimated:YES];
}

@end
