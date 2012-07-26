//
//  BPContentView.h
//
//  Created by Bojan Percevic on 5/26/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum  {
    kInitialState,              // contentView is floating, partly revealing the view below it
    kFullState,                 // contentView is taking up the whole screen
    kHiddenState                // contentView is hidden, totally revealing the view below it
} BPContentViewState;

typedef enum {
    kInitialPosition = 78,      // contentView's position when kInitialState is the current state (78px based on Facebook's Camera App)
    kFullPosition = 0,          // contentView's position when kInUseState is the current state
    kHiddenPosition = 411      // contentView's position when kHidden is the current state, aligns top of contentView with nav/tabBar
} BPContentViewPosition;
    
typedef enum {                  // values that trigger the state transitions
    kUpperBound = 230,          
    kLowerBound = 641,
    kTransitionBound = 240
} BPContentViewBound;

/*

 kHiddenPosition is 411 because when it rests there, the contentView that is still on screen is exactly the size of a UITabBar.  Therefore you can add
 a faux UITabBar upon entering kHiddenState.
 
 */

@class BPContentView;
@protocol BPContentViewDelegate <NSObject>
@optional
- (void)contentView:(BPContentView*)contentView didEnterState:(BPContentViewState)newState fromState:(BPContentViewState)oldState;
- (void)contentView:(BPContentView*)contentView willEnterState:(BPContentViewState)state;
- (void)contentView:(BPContentView*)contentView isEnteringState:(BPContentViewState)state;
- (void)contentView:(BPContentView*)contentView didEnterState:(BPContentViewState)state;
@end

@interface BPContentView : UIView  {
    @private
    UIView *parentView;
    UIPanGestureRecognizer *panRecognizer;
    CGPoint originalPosition;
    CGPoint currentPosition;
    CGPoint panVelocity;
    BPContentViewState contentViewState;
    BPContentViewState previewContentViewState;
    BPContentViewPosition contentViewPosition;
}

@property (nonatomic, assign) id<BPContentViewDelegate> delegate;
- (id)initWithSuperView:(UIView*)view andDelegate:(id<BPContentViewDelegate>)contentViewDelegate;
- (void)enterState:(BPContentViewState)state;
@end


