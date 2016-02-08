//
//  PostingDateEntryViewModel.h
//  Spree
//
//  Created by Riley Steele Parsons on 2/7/16.
//  Copyright © 2016 Riley Steele Parsons. All rights reserved.
//

#import <ReactiveViewModel/ReactiveViewModel.h>
#import "SpreeViewModelServices.h"

@interface PostingDateEntryViewModel : RVMViewModel

-(instancetype)initWithServices:(id<SpreeViewModelServices>)services field:(NSDictionary *)field;

@property NSDate *enteredDate;
@property NSString *prompt;

@property RACCommand *nextCommand;

@end
