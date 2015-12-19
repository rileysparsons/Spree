//
//  PostTableViewModel.h
//  Spree
//
//  Created by Riley Steele Parsons on 12/17/15.
//  Copyright © 2015 Riley Steele Parsons. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpreeViewModelServices.h"

@interface PostTableViewModel : NSObject

@property RACCommand* refreshPosts;
@property RACCommand* requestLocationServices;
@property NSArray *posts;
@property BOOL locationServicesAuthorized;

-(instancetype)initWithServices: (id<SpreeViewModelServices>)services;

@end
