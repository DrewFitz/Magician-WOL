//
//  GlanceController.m
//  Magician WatchKit Extension
//
//  Created by Drew Fitzpatrick on 5/25/15.
//  Copyright (c) 2015 Drew Fitzpatrick. All rights reserved.
//

#import "GlanceController.h"


@interface GlanceController()

@end


@implementation GlanceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [self updateUserActivity:@"com.DrewFitzpatrick.Magician.glanceActivity" userInfo:[NSDictionary dictionary] webpageURL:nil];
    
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



