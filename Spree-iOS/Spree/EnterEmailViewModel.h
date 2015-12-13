//
//  EnterEmailViewModel.h
//  Spree
//
//  Created by Riley Steele Parsons on 12/12/15.
//  Copyright © 2015 Riley Steele Parsons. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpreeViewModelServices.h"

@interface EnterEmailViewModel : NSObject

@property RACCommand *checkForExistingUser;
@property NSString *email;
@property BOOL userExists;

-(instancetype)initWithServices: (id<SpreeViewModelServices>)services;

@end
