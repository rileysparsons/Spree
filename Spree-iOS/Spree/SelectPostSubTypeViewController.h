//
//  SelectPostSubTypeViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 7/11/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "SelectPostTypeViewController.h"
#import "SelectPostSubTypeViewModel.h"
#import "SpreePost.h"

@interface SelectPostSubTypeViewController : UITableViewController

@property SelectPostTypeHeaderView *header;
@property SelectPostSubTypeViewModel *viewModel;

@end
