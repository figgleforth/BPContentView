//
//  BPViewController.h
//  BPContentView
//
//  Created by Bojan Percevic on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BPContentView.h"

@interface BPViewController : UIViewController <BPContentViewDelegate>

@property BPContentView *contentView;
@property UIButton *changeStateButton;

@end
