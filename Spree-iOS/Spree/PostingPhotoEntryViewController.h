//
//  PostPhotoSelectViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 7/11/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostingWorkflowViewModel.h"
#import "PostingPhotoEntryViewModel.h"
#import "AddPhotoHeaderView.h"

@interface PostingPhotoEntryViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property PostingWorkflowViewModel *postingWorkflow;

@property NSDictionary *fieldDictionary;
@property UIButton *countBarButton;
@property AddPhotoHeaderView *header;
@property PostingPhotoEntryViewModel *viewModel;

-(void)navigationBarButtons;

@end


