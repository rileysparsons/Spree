//
//  SelectPostTypeViewModel.h
//  Spree
//
//  Created by Riley Steele Parsons on 1/20/16.
//  Copyright © 2016 Riley Steele Parsons. All rights reserved.
//

#import <ReactiveViewModel/RVMViewModel.h>
#import "SpreeViewModelServices.h"

@interface SelectPostTypeViewModel : RVMViewModel

@property RACCommand* typeSelectedCommand;
@property PFObject *postTypes;

-(instancetype)initWithServices:(id<SpreeViewModelServices>)services;

@end
