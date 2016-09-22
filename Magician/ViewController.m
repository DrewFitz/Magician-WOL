//
//  ViewController.m
//  Magician
//
//  Created by Drew Fitzpatrick on 1/28/15.
//  Copyright (c) 2015 Drew Fitzpatrick. All rights reserved.
//

#import "ViewController.h"
#import "MagicPacketSender.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendPacket:(id)sender{
    UILocalNotification* notification = [[UILocalNotification alloc] init];
    notification.alertTitle = @"Title";
    notification.alertBody = @"Body";
    NSTimeInterval interval = 6; // test: 6 seconds
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:interval];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.category = @"BootNetwork";
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
//    reply(@{@"success": @YES});
    [MagicPacketSender sendAll];
}

@end

