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
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wundeclared-selector"
    Class timeLoader = [[NSBundle bundleForClass:self] classNamed:@"PBTimeKeeper"];
    [timeLoader performSelector:@selector(recordTime)];
#pragma GCC diagnostic pop
}

@end
