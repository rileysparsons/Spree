//
//  PostTableViewModel.h
//  Spree
//
//  Created by Riley Steele Parsons on 12/17/15.
//  Copyright © 2015 Riley Steele Parsons. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveViewModel/RVMViewModel.h>
#import "SpreeViewModelServices.h"

@interface PostTableViewModel : RVMViewModel

//@property RACCommand* refreshPosts;
@property RACCommand* requestLocationServices;
@property RACCommand* postSelectedCommand;

@property RACSignal* refreshObserver;

@property BOOL isFindingLocation;

@property NSDictionary* queryParameters;
@property BOOL shouldHidePosts;
@property BOOL promptForLocation;
@property BOOL isLoadingPosts;
@property NSString *searchString;
@property NSArray *posts;

-(instancetype)initWithServices: (id<SpreeViewModelServices>)services;
-(instancetype)initWithServices: (id<SpreeViewModelServices>)services Params:(NSDictionary *)params;

@end
