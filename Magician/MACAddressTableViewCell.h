//
//  MACAddressTableViewCell.h
//  Magician
//
//  Created by Drew Fitzpatrick on 5/28/15.
//  Copyright (c) 2015 Drew Fitzpatrick. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MACAddressTableViewCell;

@protocol MACAddressTableViewCellDelegate <NSObject>

-(void)didFinishEditingMACAddressCell:(MACAddressTableViewCell*)cell;

@end

@interface MACAddressTableViewCell : UITableViewCell <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *addressField;
@property (weak, nonatomic) id<MACAddressTableViewCellDelegate> delegate;

-(void) startEditing;

@end
