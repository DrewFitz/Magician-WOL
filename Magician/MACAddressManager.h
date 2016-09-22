//
//  MACAddressManager.h
//  Magician
//
//  Created by Drew Fitzpatrick on 5/28/15.
//  Copyright (c) 2015 Drew Fitzpatrick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MACAddressManager : NSObject

+(instancetype) sharedManager;

-(void) loadFromArchive;
-(void) saveToArchive;

-(NSString*) MACAddressAtIndex:(NSUInteger)index;
-(void) setMACAddress:(NSString*)address atIndex:(NSUInteger)index;
-(void) addMACAddress:(NSString*)address;
-(void) removeMACAddressAtIndex:(NSUInteger)index;
-(NSArray*) getAll;
-(NSUInteger) count;

@end
