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

-(instancetype)initWithServices: (id<SpreeViewModelServices>)services;

@end
