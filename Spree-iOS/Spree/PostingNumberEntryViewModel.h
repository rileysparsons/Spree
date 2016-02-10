//
//  PostingNumberEntryViewModel.h
//  Spree
//
//  Created by Riley Steele Parsons on 1/26/16.
//  Copyright © 2016 Riley Steele Parsons. All rights reserved.
//

#import <ReactiveViewModel/ReactiveViewModel.h>
#import "SpreeViewModelServices.h"

@interface PostingNumberEntryViewModel : RVMViewModel

-(instancetype)initWithServices:(id<SpreeViewModelServices>)services field:(NSDictionary *)field;

@property int maxCharacters;
@property int remainingCharacters;
@property NSString *prompt;
@property NSString *enteredString;

@property RACCommand *nextCommand;

@end
