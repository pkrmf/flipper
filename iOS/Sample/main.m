/*
 *  Copyright (c) 2018-present, Facebook, Inc.
 *
 *  This source code is licensed under the MIT license found in the LICENSE
 *  file in the root directory of this source tree.
 *
 */
#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import <FBAllocationTracker/FBAllocationTrackerManager.h>
#import <FBRetainCycleDetector/FBAssociationManager.h>

int main(int argc, char * argv[]) {
  @autoreleasepool {
     // [FBAssociationManager hook];
      [[FBAllocationTrackerManager sharedManager] startTrackingAllocations];
      [[FBAllocationTrackerManager sharedManager] enableGenerations];
      return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
  }
}
