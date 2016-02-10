//
//  SelectPostViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 6/28/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "PostTypeViewController.h"
#import "SelectPostTypeHeaderView.h"
#import "SelectPostTypeViewModel.h"
#import "PostingWorkflowViewModel.h"

@interface SelectPostTypeViewController : UITableViewController

@property SelectPostTypeHeaderView *header;
@property SelectPostTypeViewModel *viewModel;

@end
