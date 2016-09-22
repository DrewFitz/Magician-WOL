//
//  MACAddressManager.m
//  Magician
//
//  Created by Drew Fitzpatrick on 5/28/15.
//  Copyright (c) 2015 Drew Fitzpatrick. All rights reserved.
//

#import "MACAddressManager.h"

@implementation MACAddressManager {
    NSMutableArray* MACArray;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        MACArray = [[NSMutableArray alloc] init];
    }
    return self;
}

+(instancetype) sharedManager {
    static MACAddressManager* instance;
    if (instance == nil) {
        instance = [[self alloc] init];
    }
    return instance;
}

-(NSURL*)getArchiveURL {
    NSFileManager* fm = [NSFileManager defaultManager];
    NSURL* docURL = [fm URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    return [docURL URLByAppendingPathComponent:@"MACAddressArchive.archive"];
}
-(void) loadFromArchive {
    NSData* archiveData = [NSData dataWithContentsOfURL:[self getArchiveURL]];
    if (archiveData == nil) {
        return;
    }
    NSKeyedUnarchiver* keyedUnarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:archiveData];
    NSMutableArray* a = (NSMutableArray*)[keyedUnarchiver decodeObjectForKey:@"MACArray"];
    if (a != nil) {
        MACArray = a;
    }
    [keyedUnarchiver finishDecoding];
}
-(void) saveToArchive {
    NSMutableData* archiveData = [[NSMutableData alloc] init];
    NSKeyedArchiver* keyedArchiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:archiveData];
    [keyedArchiver encodeObject:MACArray forKey:@"MACArray"];
    [keyedArchiver finishEncoding];
    [archiveData writeToURL:[self getArchiveURL] atomically:YES];
}

-(NSString*) MACAddressAtIndex:(NSUInteger)index {
    return [MACArray objectAtIndex:index];
}
-(void)setMACAddress:(NSString *)address atIndex:(NSUInteger)index {
    [MACArray setObject:address atIndexedSubscript:index];
}
-(void)addMACAddress:(NSString *)address {
    [MACArray addObject:address];
}
-(void)removeMACAddressAtIndex:(NSUInteger)index {
    [MACArray removeObjectAtIndex:index];
}
-(NSUInteger)count {
    return [MACArray count];
}
-(NSArray *)getAll {
    return MACArray;
}

@end
