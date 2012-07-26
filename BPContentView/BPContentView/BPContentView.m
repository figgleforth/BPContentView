//
//  BPContentView.m
//
//  Created by Bojan Percevic on 5/26/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "BPContentView.h"

//  These values trigger the state transitions.
typedef enum {
    kUpperBound = 230,
    kLowerBound = 641,
    kTransitionBound = 240
} BPContentViewBound;

//  These values control the position of the contentView for each state.
//  PositionInitial is based on Facebook Camera App
typedef enum {
    BPContentViewPositionInitial = 78,
    BPContentViewPositionFull = 0,
    BPContentViewPositionHidden = 411
} BPContentViewPosition;

//  These values control the adjustment of the contentView when rotation occurs.
typedef enum
{
    BPContentViewStopperLandscape = 251,
    BPContentViewStopperPortrait = 411
} BPContentViewStopper;

@interface BPContentView ()

@property (assign) id<BPContentViewDelegate> _delegate;
@property (nonatomic, retain) UIView *_parentView;

@property (nonatomic, retain) UIPanGestureRecognizer *panRecognizer;

@property (nonatomic) CGPoint originalPosition;
@property (nonatomic) CGPoint currentPosition;
@property (nonatomic) CGPoint panVelocity;

@property (nonatomic) BPContentViewState currentContentViewState;
@property (nonatomic) BPContentViewState previousContentViewState;
@property (nonatomic) BPContentViewPosition contentViewPosition;

@property (nonatomic) UIDeviceOrientation currentOrientation;
@property (nonatomic) CGFloat hiddenY;

- (void)_handlePan:(UIPanGestureRecognizer *)recognizer;
- (void)_recognizer:(UIPanGestureRecognizer*)recognizer setViewPositionY:(CGFloat)y andViewAlpha:(CGFloat)alpha andViewState:(BPContentViewState)viewState;
- (void)_setState:(BPContentViewState)state;

@end

@implementation BPContentView

- (id)initWithDelegate:(id<BPContentViewDelegate>)delegate superView:(UIView*)view
{
    self = [super initWithFrame:CGRectMake(0, BPContentViewPositionInitial, view.frame.size.width, view.frame.size.height)];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        self._parentView = view;
        self._delegate = delegate;
        
        self.originalPosition = CGPointMake(0, self.center.y-(self.frame.size.height/2));
        self.currentPosition = self.originalPosition;
        
        self.panVelocity = CGPointMake(0, 0);
        
        self.currentContentViewState = BPContentViewStateInitial;
        self.previousContentViewState = self.currentContentViewState;
        
        [self _setState:BPContentViewStateInitial];
        
        
        self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePan:)];
        [self addGestureRecognizer:self.panRecognizer];
        
        [self setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        
        //  Observe Device rotation
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object: nil];
        
    }
    return self;
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    self.currentOrientation = [[UIDevice currentDevice] orientation];
        
    switch (self.currentOrientation) {
        case UIDeviceOrientationPortrait:
        {
            self.hiddenY = BPContentViewStopperPortrait;
            break;
        }
        case UIDeviceOrientationLandscapeLeft:
        {
            self.hiddenY = BPContentViewStopperLandscape;
            break;
        }
        case UIDeviceOrientationLandscapeRight:
        {
            self.hiddenY = BPContentViewStopperLandscape;
            break;
        }
        default:
            self.hiddenY = BPContentViewStopperPortrait;
            break;
    }
    
    if(self.currentContentViewState == BPContentViewStateHidden)
    {
        [self _setState:BPContentViewStateHidden];
    }
}


- (void)_handlePan:(UIPanGestureRecognizer *)recognizer
{
    if(recognizer.state == UIGestureRecognizerStateEnded){
        //  Update previous state reference
        [self setPreviousContentViewState:self.currentContentViewState];
        
        if((self.currentContentViewState == BPContentViewStateInitial)){
            if(self.panVelocity.y < 0){
                [self setCurrentContentViewState:BPContentViewStateFull];
            } else {
                [self setCurrentContentViewState:BPContentViewStateHidden];
            }
        } else if((self.currentContentViewState == BPContentViewStateHidden) && (self.panVelocity.y < 0))
        {
            //  contentView is hidden and the velocity is upwards
            [self setCurrentContentViewState:BPContentViewStateFull];
        } else if((self.currentContentViewState == BPContentViewStateFull) && (self.panVelocity.y > 0))
        {
            //  contentView is full screen and velocity is downwards
            [self setCurrentContentViewState:BPContentViewStateHidden];
        }
        
        //  After the state has been set, animate the view to the correct position according to the state
        switch (self.currentContentViewState)
        {
            case BPContentViewStateInitial:
            {
                [self _setState:BPContentViewStateInitial];
                break;
            }
            case BPContentViewStateFull:
            {
                [self _setState:BPContentViewStateFull];
                break;
            }
            case BPContentViewStateHidden:
            {
                [self _setState:BPContentViewStateHidden];
                break;
            }
        }
        
        self.panVelocity = CGPointMake(0, 0);        
    } else if(recognizer.state == UIGestureRecognizerStateChanged){
        
        CGPoint translation = [recognizer translationInView:self];
        self.panVelocity = [recognizer velocityInView:self];
        
        // Stop the panning if already in certain states
        if ((self.panVelocity.y < 0.0f) && (self.currentContentViewState == BPContentViewStateFull)) {
            return;
        } else if((self.panVelocity.y > 0.0f) && (self.currentContentViewState == BPContentViewStateHidden)) {
            return;
        }
        
        // Keep the contentView from sliding off the screen
        CGFloat verticalBounds = recognizer.view.center.y + translation.y;
        if( (self.panVelocity.y < 0.0f) && (verticalBounds < kUpperBound)){
            verticalBounds = kUpperBound;
        } else if( (self.panVelocity.y > 0.0f) && (verticalBounds > kLowerBound) ){
            verticalBounds = kLowerBound;
        }
        recognizer.view.center = CGPointMake(recognizer.view.center.x, 
                                             verticalBounds);
        
        // Keep track of current Position
        self.currentPosition = CGPointMake(0, recognizer.view.center.y-(self.frame.size.height/2) + translation.y);
        
        
        // Reset the translation so that it does not accumulate and send the view flying
        [recognizer setTranslation:CGPointMake(0, 0) inView:self];
    }
}

- (void)_recognizer:(UIPanGestureRecognizer*)recognizer setViewPositionY:(CGFloat)y andViewAlpha:(CGFloat)alpha andViewState:(BPContentViewState)viewState {
    __block CGPoint tempCurrentPosition;
    [UIView animateWithDuration:.3 animations:^{
        [recognizer.view setFrame:CGRectMake(0, y, recognizer.view.frame.size.width, recognizer.view.frame.size.height)];
        [recognizer.view setAlpha:alpha];
        
        // keep track of temporary current position
        tempCurrentPosition = CGPointMake(0, recognizer.view.center.y-(self.frame.size.height/2));
        
        // determine whether to alert the delegate
        if(tempCurrentPosition.y == y){
            [self setCurrentContentViewState:viewState];
        }
        
        if([self._delegate respondsToSelector:@selector(contentView:isEnteringState:)])
        {
            [self._delegate contentView:self isEnteringState:viewState];
        }
        
    } completion:^(BOOL finished) {
        [self setCurrentState:self.currentContentViewState];
        
        if([self._delegate respondsToSelector:@selector(contentView:didEnterState:fromState:)] && (self.previousContentViewState != self.currentContentViewState))
        {                
            [self._delegate contentView:self didEnterState:self.currentContentViewState fromState:self.previousContentViewState];
        }
        if([self._delegate respondsToSelector:@selector(contentView:didEnterState:)])
        {
            [self._delegate contentView:self didEnterState:self.currentContentViewState];
        }
    }];
}

- (void)_setState:(BPContentViewState)state {
    [self setPreviousContentViewState:self.currentContentViewState];
    
    if([self._delegate respondsToSelector:@selector(contentView:willEnterState:)])
    {
        [self._delegate contentView:self willEnterState:state];
    }
    
    switch (state) {
        case BPContentViewStateInitial:
            [self _recognizer:self.panRecognizer setViewPositionY:BPContentViewPositionInitial andViewAlpha:1.f andViewState:BPContentViewStateInitial];
            break;
        case BPContentViewStateFull:
            [self _recognizer:self.panRecognizer setViewPositionY:BPContentViewPositionFull andViewAlpha:1.f andViewState:BPContentViewStateFull];
            break;
        case BPContentViewStateHidden:
            [self _recognizer:self.panRecognizer setViewPositionY:self.hiddenY andViewAlpha:1.f andViewState:BPContentViewStateHidden];
            break;
    }
}

- (void)setState:(BPContentViewState)state
{
    [self _setState:state];
}

@end
