#import <Foundation/Foundation.h>
#import <MiniApp/MiniApp-Swift.h>

@interface LoaderObjC : NSObject
@end

@implementation LoaderObjC : NSObject
+ (void)load {
    [MiniAppAnalyticsLoader loadMiniAppAnalytics];
    #ifdef MAP_SDK_ADS
    [MiniAppAdLoader loadMiniAds];
    #endif
}
@end
