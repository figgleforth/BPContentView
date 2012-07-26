//
//  BPContentView.h
//
//  Created by Bojan Percevic on 5/26/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

//  BPContentViewStateInitial       contentView is floating, partly revealing the view below it.
//  BPContentViewStateFull          contentView is taking up the whole screen.
//  BPContentViewStateHidden        contentView is hidden, completely revealing the view below it.
typedef enum  {
    BPContentViewStateInitial,
    BPContentViewStateFull,
    BPContentViewStateHidden
} BPContentViewState;

@class BPContentView;

@protocol BPContentViewDelegate <NSObject>
@optional
- (void)contentView:(BPContentView*)contentView didEnterState:(BPContentViewState)newState fromState:(BPContentViewState)oldState;
- (void)contentView:(BPContentView*)contentView willEnterState:(BPContentViewState)state;
- (void)contentView:(BPContentView*)contentView isEnteringState:(BPContentViewState)state;
- (void)contentView:(BPContentView*)contentView didEnterState:(BPContentViewState)state;
@end

@interface BPContentView : UIView

@property (assign) BPContentViewState currentState;

//  init
- (id)initWithDelegate:(id<BPContentViewDelegate>)delegate superView:(UIView*)view;

//  Transition to a state (BPContentViewState)
- (void)setState:(BPContentViewState)state;

@end


