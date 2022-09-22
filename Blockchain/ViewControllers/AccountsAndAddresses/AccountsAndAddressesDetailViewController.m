// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#import "AccountsAndAddressesNavigationController.h"
#import "AccountsAndAddressesDetailViewController.h"
#import "BCEditAccountView.h"
#import "BCEditAddressView.h"
#import "BlockchainApp-Swift.h"

const int numberOfSectionsAccountUnarchived = 2;
const int numberOfSectionsAddressUnarchived = 1; // 2 if watch only
const int numberOfSectionsArchived = 1;

const int numberOfRowsAccountUnarchived = 3;
const int numberOfRowsAddressUnarchived = 3;

const int numberOfRowsArchived = 1;

const int numberOfRowsTransfer = 1;

typedef enum {
    DetailTypeShowExtendedPublicKey = 100,
    DetailTypeShowAddress = 200,
    DetailTypeEditAccountLabel = 300,
    DetailTypeEditAddressLabel = 400,
    DetailTypeScanPrivateKey = 500,
}DetailType;

@interface AccountsAndAddressesDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation AccountsAndAddressesDetailViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    UILabel *navigationItemTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, [ConstantsObjcBridge defaultNavigationBarHeight])];
    navigationItemTitleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:23];
    navigationItemTitleLabel.adjustsFontSizeToFitWidth = YES;
    navigationItemTitleLabel.textAlignment = NSTextAlignmentCenter;
    navigationItemTitleLabel.textColor = UIColor.whiteColor;
    navigationItemTitleLabel.text = self.navigationItemTitle;
    self.navigationItem.titleView = navigationItemTitleLabel;

    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    if (self.account < 0 && !self.address) {
        DLog(@"Error: no account or address set!");
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:NOTIFICATION_KEY_RELOAD_ACCOUNTS_AND_ADDRESSES object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reload
{
    [self.tableView reloadData];
}

#pragma mark - UI Helpers

- (void)alertToShowAccountXPub
{
    UIAlertController *alertToShowXPub = [UIAlertController alertControllerWithTitle:BC_STRING_WARNING_TITLE message:BC_STRING_EXTENDED_PUBLIC_KEY_WARNING preferredStyle:UIAlertControllerStyleAlert];
    [alertToShowXPub addAction:[UIAlertAction actionWithTitle:BC_STRING_CONTINUE style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showAccountXPub:self.account];
    }]];
    [alertToShowXPub addAction:[UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertToShowXPub animated:YES completion:nil];
}

- (void)alertToConfirmSetDefaultAccount:(int)account
{
    UIAlertController *alertToSetDefaultAccount = [UIAlertController alertControllerWithTitle:BC_STRING_SET_DEFAULT_ACCOUNT message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertToSetDefaultAccount addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self setDefaultAccount:account];
    }]];
    [alertToSetDefaultAccount addAction:[UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertToSetDefaultAccount animated:YES completion:nil];
}

#pragma mark - Wallet status

- (BOOL)isArchived
{
    if (self.address) {
        return [WalletManager.sharedInstance.wallet isAddressArchived:self.address];
    } else {
        return [WalletManager.sharedInstance.wallet isAccountArchived:self.account assetType:self.assetType];
    }
}

#pragma mark - Actions

- (void)transferFundsFromAddressClicked
{

}

- (void)labelAddressClicked
{
    [self showDetailScreenWithType:DetailTypeEditAddressLabel];
}

- (void)labelAccountClicked
{
    [self showDetailScreenWithType:DetailTypeEditAccountLabel];
}

- (void)showAddress:(NSString *)address
{
    [self showDetailScreenWithType:DetailTypeShowAddress];
}

- (void)showAccountXPub:(int)account
{
    [self showDetailScreenWithType:DetailTypeShowExtendedPublicKey];
}

- (void)setDefaultAccount:(int)account
{
    if (self.assetType == LegacyAssetTypeBitcoin)
        [LoadingViewPresenter.shared showWith:[LocalizationConstantsObjcBridge syncingWallet]];
    [WalletManager.sharedInstance.wallet setDefaultAccount:account assetType:self.assetType];
}

- (void)toggleArchive
{
    if (self.address) {

        NSArray *activeLegacyAddresses = [WalletManager.sharedInstance.wallet activeLegacyAddresses:self.assetType];

        if (![WalletManager.sharedInstance.wallet didUpgradeToHd] && [activeLegacyAddresses count] == 1 && [[activeLegacyAddresses firstObject] isEqualToString:self.address]) {
            [AlertViewPresenter.shared standardNotifyWithTitle:BC_STRING_ERROR message:BC_STRING_AT_LEAST_ONE_ADDRESS_REQUIRED in:self handler: nil];
        } else {
            [LoadingViewPresenter.shared showWith:[LocalizationConstantsObjcBridge syncingWallet]];
            [self performSelector:@selector(toggleArchiveLegacyAddress) withObject:nil afterDelay:ANIMATION_DURATION];
        }
    } else {
        if (self.assetType == LegacyAssetTypeBitcoin)
            [LoadingViewPresenter.shared showWith:[LocalizationConstantsObjcBridge syncingWallet]];
        [self performSelector:@selector(toggleArchiveAccount) withObject:nil afterDelay:ANIMATION_DURATION];
    }
}

- (void)toggleArchiveLegacyAddress
{
    [WalletManager.sharedInstance.wallet toggleArchiveLegacyAddress:self.address];
}

- (void)toggleArchiveAccount
{
    [WalletManager.sharedInstance.wallet toggleArchiveAccount:self.account assetType:self.assetType];
}

#pragma mark - Navigation

- (void)showDetailScreenWithType:(DetailType)type
{
    [self performSegueWithIdentifier:SEGUE_IDENTIFIER_ACCOUNTS_AND_ADDRESSES_DETAIL_EDIT sender:[NSNumber numberWithInt:type]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (![segue.identifier isEqualToString:SEGUE_IDENTIFIER_ACCOUNTS_AND_ADDRESSES_DETAIL_EDIT]) {
        return;
    }

    int detailType = [sender intValue];

    if (detailType == DetailTypeEditAddressLabel) {

        BCEditAddressView *editAddressView = [[BCEditAddressView alloc] initWithAddress:self.address];
        editAddressView.labelTextField.text = [WalletManager.sharedInstance.wallet labelForLegacyAddress:self.address assetType:self.assetType];

        [self setupModalView:editAddressView inViewController:segue.destinationViewController];

        [editAddressView.labelTextField becomeFirstResponder];
        [segue.destinationViewController.navigationItem setTitle:BC_STRING_LABEL_ADDRESS];
    } else if (detailType == DetailTypeEditAccountLabel) {

        BCEditAccountView *editAccountView = [[BCEditAccountView alloc] initWithAssetType:self.assetType];
        editAccountView.labelTextField.text = [WalletManager.sharedInstance.wallet getLabelForAccount:self.account assetType:self.assetType];
        editAccountView.accountIdx = self.account;

        [self setupModalView:editAccountView inViewController:segue.destinationViewController];

        [editAccountView.labelTextField becomeFirstResponder];
        [segue.destinationViewController.navigationItem setTitle:BC_STRING_NAME];
    } else if (detailType == DetailTypeShowExtendedPublicKey) {
        AddressesQRCodeView *view = [[AddressesQRCodeView alloc] initWithFrame:self.view.frame];
        NSString *address = [WalletManager.sharedInstance.wallet getXpubForAccount:self.account assetType:self.assetType];
        NSString *header = BC_STRING_EXTENDED_PUBLIC_KEY_DETAIL_HEADER_TITLE;
        NSString *copyButton = BC_STRING_COPY_XPUB;
        [view configureWithAddress:address header:header copyButton:copyButton];
        [self setupModalView:view inViewController:segue.destinationViewController];
        [segue.destinationViewController.navigationItem setTitle:BC_STRING_EXTENDED_PUBLIC_KEY];
    } else if (detailType == DetailTypeShowAddress) {
        AddressesQRCodeView *view = [[AddressesQRCodeView alloc] initWithFrame:self.view.frame];
        NSString *address = self.address;
        NSString *header = @"";
        NSString *copyButton = BC_STRING_COPY_ADDRESS;
        [view configureWithAddress:address header:header copyButton:copyButton];
        [self setupModalView:view inViewController:segue.destinationViewController];
        [segue.destinationViewController.navigationItem setTitle:BC_STRING_ADDRESS];
    }
}

- (void)setupModalView:(UIView *)modalView inViewController:(UIViewController *)viewController
{
    [viewController.view addSubview:modalView];

    CGRect frame = modalView.frame;
    frame.origin.y = viewController.view.frame.origin.y;
    modalView.frame = frame;
}

#pragma mark - Table View Delegate

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [self getFooterViewForSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    UIView *view = [self getFooterViewForSection:section];
    return view.frame.size.height;
}

- (UIView *)getFooterViewForSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, self.tableView.frame.size.width - 30, 50)];
    label.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_SMALL];
    label.numberOfLines = 0;
    label.textColor = [UIColor grayColor];
    label.text = [self getStringForFooterInSection:section];
    [label sizeToFit];

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, label.frame.size.height + 16)];
    [view addSubview:label];

    return view;
}

- (NSString *)getStringForFooterInSection:(NSInteger)section
{
    int sectionMain = 0;
    int sectionArchived = 1;

    if (section == sectionMain) {
        if ([self isArchived]) {
            return BC_STRING_ARCHIVED_FOOTER_TITLE;
        } else {
            if (self.address) {
                return [WalletManager.sharedInstance.wallet isWatchOnlyLegacyAddress:self.address] ? BC_STRING_WATCH_ONLY_FOOTER_TITLE : BC_STRING_ARCHIVE_FOOTER_TITLE;
            } else {
                return BC_STRING_EXTENDED_PUBLIC_KEY_FOOTER_TITLE;
            }
        }
    } else if (section == sectionArchived) {
        return BC_STRING_ARCHIVE_FOOTER_TITLE;
    }

    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self isArchived]) {
        return numberOfSectionsArchived;
    }

    if (self.address) {
        int numberOfSections = numberOfSectionsAddressUnarchived;
        return [WalletManager.sharedInstance.wallet isWatchOnlyLegacyAddress:self.address] ? numberOfSections + 1 : numberOfSections;
    } else {
        return [WalletManager.sharedInstance.wallet getDefaultAccountIndexForAssetType:self.assetType] == self.account ? numberOfSectionsAccountUnarchived - 1 : numberOfSectionsAccountUnarchived;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if ([self isArchived]) {
            return numberOfRowsArchived;
        } else {
            if (self.address) {
                return numberOfRowsAddressUnarchived;
            } else {
                return [WalletManager.sharedInstance.wallet getDefaultAccountIndexForAssetType:self.assetType] == self.account ? numberOfRowsAccountUnarchived - 1 : numberOfRowsAccountUnarchived;
            }
        }
    }

    if (section == 1) {
        return numberOfRowsArchived;
    }

    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    int sectionMain = 0;
    int sectionArchived = 1;

    if (indexPath.section == sectionMain) {
        if ([self isArchived]) {
            switch (indexPath.row) {
                case 0: {
                    [self toggleArchive];
                    return;
                }
            }
        } else {
            switch (indexPath.row) {
                case 0: {
                    if (self.address) {
                        [self labelAddressClicked];
                    } else {
                        [self labelAccountClicked];
                    }
                    return;
                }
                case 1: {
                    if (self.address) {
                            [self showAddress:self.address];
                    } else {
                        if ([WalletManager.sharedInstance.wallet getDefaultAccountIndexForAssetType:self.assetType] != self.account) {
                            [self alertToConfirmSetDefaultAccount:self.account];
                        } else {
                            [self alertToShowAccountXPub];
                        }
                    }
                    return;
                }
                case 2: {
                    if (self.address) {
                        if ([WalletManager.sharedInstance.wallet isWatchOnlyLegacyAddress:self.address]) {
                            // TODO: Watch addresses no longer supported.
                            // Is this necessary?
                        } else {
                            [self toggleArchive];
                        }
                    } else {
                        [self alertToShowAccountXPub];
                    }
                        return;
                }
            }
        }
    }
    if (indexPath.section == sectionArchived) {
        [self toggleArchive];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.textLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_MEDIUM];
    cell.detailTextLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_MEDIUM];
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;

    int sectionMain = 0;
    int sectionArchived = 1;

    BOOL isArchived = [self isArchived];
    if (indexPath.section == sectionMain) {
        switch (indexPath.row) {
            case 0: {
                if (isArchived) {
                    cell.textLabel.text = BC_STRING_UNARCHIVE;
                    cell.textLabel.textColor = UIColor.brandSecondary;
                } else {
                    cell.textLabel.text = self.address? BC_STRING_LABEL : BC_STRING_NAME;
                    cell.textLabel.textColor = UIColor.gray5;
                    cell.detailTextLabel.text = self.address ? [WalletManager.sharedInstance.wallet labelForLegacyAddress:self.address assetType:self.assetType] : [WalletManager.sharedInstance.wallet getLabelForAccount:self.account assetType:self.assetType];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                return cell;
            }
            case 1: {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                if (self.address) {
                    cell.textLabel.text = BC_STRING_ADDRESS;
                    cell.textLabel.textColor = UIColor.gray5;
                    cell.detailTextLabel.text = self.address;
                } else {
                    if ([WalletManager.sharedInstance.wallet getDefaultAccountIndexForAssetType:self.assetType] != self.account) {
                        cell.textLabel.text = BC_STRING_MAKE_DEFAULT;
                        cell.textLabel.textColor = UIColor.brandSecondary;
                        cell.accessoryType = UITableViewCellAccessoryNone;
                    } else {
                        cell.textLabel.text = BC_STRING_EXTENDED_PUBLIC_KEY;
                        cell.textLabel.textColor = UIColor.gray5;
                    }
                }
                return cell;
            }
            case 2: {
                if (self.address) {
                    if ([WalletManager.sharedInstance.wallet isWatchOnlyLegacyAddress:self.address]) {
                        cell.textLabel.text = BC_STRING_SCAN_PRIVATE_KEY;
                        cell.textLabel.textColor = UIColor.brandSecondary;
                        cell.accessoryType = UITableViewCellAccessoryNone;
                    } else {
                        if (isArchived) {
                            cell.textLabel.text = BC_STRING_UNARCHIVE;
                            cell.textLabel.textColor = UIColor.brandSecondary;
                        } else {
                            cell.textLabel.text = BC_STRING_ARCHIVE;
                            cell.textLabel.textColor = UIColor.error;
                        }
                    }
                } else {
                    cell.textLabel.text = BC_STRING_EXTENDED_PUBLIC_KEY;
                    cell.textLabel.textColor = UIColor.gray5;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                return cell;
            }
            default: return nil;
        }
    }
    if (indexPath.section == sectionArchived) {
        if (isArchived) {
            cell.textLabel.text = BC_STRING_UNARCHIVE;
            cell.textLabel.textColor = UIColor.brandSecondary;
        } else {
            cell.textLabel.text = BC_STRING_ARCHIVE;
            cell.textLabel.textColor = UIColor.error;
        }
        return cell;
    }
    return nil;
}

@end
