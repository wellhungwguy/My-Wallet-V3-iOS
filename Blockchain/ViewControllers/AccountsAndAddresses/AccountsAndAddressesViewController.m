// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#import "AccountsAndAddressesViewController.h"
#import "AccountsAndAddressesDetailViewController.h"
#import "ReceiveTableCell.h"
#import "BlockchainApp-Swift.h"
#import "UIView+ChangeFrameAttribute.h"
#import "NSNumberFormatter+Currencies.h"

@import FeatureSettingsDomain;

#define CELL_HEIGHT_DEFAULT 44.0f

@interface AccountsAndAddressesViewController () <AssetSelectorViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) BOOL isOpeningSelector;
@property (nonatomic, copy) NSString *clickedAddress;
@property (nonatomic, assign) int clickedAccount;
@property (nonatomic, copy) NSArray *allKeys;

@end

@implementation AccountsAndAddressesViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.lightGray;
    self.title = BC_STRING_ADDRESSES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithImage:[UIImage imageNamed:@"Icon-Close-Circle"]
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(closeButtonClicked:)];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@""
                                             style:UIBarButtonItemStylePlain
                                             target:nil
                                             action:nil];

    CGRect selectorFrame = CGRectMake(0,
                                      0,
                                      self.view.frame.size.width,
                                      [ConstantsObjcBridge assetSelectorHeight]);
    
    self.assetSelectorView = [[AssetSelectorView alloc]
                              initWithFrame:selectorFrame
                              assets:@[@(LegacyAssetTypeBitcoin), @(LegacyAssetTypeBitcoinCash)]
                              parentView:self.view];
    self.assetSelectorView.delegate = self;

    CGRect frame = CGRectMake(self.view.frame.origin.x,
                              self.assetSelectorView.frame.origin.y + self.assetSelectorView.frame.size.height,
                              self.view.frame.size.width,
                              self.view.frame.size.height - [ConstantsObjcBridge assetSelectorHeight]);
    self.tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = UIColor.lightGray;
    [self.view insertSubview:self.tableView belowSubview: self.assetSelectorView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:NOTIFICATION_KEY_RELOAD_ACCOUNTS_AND_ADDRESSES object:nil];
    [self reload];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.assetSelectorView close];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reload
{
    self.allKeys = [WalletManager.sharedInstance.wallet allLegacyAddresses:self.assetType];
    [self.tableView reloadData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SEGUE_IDENTIFIER_ACCOUNTS_AND_ADDRESSES_DETAIL]) {
        AccountsAndAddressesDetailViewController *detailViewController = segue.destinationViewController;
        detailViewController.assetType = self.assetType;
        if (self.clickedAddress) {
            detailViewController.address = self.clickedAddress;
            detailViewController.account = -1;
            detailViewController.navigationItemTitle = self.clickedAddress;
        } else if (self.clickedAccount >= 0) {
            detailViewController.account = self.clickedAccount;
            detailViewController.address = nil;
            detailViewController.navigationItemTitle = [WalletManager.sharedInstance.wallet getLabelForAccount:self.clickedAccount assetType:self.assetType];
        }
    }
}

- (IBAction)closeButtonClicked:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Actions

- (void)setAssetType:(LegacyAssetType)assetType
{
    _assetType = assetType;
    
    [self reload];
}

- (void)didSelectAddress:(NSString *)address
{
    self.clickedAddress = address;
    self.clickedAccount = -1;
    [self performSegueWithIdentifier:SEGUE_IDENTIFIER_ACCOUNTS_AND_ADDRESSES_DETAIL sender:nil];
}

- (void)didSelectAccount:(int)account
{
    self.clickedAccount = account;
    self.clickedAddress = nil;
    [self performSegueWithIdentifier:SEGUE_IDENTIFIER_ACCOUNTS_AND_ADDRESSES_DETAIL sender:nil];
}

#pragma mark - Asset Selector View Delegate

- (void)didSelectAsset:(LegacyAssetType)assetType
{
    [self.containerView changeYPosition:8 + [ConstantsObjcBridge assetSelectorHeight]];
    self.assetType = assetType;
}

- (void)didOpenSelector
{
    self.isOpeningSelector = YES;
    [self.containerView changeYPosition:8 + [ConstantsObjcBridge assetSelectorHeight]*self.assetSelectorView.assets.count];
    self.isOpeningSelector = NO;
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return CELL_HEIGHT_DEFAULT;
    }
    
    return 70.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        if (![WalletManager.sharedInstance.wallet isInitialized]) {
            return 45.0f;
        } else {
            if ([WalletManager.sharedInstance.wallet didUpgradeToHd]) {
                return 45.0f;
            } else {
                return 0;
            }
        }
    } else {
        return 45.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 45)];
    view.backgroundColor = UIColor.lightGray;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, self.view.frame.size.width, 14)];
    label.textColor = UIColor.brandPrimary;
    label.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL_MEDIUM];
    
    [view addSubview:label];
    
    NSString *labelString;
    
    if (section == 0) {
        labelString = BC_STRING_WALLETS;
    } else if (section == 1) {
        labelString = BC_STRING_IMPORTED_ADDRESSES;
    } else {
        @throw @"Unknown Section";
    }
    
    label.text = labelString;
    
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [WalletManager.sharedInstance.wallet getAllAccountsCount:self.assetType];
        case 1:
            if (self.assetType == LegacyAssetTypeBitcoin) {
                return self.allKeys.count;
            } else {
                return self.allKeys.count > 0 ? 1 : 0;
            }
        default:
            return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [WalletManager.sharedInstance.wallet hasLegacyAddresses:self.assetType] ? 2 : 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        [self didSelectAccount:(int)indexPath.row];
    } else if (indexPath.section == 1) {
        if (self.assetType == LegacyAssetTypeBitcoin) [self didSelectAddress:self.allKeys[indexPath.row]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView sectionZeroCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    int accountIndex = (int) indexPath.row;
    NSString *accountLabelString = [WalletManager.sharedInstance.wallet getLabelForAccount:accountIndex assetType:self.assetType];

    ReceiveTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"receiveAccount"];

    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"ReceiveTableCell" owner:nil options:nil].firstObject;
        cell.backgroundColor = [UIColor whiteColor];
        cell.balanceLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_EXTRA_SMALL];

        if ([WalletManager.sharedInstance.wallet getDefaultAccountIndexForAssetType:self.assetType] == accountIndex) {
            cell.labelLabel.autoresizingMask = UIViewAutoresizingNone;
            cell.balanceLabel.autoresizingMask = UIViewAutoresizingNone;
            cell.balanceButton.autoresizingMask = UIViewAutoresizingNone;
            cell.watchLabel.autoresizingMask = UIViewAutoresizingNone;

            CGFloat labelLabelCenterY = cell.labelLabel.center.y;
            cell.labelLabel.text = accountLabelString;
            [cell.labelLabel sizeToFit];
            [cell.labelLabel changeXPosition:20];
            cell.labelLabel.center = CGPointMake(cell.labelLabel.center.x, labelLabelCenterY);

            cell.watchLabel.hidden = NO;
            cell.watchLabel.text = BC_STRING_DEFAULT;
            CGFloat watchLabelCenterY = cell.watchLabel.center.y;
            [cell.watchLabel sizeToFit];
            [cell.watchLabel changeXPosition:cell.labelLabel.frame.origin.x + cell.labelLabel.frame.size.width + 8];
            cell.watchLabel.center = CGPointMake(cell.watchLabel.center.x, watchLabelCenterY);
            cell.watchLabel.textColor = [UIColor grayColor];

            CGFloat minimumBalanceButtonOriginX = IS_USING_SCREEN_SIZE_LARGER_THAN_SE ? 235 : 194;
            CGFloat watchLabelEndX = cell.watchLabel.frame.origin.x + cell.watchLabel.frame.size.width + 8;

            if (watchLabelEndX > minimumBalanceButtonOriginX) {
                CGFloat smallestDefaultLabelWidth = 18;
                CGFloat difference = cell.watchLabel.frame.size.width - (watchLabelEndX - minimumBalanceButtonOriginX);
                CGFloat newWidth = difference > smallestDefaultLabelWidth ? difference : smallestDefaultLabelWidth;
                [cell.watchLabel changeWidth:newWidth];
            }

            CGFloat windowWidth = tableView.frame.size.width;
            cell.balanceLabel.frame = CGRectMake(minimumBalanceButtonOriginX, 11, windowWidth - minimumBalanceButtonOriginX - 20, 21);
            cell.balanceButton.frame = CGRectMake(minimumBalanceButtonOriginX, 0, windowWidth - minimumBalanceButtonOriginX, CELL_HEIGHT_DEFAULT);
        } else {
            // Don't show the watch only tag and resize the label and balance labels to use up the freed up space
            cell.labelLabel.frame = CGRectMake(20, 11, 185, 21);
            cell.balanceLabel.frame = CGRectMake(217, 11, 120, 21);
            UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 217, cell.frame.size.height-(cell.frame.size.height-cell.balanceLabel.frame.origin.y-cell.balanceLabel.frame.size.height), 0);
            cell.balanceButton.frame = UIEdgeInsetsInsetRect(cell.contentView.frame, contentInsets);

            cell.watchLabel.hidden = YES;
            cell.watchLabel.text = BC_STRING_WATCH_ONLY;
            cell.watchLabel.textColor = UIColor.error;
        }
    }

    cell.labelLabel.text = accountLabelString;
    cell.addressLabel.text = @"";

    uint64_t balance = [[WalletManager.sharedInstance.wallet getBalanceForAccount:accountIndex assetType:self.assetType] longLongValue];

    // Selected cell color
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0,0,cell.frame.size.width,cell.frame.size.height)];
    [v setBackgroundColor:UIColor.brandPrimary];
    [cell setSelectedBackgroundView:v];

    if ([WalletManager.sharedInstance.wallet isAccountArchived:accountIndex assetType:self.assetType]) {
        cell.balanceLabel.text = BC_STRING_ARCHIVED;
        cell.balanceLabel.textColor = UIColor.brandSecondary;
    } else {
        cell.balanceLabel.text = self.assetType == LegacyAssetTypeBitcoin ? [NSNumberFormatter formatMoney:balance] : [NSNumberFormatter formatBCHAmountInAutomaticLocalCurrency:balance];
        cell.balanceLabel.textColor = UIColor.green;
    }
    cell.balanceLabel.minimumScaleFactor = 0.75f;
    [cell.balanceLabel setAdjustsFontSizeToFitWidth:YES];

    [cell.balanceButton addTarget:self action:@selector(toggleSymbol) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView sectionOneCellForRowAtIndexPath:(NSIndexPath *)indexPath {

    // Imported addresses

    NSString *addr = self.allKeys[indexPath.row];

    Boolean isWatchOnlyLegacyAddress = [WalletManager.sharedInstance.wallet isWatchOnlyLegacyAddress:addr];

    ReceiveTableCell *cell;
    if (isWatchOnlyLegacyAddress) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"receiveWatchOnly"];
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"receiveNormal"];
    }

    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"ReceiveTableCell" owner:nil options:nil].firstObject;
        cell.backgroundColor = [UIColor whiteColor];
        cell.balanceLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_EXTRA_SMALL];

        if (isWatchOnlyLegacyAddress) {
            // Show the watch only tag and resize the label and balance labels so there is enough space
            cell.labelLabel.frame = CGRectMake(20, 11, 110, 21);

            cell.balanceLabel.frame = CGRectMake(254, 11, 83, 21);
            UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 254, cell.frame.size.height-(cell.frame.size.height-cell.balanceLabel.frame.origin.y-cell.balanceLabel.frame.size.height), 0);
            cell.balanceButton.frame = UIEdgeInsetsInsetRect(cell.contentView.frame, contentInsets);

            [cell.watchLabel setHidden:FALSE];
        }
        else {
            // Don't show the watch only tag and resize the label and balance labels to use up the freed up space
            cell.labelLabel.frame = CGRectMake(20, 11, 185, 21);

            cell.balanceLabel.frame = CGRectMake(217, 11, 120, 21);
            UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 217, cell.frame.size.height-(cell.frame.size.height-cell.balanceLabel.frame.origin.y-cell.balanceLabel.frame.size.height), 0);
            cell.balanceButton.frame = UIEdgeInsetsInsetRect(cell.contentView.frame, contentInsets);

            [cell.watchLabel setHidden:TRUE];

            // Disable cell highlighting for BCH imported addresses
            if (self.assetType == LegacyAssetTypeBitcoinCash) {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            } else {
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            }
        }
    }

    NSString *label = self.assetType == LegacyAssetTypeBitcoin ? [WalletManager.sharedInstance.wallet labelForLegacyAddress:addr assetType:self.assetType] : BC_STRING_IMPORTED_ADDRESSES;

    if (label) {
        cell.labelLabel.text = label;
    } else {
        cell.labelLabel.text = BC_STRING_NO_LABEL;
    }

    cell.addressLabel.text = self.assetType == LegacyAssetTypeBitcoin ? addr : nil;

    uint64_t balance = self.assetType == LegacyAssetTypeBitcoin ? [[WalletManager.sharedInstance.wallet getLegacyAddressBalance:addr assetType:self.assetType] longLongValue] : [WalletManager.sharedInstance.wallet getTotalBalanceForActiveLegacyAddresses:self.assetType];

    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0,0,cell.frame.size.width,cell.frame.size.height)];
    [v setBackgroundColor:UIColor.brandPrimary];
    [cell setSelectedBackgroundView:v];

    if ([WalletManager.sharedInstance.wallet isAddressArchived:addr]) {
        cell.balanceLabel.text = BC_STRING_ARCHIVED;
        cell.balanceLabel.textColor = UIColor.brandSecondary;
    } else {
        cell.balanceLabel.text = self.assetType == LegacyAssetTypeBitcoin ? [NSNumberFormatter formatMoney:balance] : [NSNumberFormatter formatBCHAmountInAutomaticLocalCurrency:balance];
        cell.balanceLabel.textColor = UIColor.green;
    }
    cell.balanceLabel.minimumScaleFactor = 0.75f;
    [cell.balanceLabel setAdjustsFontSizeToFitWidth:YES];

    [cell.balanceButton addTarget:self action:@selector(toggleSymbol) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    switch (indexPath.section) {
        case 0:
            return [self tableView:tableView sectionZeroCellForRowAtIndexPath:indexPath];
        case 1:
            return [self tableView:tableView sectionOneCellForRowAtIndexPath:indexPath];
        default:
            return nil;
    }
}

- (void)toggleSymbol
{
    BlockchainSettingsApp.shared.symbolLocal = !BlockchainSettingsApp.shared.symbolLocal;
}

@end
