//
//  PostingWorkflow.h
//  Spree
//
//  Created by Riley Steele Parsons on 6/28/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpreePost.h"

@interface PostingWorkflow : NSObject

@property SpreePost *post;
@property NSMutableArray *photosForDisplay;
@property NSMutableArray *uncompletedFields;
@property NSMutableArray *completedFields;
@property (retain, nonatomic) PFObject* type;
@property (retain, nonatomic) PFObject* subtype;
@property int step;

-(UIViewController *)nextViewController;
-(id)initWithType:(PFObject *)type;
-(id)initWithPost:(SpreePost *)post;
-(UIViewController *)presentPreviewPostController;


@end