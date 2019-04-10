//
//  FlipperKitMemoryLeakAggregator.m
//  Pods
//
//  Created by Marc Terns on 4/4/19.
//

#import "FlipperKitMemoryLeakAggregator.h"
#import <FBAllocationTracker/FBAllocationTrackerManager.h>
#import <FBRetainCycleDetector/FBRetainCycleDetector.h>
#import <FBAllocationTracker/FBAllocationTrackerSummary.h>

@interface FlipperKitMemoryLeakAggregator ()
@property (nonatomic) NSUInteger generationCounter;
@property (nonatomic, strong) NSArray *trackedClasses;
@end

@implementation FlipperKitMemoryLeakAggregator

+ (instancetype)sharedInstance {
    static FlipperKitMemoryLeakAggregator *sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _trackedClasses = [[[FBAllocationTrackerManager sharedManager] trackedClasses] allObjects];
    }
    return self;
}

- (NSArray *)findMemoryLeaks {
    @synchronized (self) {
        NSMutableArray *retainCycles = [NSMutableArray new];
        for (Class clazz in self.trackedClasses) {
            NSArray *instances = [[FBAllocationTrackerManager sharedManager] instancesForClass:clazz inGeneration:self.generationCounter];
            FBRetainCycleDetector *detector = [FBRetainCycleDetector new];
            for (id instance  in instances) {
                if  ([NSBundle bundleForClass:clazz] != [NSBundle mainBundle]) {
                    continue;
                }
                [detector addCandidate:instance];
                [retainCycles addObjectsFromArray:[[detector findRetainCyclesWithMaxCycleLength:10] allObjects]];
            }
        }
        [[FBAllocationTrackerManager sharedManager] markGeneration];
        self.generationCounter++;
        if (retainCycles.count > 0) {
            return retainCycles;
        }
        return nil;
    }
}
@end
