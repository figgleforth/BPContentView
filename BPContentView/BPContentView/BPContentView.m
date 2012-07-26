//
//  BPContentView.m
//
//  Created by Bojan Percevic on 5/26/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "BPContentView.h"

@interface BPContentView ()

// PRIVATE
@property (nonatomic, retain) UIView *parentView;
@property (nonatomic, retain) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic) CGPoint originalPosition;
@property (nonatomic) CGPoint currentPosition;
@property (nonatomic) CGPoint panVelocity;
@property (nonatomic) BPContentViewState contentViewState;
@property (nonatomic) BPContentViewState previewsContentViewState;
@property (nonatomic) BPContentViewPosition contentViewPosition;
@property (nonatomic) UIDeviceOrientation currentOrientation;
@property (nonatomic) CGFloat hiddenY;

- (void)_handlePan:(UIPanGestureRecognizer *)recognizer;
- (void)_recognizer:(UIPanGestureRecognizer*)recognizer setsViewPositionY:(CGFloat)yPosition andViewAlpha:(CGFloat)alpha andViewState:(BPContentViewState)viewState;

@end

@implementation BPContentView
@synthesize parentView;
@synthesize panRecognizer;
@synthesize originalPosition;
@synthesize currentPosition;
@synthesize contentViewState;
@synthesize previewsContentViewState;
@synthesize contentViewPosition;
@synthesize panVelocity;
@synthesize delegate;
@synthesize currentOrientation;
@synthesize hiddenY;

- (id)initWithSuperView:(UIView*)view andDelegate:(id<BPContentViewDelegate>)contentViewDelegate
{
    self = [super initWithFrame:CGRectMake(0, kInitialPosition, view.frame.size.width, view.frame.size.height)];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        self.parentView = view;
        self.delegate = contentViewDelegate;
        
        self.originalPosition = CGPointMake(0, self.center.y-(self.frame.size.height/2));
        self.currentPosition = self.originalPosition;
        self.panVelocity = CGPointMake(0, 0);
        
        self.contentViewState = kInitialState;
        self.previewsContentViewState = self.contentViewState;
        
        [self enterState:kInitialState];
        
        self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:self.panRecognizer];
        
        [self setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        
        // Observe Device rotation
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
        
    }
    return self;
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    //Obtaining the current device orientation
    self.currentOrientation = [[UIDevice currentDevice] orientation];
    
    switch (self.currentOrientation) {
        case UIDeviceOrientationPortrait:
        {
            self.hiddenY = 411;
            break;
        }
        case UIDeviceOrientationLandscapeLeft:
        {
            self.hiddenY = 251;
            break;
        }
        case UIDeviceOrientationLandscapeRight:
        {
            self.hiddenY = 251;
            break;
        }
        default:
            self.hiddenY = 411;
            break;
    }
    if(self.contentViewState == kHiddenState)
    {
        [self enterState:kHiddenState];
    }
}


- (void)_handlePan:(UIPanGestureRecognizer *)recognizer
{
    if(recognizer.state == UIGestureRecognizerStateEnded){
        // update previous state reference
        [self setPreviewsContentViewState:self.contentViewState];
        
        if((self.contentViewState == kInitialState)){
            if(self.panVelocity.y < 0){
                [self setContentViewState:kFullState];
            } else {
                [self setContentViewState:kHiddenState];
            }
        } else if((self.contentViewState == kHiddenState) && (self.panVelocity.y < 0))
        {
            // contentView is hidden and the velocity is upwards
            [self setContentViewState:kFullState];
        } else if((self.contentViewState == kFullState) && (self.panVelocity.y > 0))
        {
            // contentView is full screen and velocity is downwards
            [self setContentViewState:kHiddenState];
        }
        
        // After the state has been set, animate the view to the correct position according to the state
        switch (self.contentViewState)
        {
            case kInitialState:
            {
                [self enterState:kInitialState];
                break;
            }
            case kFullState:
            {
                [self enterState:kFullState];
                break;
            }
            case kHiddenState:
            {
                [self enterState:kHiddenState];
                break;
            }
        }
        
        self.panVelocity = CGPointMake(0, 0);        
    } else if(recognizer.state == UIGestureRecognizerStateChanged){
        
        CGPoint translation = [recognizer translationInView:self];
        self.panVelocity = [recognizer velocityInView:self];
        
        // Stop the panning if already in certain states
        if ((self.panVelocity.y < 0.0f) && (self.contentViewState == kFullState)) {
            return;
        } else if((self.panVelocity.y > 0.0f) && (self.contentViewState == kHiddenState)) {
            return;
        }
        
        // Keep the contentView from sliding off the screen
        CGFloat verticalBounds = recognizer.view.center.y + translation.y;
        if( (self.panVelocity.y < 0.0f) && (verticalBounds < kUpperBound)){
            verticalBounds = kUpperBound;//230.0f;
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

- (void)_recognizer:(UIPanGestureRecognizer*)recognizer setsViewPositionY:(CGFloat)yPosition andViewAlpha:(CGFloat)alpha andViewState:(BPContentViewState)viewState {    
    __block CGPoint tempCurrentPosition;
    [UIView animateWithDuration:.3 animations:^{
        [recognizer.view setFrame:CGRectMake(0, yPosition, recognizer.view.frame.size.width, recognizer.view.frame.size.height)];
        [recognizer.view setAlpha:alpha];
        
        // keep track of temporary current position
        tempCurrentPosition = CGPointMake(0, recognizer.view.center.y-(self.frame.size.height/2));
        
        // determine whether to alert the deleage
        if(tempCurrentPosition.y == yPosition){
            [self setContentViewState:viewState];
        }
        
        if([self.delegate respondsToSelector:@selector(contentView:isEnteringState:)])
        {
            [self.delegate contentView:self isEnteringState:viewState];
        }
        
    } completion:^(BOOL finished) {
        
        if([self.delegate respondsToSelector:@selector(contentView:didEnterState:fromState:)] && (self.previewsContentViewState != self.contentViewState))
        {                
            [self.delegate contentView:self didEnterState:self.contentViewState fromState:self.previewsContentViewState];
        }
        if([self.delegate respondsToSelector:@selector(contentView:didEnterState:)])
        {
            [self.delegate contentView:self didEnterState:self.contentViewState];
        }
    }];
}

- (void)enterState:(BPContentViewState)state {
    [self setPreviewsContentViewState:self.contentViewState];
    
    if([self.delegate respondsToSelector:@selector(contentView:willEnterState:)])
    {
        [self.delegate contentView:self willEnterState:state];
    }
    
    switch (state) {
        case kInitialState:
            [self _recognizer:self.panRecognizer setsViewPositionY:kInitialPosition andViewAlpha:1.f andViewState:kInitialState];
            break;
        case kFullState:
            [self _recognizer:self.panRecognizer setsViewPositionY:kFullPosition andViewAlpha:1.f andViewState:kFullState];
            break;
        case kHiddenState:
            [self _recognizer:self.panRecognizer setsViewPositionY:self.hiddenY andViewAlpha:1.f andViewState:kHiddenState];
            break;
    }
}

@end
