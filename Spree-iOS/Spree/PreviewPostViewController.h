//
//  PreviewPostViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 7/11/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostDetailTableViewController.h"
#import "PreviewPostViewModel.h"

@interface PreviewPostViewController : UITableViewController

@property PreviewPostViewModel *viewModel;

//-(void)initWithPost:(SpreePost *)post workflow:(PostingWorkflowViewModel *)workflow;
//-(void)initWithPost:(SpreePost *)post;
-(NSArray *)sanitizePhotoArray:(NSArray*)photoArray;
-(void)editButtonTouched:(id)sender;

@end
 