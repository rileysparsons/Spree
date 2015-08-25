//
//  PreviewPostViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 7/11/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostDetailTableViewController.h"
#import "PostingWorkflow.h"

@interface PreviewPostViewController : PostDetailTableViewController

@property PostingWorkflow *postingWorkflow;

-(void)initWithPost:(SpreePost *)post workflow:(PostingWorkflow *)workflow;

@end
