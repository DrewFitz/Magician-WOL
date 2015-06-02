//
//  MagicPacketSender.m
//  Magician
//
//  Created by Drew Fitzpatrick on 5/25/15.
//  Copyright (c) 2015 Drew Fitzpatrick. All rights reserved.
//

#import "MagicPacketSender.h"
//#import <CoreFoundation/CoreFoundation.h>
//#import <sys/socket.h>
#import <netinet/in.h>
//#import <arpa/inet.h>
#import <string.h>
#import <unistd.h>
//#import <netdb.h>
#import <sys/uio.h>

#import "Reachability.h"

#import "AsyncUdpSocket.h"

#import <sys/types.h>
#import <sys/socket.h>
#import <netdb.h>
#import <ifaddrs.h>
#import <arpa/inet.h>

#import "MACAddressManager.h"

@implementation NSString (MACExtension)

-(NSArray*) toMACByteArray {
    unichar char_A = [@"a" characterAtIndex:0];
    unichar char_0 = [@"0" characterAtIndex:0];
    
    NSArray* byteStrings = [self componentsSeparatedByString:@":"];
    
    NSMutableArray* bytes = [NSMutableArray arrayWithCapacity:byteStrings.count];
    
    for (NSString* byteString in byteStrings) {
        unsigned char byte = 0;
        
        NSString* lower = [byteString lowercaseString];
        unichar char0 = [lower characterAtIndex:0];
        unichar char1 = [lower characterAtIndex:1];
        
        if (char0 < char_A) {
            byte += 16 * (char0 - char_0);
        } else {
            byte += 16 * (10 + (char0 - char_A));
        }
        if (char1 < char_A) {
            byte += (char1 - char_0);
        } else {
            byte += (10 + (char1 - char_A));
        }
        
        [bytes addObject:[NSNumber numberWithUnsignedChar:byte]];
    }
    
    return bytes;
}

@end

@implementation MagicPacketSender

+(instancetype) sharedInstance {
    static MagicPacketSender* instance;
    if (instance == nil) {
        instance = [[MagicPacketSender alloc] init];
    }
    return instance;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        // TODO: load config here
    }
    return self;
}

+(NSArray*) getMACAddresses {
    // TODO: load these from some file
    //return @[@"bc:5f:f4:6d:8e:b1"];
    return [[MACAddressManager sharedManager] getAll];
}

+(BOOL) sendAll {
    // check if we have wifi
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus netstatus = [reachability currentReachabilityStatus];
    
    if (netstatus != ReachableViaWiFi) {
        NSLog(@"no WiFi network detected");
        return NO;
    }
    
    NSString *broadcastAddress;
    // find broadcast address
    struct ifaddrs *ifa = NULL, *ifList;
    getifaddrs(&ifList); // should check for errors
    for (ifa = ifList; ifa != NULL; ifa = ifa->ifa_next) {
        if ( strncmp(ifa->ifa_name, "en0", 3) == 0) {
            if (ifa->ifa_dstaddr != NULL) {
                broadcastAddress = [NSString stringWithUTF8String:inet_ntoa( ((struct sockaddr_in *)ifa->ifa_dstaddr)->sin_addr )];
            }
        } else {
            continue;
        }
    }
    freeifaddrs(ifList); // clean up after yourself
    
    if (broadcastAddress == nil) {
        NSLog(@"couldn't find broadcast address");
        return NO;
    }
    
    AsyncUdpSocket *udpSocket = [[AsyncUdpSocket alloc] initIPv4];
    if(![udpSocket enableBroadcast:YES error:nil]) {
        NSLog(@"Couldn't enable broadcast on socket");
        return NO;
    }
    
    NSArray *MACArray = [self getMACAddresses];
    
    BOOL returnValue = YES;
    for (NSString* mac in MACArray) {
        NSArray* macBytes = [mac toMACByteArray];
        
        unsigned char content[102];
        memset(&content, 0, sizeof(content));
        
        // set magic first bytes
        memset(&content, 0xff, 6);
        for (int i = 6; i < 102; i++) {
            content[i] = [(NSNumber*)macBytes[i%macBytes.count] unsignedCharValue];
        }
        
        NSData *data = [NSData dataWithBytes:content length:sizeof(content)];
        BOOL success = [udpSocket sendData:data toHost:broadcastAddress port:9 withTimeout:-1 tag:0];
        if (!success) {
            returnValue = NO;
        }
    }
    
    return returnValue;
}

//+(BOOL)sendAllOld {
//    // Send packet(s)
//    const char* hostname = "10.0.0.255";
//    const char* portname = "9";
//    
//    struct addrinfo hints;
//    memset(&hints, 0, sizeof(hints));
//    hints.ai_family = AF_UNSPEC;
//    hints.ai_socktype = SOCK_DGRAM;
//    hints.ai_protocol = 0;
//    hints.ai_flags = AI_ADDRCONFIG;
//    
//    struct addrinfo* res = 0;
//    int err = getaddrinfo(hostname, portname, &hints, &res);
//    if (err != 0)
//    {
//        printf("failed to resolve remote socket address (err=%d)", err);
//    }
//    
//    int fd = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
//    if (fd == -1) {
//        printf("%s", strerror(errno));
//    }
//    
//    int broadcast = 1;
//    if (setsockopt(fd, SOL_SOCKET, SO_BROADCAST, &broadcast, sizeof(broadcast)) == -1) {
//        printf("%s", strerror(errno));
//    }
//    
//    unsigned char content[102];
//    memset(&content, 0, sizeof(content));
//    
//    // set magic first bytes
//    memset(&content, 0xff, 6);
//    // copy mac address a bunch
//    const unsigned char macAddr[] = {0xbc, 0x5f, 0xf4, 0x6d, 0x8e, 0xb1};
//    for (int i = 1; i < 17; ++i) {
//        memcpy(content + i*6, macAddr, 6);
//    }
//    
//    
//    struct iovec iov[1];
//    iov[0].iov_base = content;
//    iov[0].iov_len = sizeof(content);
//    
//    struct msghdr message;
//    message.msg_name = res->ai_addr;
//    message.msg_namelen = res->ai_addrlen;
//    message.msg_iov = iov;
//    message.msg_iovlen = 1;
//    message.msg_control = 0;
//    message.msg_controllen = 0;
//    
//    if (sendmsg(fd, &message, 0) == -1) {
//        printf("%s", strerror(errno));
//    }
//    
//    freeaddrinfo(res);
//    close(fd);
//
//    NSLog(@"Magic packets sent");
//    return YES;
//}

@end
