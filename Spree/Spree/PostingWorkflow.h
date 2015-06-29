//
//  PostingWorkflow.h
//  Spree
//
//  Created by Riley Steele Parsons on 6/28/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostingWorkflow : NSObject

@property PFObject *post;

-(UIViewController *)nextViewController;
-(id)initWithType:(PFObject *)type;

@end
