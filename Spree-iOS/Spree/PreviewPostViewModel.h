//
//  PreviewPostViewModel.h
//  Spree
//
//  Created by Riley Steele Parsons on 2/7/16.
//  Copyright © 2016 Riley Steele Parsons. All rights reserved.
//

#import <ReactiveViewModel/ReactiveViewModel.h>
#import "SpreeViewModelServices.h"
#import "SpreePost.h"

@interface PreviewPostViewModel : RVMViewModel

-(instancetype)initWithServices:(id<SpreeViewModelServices>)services post:(SpreePost *)post;

@property SpreePost *post;
@property NSArray *existingFieldsToShow;
@property UITableView *tableView;
@property BOOL isPosting;

@property RACCommand *editFieldCommand;
@property RACCommand *fieldWasEditedCommand;
@property RACCommand *completePostCommand;

@end

