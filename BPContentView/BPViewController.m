//
//  BPViewController.m
//  BPContentView
//
//  Created by Bojan Percevic on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BPViewController.h"

@interface BPViewController ()

@end

@implementation BPViewController
@synthesize contentView;
@synthesize myLabel;
@synthesize myButton;

- (id)init {
    self = [super init];
    if(self){
        self.contentView = [[BPContentView alloc] initWithSuperView:self.view andDelegate:self];
        [self.view addSubview:self.contentView];
        
        self.myLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, self.contentView.frame.size.width-20, 34)];
        [self.myLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:self.myLabel];
        
        self.myButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.myButton setFrame:CGRectMake(self.contentView.frame.size.width-130, 10, 120, 30)];
        [self.myButton setTitle:@"Initial State" forState:UIControlStateNormal];
        [self.myButton addTarget:self action:@selector(goToInitialState) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.myButton];
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark myButton Callback
- (void)goToInitialState {
    [self.contentView enterState:kInitialState];
}

#pragma mark BPContentView Delegate
- (void)contentView:(BPContentView *)contentView didEnterState:(BPContentViewState)state {
    switch (state) {
        case kHiddenState:
            [self.contentView setBackgroundColor:[UIColor greenColor]];
            [self.myLabel setText:@"Hidden State"];
            [self.myLabel setTextColor:[UIColor blackColor]];
            break;
            
        case kFullState:
            [self.contentView setBackgroundColor:[UIColor redColor]];
            [self.myLabel setText:@"Full State"];
            [self.myLabel setTextColor:[UIColor whiteColor]];
            break;
            
        case kInitialState:
            [self.contentView setBackgroundColor:[UIColor blueColor]];
            [self.myLabel setText:@"Initial State"];
            [self.myLabel setTextColor:[UIColor whiteColor]];
            break;
    }
}

@end
