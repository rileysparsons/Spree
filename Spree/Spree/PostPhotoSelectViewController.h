//
//  PostPhotoSelectViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 7/11/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostingWorkflow.h"
#import "AddPhotoHeaderView.h"

@interface PostPhotoSelectViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property PostingWorkflow *postingWorkflow;
@property NSMutableArray *photoArray;
@property NSMutableArray *fileArray;
@property UIButton *countBarButton;
@property AddPhotoHeaderView *header;


-(void)navigationBarButtons;

@end


