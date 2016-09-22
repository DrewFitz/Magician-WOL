//
//  InterfaceController.m
//  Magician WatchKit Extension
//
//  Created by Drew Fitzpatrick on 5/25/15.
//  Copyright (c) 2015 Drew Fitzpatrick. All rights reserved.
//

#import "InterfaceController.h"

@interface InterfaceController()

@property (weak, nonatomic) IBOutlet WKInterfaceImage *buttonInterfaceImage;

@property BOOL isBooting;

@end


@implementation InterfaceController {
    NSTimer* timer;
}

-(void) startAnimating {
    [self.buttonInterfaceImage setImageNamed:@"LightningCircleAnim"];
    [self.buttonInterfaceImage startAnimatingWithImagesInRange:NSMakeRange(0, 60) duration:-1.0 repeatCount:0];
}

-(void) stopAnimating {
    [self.buttonInterfaceImage setImageNamed:@"LightningCircle"];
}

-(void) bootAll {
    [self startAnimating];
    self.isBooting = YES;
    timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(requestBootFromApp) userInfo:nil repeats:NO];
}

-(void)requestBootFromApp {
    [InterfaceController openParentApplication:@{@"requestType": @"bootAll"} reply:^(NSDictionary *replyInfo, NSError *error) {
        NSLog(@"replyInfo: %@", replyInfo);
        NSLog(@"error: %@", error);
        
        [self stopAnimating];
        self.isBooting = NO;
    }];
}

-(void) cancelBoot {
    [timer invalidate];
    [self stopAnimating];
    self.isBooting = NO;
}

- (IBAction)buttonTapped {
    if (self.isBooting) {
        [self cancelBoot];
    } else {
        [self bootAll];
    }
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    self.isBooting = NO;
}

- (void)willActivate {
    [super willActivate];
}

- (void)didDeactivate {
    [super didDeactivate];
}

-(void)handleUserActivity:(NSDictionary *)userInfo {
    NSLog(@"Handle User Activity");
    [self bootAll];
}

-(void)scheduleSnoozeNotification {
    [InterfaceController openParentApplication:@{@"requestType": @"snooze"} reply:^(NSDictionary *replyInfo, NSError *error) {
        NSLog(@"replyInfo: %@", replyInfo);
        NSLog(@"error: %@", error);
    }];
}

-(void)handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)localNotification {
    if ([identifier isEqualToString:@"bootAction"]) {
        NSLog(@"Handle boot action");
        [self bootAll];
    } else if ([identifier isEqualToString:@"snoozeAction"]) {
        [self scheduleSnoozeNotification];
    }
}

-(void)handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)remoteNotification {
    if ([identifier isEqualToString:@"bootAction"]) {
        NSLog(@"Handle boot action");
        [self bootAll];
    } else if ([identifier isEqualToString:@"snoozeAction"]) {
        [self scheduleSnoozeNotification];
    }
}

@end



