//
//  SelectPostSubTypeViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 7/11/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "SelectPostTypeViewController.h"
#import "SpreePost.h"
#import "PostingWorkflow.h"

@interface SelectPostSubTypeViewController : SelectPostTypeViewController

@property SpreePost *post;
@property NSArray *subTypes;
@property NSString *type;
@property PostingWorkflow *workflow;


@end
