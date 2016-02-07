//
//  PostingWorkflow.h
//  Spree
//
//  Created by Riley Steele Parsons on 6/28/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpreeViewModelServices.h"
#import <ReactiveViewModel/RVMViewModel.h>
#import "SpreePost.h"

@interface PostingWorkflowViewModel : RVMViewModel

@property SpreePost *post;
@property NSMutableArray *photosForDisplay;
@property NSMutableArray *uncompletedFields;
@property NSMutableArray *completedFields;

@property (nonatomic, strong) NSMutableArray *viewControllersForPresentation;
@property RACSignal *presentNextViewControllerSignal;

@property int step;

-(instancetype)initWithServices: (id<SpreeViewModelServices>)services;

-(UIViewController *)presentPreviewPostController;


@end
