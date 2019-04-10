//
//  FlipperKitMemoryLeakAggregator.h
//  Pods
//
//  Created by Marc Terns on 4/4/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FlipperKitMemoryLeakAggregator : NSObject

+ (instancetype)sharedInstance;
- (NSArray *)findMemoryLeaks;
@end

NS_ASSUME_NONNULL_END
