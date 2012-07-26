//
//  BPViewController.m
//  BPContentView
//
//  Created by Bojan Percevic on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BPViewController.h"

@implementation BPViewController

- (id)init {
    self = [super init];
    if(self){
        self.contentView = [[BPContentView alloc] initWithDelegate:self superView:self.view];
        [self.view addSubview:self.contentView];
                        
        self.changeStateButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.changeStateButton setTitle:@"Go Hidden" forState:UIControlStateNormal];
        [self.changeStateButton addTarget:self action:@selector(changeState:) forControlEvents:UIControlEventTouchUpInside];
        [self.changeStateButton setFrame:CGRectMake(5, 5, 120, 39)];
        [self.contentView addSubview:self.changeStateButton];
        
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark myButton Callback
- (void)changeState:(UIButton*)sender {
    switch (self.contentView.currentState) {
        case BPContentViewStateInitial:
            [self.contentView setState:BPContentViewStateHidden];
            break;
        case BPContentViewStateFull:
            [self.contentView setState:BPContentViewStateHidden];
            break;
        case BPContentViewStateHidden:
            [self.contentView setState:BPContentViewStateFull];
            break;
    }
}

#pragma mark BPContentView Delegate
- (void)contentView:(BPContentView *)contentView didEnterState:(BPContentViewState)state {
    switch (state) {
        case BPContentViewStateHidden:
            [self.changeStateButton setTitle:@"Go Full" forState:UIControlStateNormal];
            break;
            
        case BPContentViewStateFull:
            [self.changeStateButton setTitle:@"Go Hidden" forState:UIControlStateNormal];
            break;
            
        case BPContentViewStateInitial:
            break;
    }
}

@end
