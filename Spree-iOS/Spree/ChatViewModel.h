//
//  ChatViewModel.h
//  Spree
//
//  Created by Riley Steele Parsons on 4/10/16.
//  Copyright © 2016 Riley Steele Parsons. All rights reserved.
//

#import <ReactiveViewModel/ReactiveViewModel.h>
#import "SpreeViewModelServices.h"

@interface ChatViewModel : RVMViewModel

-(instancetype)initWithServices: (id<SpreeViewModelServices>)services;

@property RACCommand *sendMessageCommand;
@property NSArray *messages;
@property NSString *typedText;

@end
