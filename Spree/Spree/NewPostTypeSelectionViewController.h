//
//  NewPostTypeSelectionViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 3/8/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "SpreePost.h"

@interface NewPostTypeSelectionViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *typeTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBarButtonItem;
@property SpreePost *post;

- (IBAction)cancelBarButtonItemPressed:(id)sender;

@end
