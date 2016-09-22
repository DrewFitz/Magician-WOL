//
//  MACAddressTableViewController.m
//  Magician
//
//  Created by Drew Fitzpatrick on 5/28/15.
//  Copyright (c) 2015 Drew Fitzpatrick. All rights reserved.
//

#import "MACAddressTableViewController.h"
#import "MACAddressManager.h"

@interface MACAddressTableViewController ()

@end

@implementation MACAddressTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)closeAction:(id)sender {
    [[MACAddressManager sharedManager] saveToArchive];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)addAction:(id)sender {
    [[MACAddressManager sharedManager] addMACAddress:@"00:00:00:00:00:00"];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return [[MACAddressManager sharedManager] count];
    } else {
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MACCell" forIndexPath:indexPath];
    
    MACAddressTableViewCell* macCell = (MACAddressTableViewCell*) cell;
    if (macCell) {
        macCell.addressField.text = [[MACAddressManager sharedManager] MACAddressAtIndex:[indexPath row]];
        macCell.delegate = self;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[MACAddressManager sharedManager] removeMACAddressAtIndex:[indexPath row]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
    MACAddressTableViewCell* macCell = (MACAddressTableViewCell*) cell;
    if (macCell) {
        [macCell startEditing];
    }
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - MAC cell delegate

-(void)didFinishEditingMACAddressCell:(MACAddressTableViewCell *)cell {
    NSIndexPath* path = [self.tableView indexPathForCell:cell];
    NSString* newMAC = cell.addressField.text;
    [[MACAddressManager sharedManager] setMACAddress:newMAC atIndex:[path row]];
}

@end
