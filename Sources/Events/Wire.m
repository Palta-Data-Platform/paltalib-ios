
@interface PBWiringLauncher : NSObject

@end

@implementation PBWiringLauncher

+ (void)load {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wundeclared-selector"
    Class class = [[NSBundle bundleForClass:self] classNamed:@"PBEventsWiring"];
    [[[class alloc] init] performSelector:@selector(wireStack)];
#pragma GCC diagnostic pop
}

@end
