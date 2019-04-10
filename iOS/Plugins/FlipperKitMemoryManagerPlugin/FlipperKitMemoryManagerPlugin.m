//
//  FlipperKitMemoryManagerPlugin.m
//  Sample
//
//  Created by Marc Terns on 9/30/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "FlipperKitMemoryManagerPlugin.h"
#import <FlipperKit/FlipperConnection.h>
#import <FlipperKit/FlipperResponder.h>
#import <FBAllocationTracker/FBAllocationTrackerManager.h>
#import <FBRetainCycleDetector/FBRetainCycleDetector.h>
#import <FBAllocationTracker/FBAllocationTrackerSummary.h>
#import "FlipperKitMemoryLeakAggregator.h"

@interface FlipperKitMemoryManagerPlugin ()
@property (nonatomic, strong) id<FlipperConnection> flipperConnection;
@property (nonatomic, strong) NSMutableArray *leaks;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation FlipperKitMemoryManagerPlugin

- (instancetype)init {
    if (self = [super init]) {
        _leaks = [NSMutableArray new];
        _timer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(findRetainCycles) userInfo:nil repeats:YES];
    }
    return self;
        
}

- (void)didConnect:(id<FlipperConnection>)connection {
    self.flipperConnection = connection;
    __block typeof(self) blockSelf = self;
    [connection receive:@"clear" withBlock:^(NSDictionary * params, id<FlipperResponder> responder) {
        blockSelf.leaks = [NSMutableArray new];
    }];
}

- (void)didDisconnect {
    self.flipperConnection = nil;
}

- (NSString *)identifier {
    return @"LeakCanary";
}

- (BOOL)runInBackground {
    return NO;
}

#pragma mark - Private methods

- (void)findRetainCycles {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *newLeaks = [[FlipperKitMemoryLeakAggregator sharedInstance] findMemoryLeaks];
        if(newLeaks.count > 0) {
            [self.leaks addObjectsFromArray:newLeaks];
            [self memoryManagerDidFindRetainCycles:self.leaks];
        }
    });
}

- (void)memoryManagerDidFindRetainCycles:(NSMutableArray *)retainCycles {
//    NSString *a = @"In com.example.leakcanary:1.0:1.\\n"
//    @"* com.example.leakcanary.MainActivity has leaked:\\n"
//    @"* references android.view.inputmethod.InputMethodManager.mServedView\\n"
//    @"* references com.android.internal.policy.impl.PhoneWindow$DecorView.mContext\\n"
//    @"* leaks com.squareup.leakcanary.internal.DisplayLeakActivity instance\\n"
//    @"* Reference Key: 28f138fd-00b0-4fb6-bdbd-ae37600a7473\\n"
//    @"* Device: S.LSI Division, Samsung Electronics Co., Ltd. Android Full Android on ORIGEN QUAD full_origen_quad\\n"
//    @"* Android Version: 4.0.4 API: 15 LeakCanary: 1.3.1\\n"
//    @"* Durations: watch=5011ms, gc=134ms, heap dump=789ms, analysis=19125ms\\n"
//    @"* Details:\\n"
//    @"* Class android.view.inputmethod.InputMethodManager\\n"
//    @"|   static $staticOverhead = byte[] [id=0x40bda221;length=480;size=496]\\n"
//    @"|   static CONTROL_START_INITIAL = 256\\n"
//    @"|   static CONTROL_WINDOW_FIRST = 4\\n"
//    @"|   static CONTROL_WINDOW_IS_TEXT_EDITOR = 2\\n"
//    @"|   static CONTROL_WINDOW_VIEW_HAS_FOCUS = 1\\n"
//    @"|   static DEBUG = false\\n"
//    @"|   static HIDE_IMPLICIT_ONLY = 1\\n"
//    @"|   static HIDE_NOT_ALWAYS = 2\\n"
//    @"|   static MSG_BIND = 2\\n"
//    @"|   static MSG_DUMP = 1\\n"
//    @"|   static MSG_SET_ACTIVE = 4\\n"
//    @"|   static MSG_UNBIND = 3\\n"
//    @"|   static RESULT_HIDDEN = 3\\n"
//    @"|   static RESULT_SHOWN = 2\\n"
//    @"|   static RESULT_UNCHANGED_HIDDEN = 1\\n"
//    @"|   static RESULT_UNCHANGED_SHOWN = 0\\n"
//    @"|   static SHOW_FORCED = 2\\n"
//    @"|   static SHOW_IMPLICIT = 1\\n"
//    @"|   static TAG = java.lang.String [id=0x40bda4a8]\\n"
//    @"|   static mInstance = android.view.inputmethod.InputMethodManager [id=0x41263f38]\\n"
//    @"|   static mInstanceSync = java.lang.Object [id=0x40b69cd0]\\n"
//    @"* Instance of android.view.inputmethod.InputMethodManager\\n"
//    @"|   static $staticOverhead = byte[] [id=0x40bda221;length=480;size=496]\\n"
//    @"|   static CONTROL_START_INITIAL = 256\\n"
//    @"|   static CONTROL_WINDOW_FIRST = 4\\n"
//    @"|   static CONTROL_WINDOW_IS_TEXT_EDITOR = 2\\n"
//    @"|   static CONTROL_WINDOW_VIEW_HAS_FOCUS = 1\\n"
//    @"|   static DEBUG = false\\n"
//    @"|   static HIDE_IMPLICIT_ONLY = 1\\n"
//    @"|   static HIDE_NOT_ALWAYS = 2\\n"
//    @"|   static MSG_BIND = 2\\n"
//    @"|   static MSG_DUMP = 1\\n"
//    @"|   static MSG_SET_ACTIVE = 4\\n"
//    @"|   static MSG_UNBIND = 3\\n"
//    @"|   static RESULT_HIDDEN = 3\\n"
//    @"|   static RESULT_SHOWN = 2\\n"
//    @"|   static RESULT_UNCHANGED_HIDDEN = 1\\n"
//    @"|   static RESULT_UNCHANGED_SHOWN = 0\\n"
//    @"|   static SHOW_FORCED = 2\\n"
//    @"|   static SHOW_IMPLICIT = 1\\n"
//    @"|   static TAG = java.lang.String [id=0x40bda4a8]\\n"
//    @"|   static mInstance = android.view.inputmethod.InputMethodManager [id=0x41263f38]\\n"
//    @"|   static mInstanceSync = java.lang.Object [id=0x40b69cd0]\\n"
//    @"|   mTmpCursorRect = android.graphics.Rect [id=0x41264cd8]\\n"
//    @"|   mService = com.android.internal.view.IInputMethodManager$Stub$Proxy [id=0x41275c38]\\n"
//    @"|   mClient = android.view.inputmethod.InputMethodManager$1 [id=0x41264d18]\\n"
//    @"|   mCompletions = null\\n"
//    @"|   mCurId = null\\n"
//    @"|   mCurMethod = null\\n"
//    @"|   mCurRootView = com.android.internal.policy.impl.PhoneWindow$DecorView [id=0x41331a78]\\n"
//    @"|   mCurrentTextBoxAttribute = null\\n"
//    @"|   mServedView = com.android.internal.policy.impl.PhoneWindow$DecorView [id=0x41331a78]\\n"
//    @"|   mServedInputConnection = null\\n"
//    @"|   mCursorRect = android.graphics.Rect [id=0x41264cf8]\\n"
//    @"|   mNextServedView = com.android.internal.policy.impl.PhoneWindow$DecorView [id=0x41331a78]\\n"
//    @"|   mMainLooper = android.os.Looper [id=0x4124fc70]\\n"
//    @"|   mDummyInputConnection = android.view.inputmethod.BaseInputConnection [id=0x412554a0]\\n"
//    @"|   mIInputContext = android.view.inputmethod.InputMethodManager$ControlledInputConnectionWrapper [id=0x41254ff0]\\n"
//    @"|   mH = android.view.inputmethod.InputMethodManager$H [id=0x412554c8]\\n"
//    @"|   mHasBeenInactive = true\\n"
//    @"|   mFullscreenMode = false\\n"
//    @"|   mCursorSelStart = 0\\n"
//    @"|   mCursorSelEnd = 0\\n"
//    @"|   mServedConnecting = false\\n"
//    @"|   mCursorCandStart = 0\\n"
//    @"|   mCursorCandEnd = 0\\n"
//    @"|   mBindSequence = -1\\n"
//    @"|   mActive = false\\n"
//    @"* Instance of com.android.internal.policy.impl.PhoneWindow$DecorView\\n"
//    @"|   mActionMode = null\\n"
//    @"|   mActionModePopup = null\\n"
//    @"|   mActionModeView = null\\n"
//    @"|   mBackgroundPadding = android.graphics.Rect [id=0x4135b4b8]\\n"
//    @"|   this$0 = com.android.internal.policy.impl.PhoneWindow [id=0x4135eb20]\\n"
//    @"|   mShowActionModePopup = null\\n"
//    @"|   mMenuBackground = null\\n"
//    @"|   mDrawingBounds = android.graphics.Rect [id=0x4135b498]\\n"
//    @"|   mFramePadding = android.graphics.Rect [id=0x4135b4d8]\\n"
//    @"|   mFrameOffsets = android.graphics.Rect [id=0x4135b4f8]\\n"
//    @"|   mFeatureId = -1\\n"
//    @"|   mDownY = 0\\n"
//    @"|   mDefaultOpacity = -1\\n"
//    @"|   mWatchingForMenu = false\\n"
//    @"|   mChanging = false\\n"
//    @"|   mForeground = null\\n"
//    @"|   mSelfBounds = android.graphics.Rect [id=0x4135b440]\\n"
//    @"|   mOverlayBounds = android.graphics.Rect [id=0x4135b460]\\n"
//    @"|   mMatchParentChildren = java.util.ArrayList [id=0x41331d08]\\n"
//    @"* Instance of com.squareup.leakcanary.internal.DisplayLeakActivity\\n"
//    @"|   static $staticOverhead = byte[] [id=0x412db3f9;length=48;size=64]\\n"
//    @"|   static SHOW_LEAK_EXTRA = java.lang.String [id=0x413554a0]\\n"
//    @"|   static TAG = java.lang.String [id=0x413554f0]\\n"
//    @"|   actionButton = android.widget.Button [id=0x413bc4e0]\\n"
//    @"|   failureView = android.widget.TextView [id=0x413bbe28]\\n"
//    @"|   leaks = java.util.ArrayList [id=0x413c08e0]\\n"
//    @"|   listView = android.widget.ListView [id=0x413ba508]\\n"
//    @"|   visibleLeakRefKey = null\\n"
//    @"|   maxStoredLeaks = 7\\n"
//    @"|   mActionBar = com.android.internal.app.ActionBarImpl [id=0x413bcef8]\\n"
//    @"|   mActivityInfo = android.content.pm.ActivityInfo [id=0x41381390]\\n"
//    @"|   mAllLoaderManagers = android.util.SparseArray [id=0x413bd5f0]\\n"
//    @"|   mApplication = <stripped> [id=0x4126ffe8]\\n"
//    @"|   mBase = android.app.ContextImpl [id=0x41355720]";
    NSMutableArray *leaksArray = [NSMutableArray new];
    for (NSArray<FBObjectiveCObject *> *objects in retainCycles) {
        for (FBObjectiveCObject *object in objects) {
            NSMutableDictionary *leak = [NSMutableDictionary new];
            [leak setObject:object.classNameOrNull forKey:@"title"];
            [leak setObject:[NSString stringWithFormat:@"%zu", object.objectAddress] forKey:@"root"];
            [leak setObject:[NSString stringWithFormat:@"%zu", sizeof(object.object)] forKey:@"retainedSize"];
            [leak setObject: @{[object description]:@{@"id": [NSString stringWithFormat:@"%zu", object.objectAddress],
                                                      @"name": [object description],
                                                      @"expanded": @YES,
                                                      @"children": @[],
                                                      @"attributes": @[],
                                                      @"data": @{},
                                                      @"decoration": @"",
                                                      @"extraInfo": @{}}} forKey:@"elements"];
            
            [leak setObject: @{[object description]:@{@"id": [NSString stringWithFormat:@"%zu", object.objectAddress],
                                                      @"name": [object description],
                                                      @"expanded": @YES,
                                                      @"children": @[],
                                                      @"attributes": @[],
                                                      @"data": @{},
                                                      @"decoration": @"",
                                                      @"extraInfo": @{}}} forKey:@"elementsSimple"];
            [leak setObject:@{@"a":@"a"} forKey:@"staticValues"];
            [leak setObject:@{@"a":@"a"} forKey:@"instanceFields"];
            [leaksArray addObject:leak];
        }
    }
    [self.flipperConnection send:@"reportLeak" withParams:@{@"leaks": leaksArray}];
    NSLog(@"%@", retainCycles);
}

@end
