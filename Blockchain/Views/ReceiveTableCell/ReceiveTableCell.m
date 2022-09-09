// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#import "ReceiveTableCell.h"
#import "BlockchainApp-Swift.h"

@implementation ReceiveTableCell

@synthesize balanceLabel;
@synthesize labelLabel;
@synthesize addressLabel;
@synthesize watchLabel;
@synthesize balanceButton;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.labelLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_SMALL_MEDIUM];
    self.balanceLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_SMALL_MEDIUM];
    self.addressLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_SMALL_MEDIUM];
    
    self.balanceLabel.adjustsFontSizeToFitWidth = YES;
    self.watchLabel.adjustsFontSizeToFitWidth = YES;
    self.watchLabel.text = [LocalizationConstantsObjcBridge nonSpendable];
}

@end
