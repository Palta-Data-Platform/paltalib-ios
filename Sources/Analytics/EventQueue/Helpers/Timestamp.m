//
//  Timestamp.m
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 20/07/2022.
//

#import <Foundation/Foundation.h>

@interface PBTimeKeeperLauncher : NSObject

@end

@implementation PBTimeKeeperLauncher

+ (void)load {
    Class timeLoader = [[NSBundle bundleForClass:self] classNamed:@"PBTimeKeeper"];
    [timeLoader performSelector:@selector(recordTime)];
}

@end
