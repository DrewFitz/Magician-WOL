//
//  MACAddressTableViewCell.m
//  Magician
//
//  Created by Drew Fitzpatrick on 5/28/15.
//  Copyright (c) 2015 Drew Fitzpatrick. All rights reserved.
//

#import "MACAddressTableViewCell.h"

@implementation MACAddressTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.addressField.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(BOOL)validateMACAddress:(NSString*)address {
    NSString* rxString = @"^([abcdef0123456789]{2}:){0,5}[abcdef0123456789]{0,2}$";
    NSRegularExpression* validMACRegex = [NSRegularExpression regularExpressionWithPattern:rxString options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray* matches = [validMACRegex matchesInString:address options:NSMatchingAnchored range:NSMakeRange(0, address.length)];
    if (matches.count > 0) {
        return YES;
    } else {
        return NO;
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString* oldString = textField.text;
    NSString* newString = [oldString stringByReplacingCharactersInRange:range withString:string];

    BOOL valid = [self validateMACAddress:newString];
    if (valid) {
        BOOL isAddingText = oldString.length < newString.length;
        if (isAddingText) {
            if ((newString.length + 1) % 3 == 0 && (newString.length + 1) < 18) { // should add ':'
                textField.text = [newString stringByAppendingString:@":"];
                return NO;
            }
        }
        return YES;
    } else {
        return NO;
    }
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([self.addressField.text isEqualToString:@"00:00:00:00:00:00"]) {
        self.addressField.text = @"";
    }
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    if ([self.addressField.text isEqualToString:@""]) {
        self.addressField.text = @"00:00:00:00:00:00";
    }
    [self.delegate didFinishEditingMACAddressCell:self];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self.delegate didFinishEditingMACAddressCell:self];
    return YES;
}

-(void)startEditing {
    [self.addressField becomeFirstResponder];
}

@end
