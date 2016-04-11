//
//  ChatViewModel.m
//  Spree
//
//  Created by Riley Steele Parsons on 4/10/16.
//  Copyright © 2016 Riley Steele Parsons. All rights reserved.
//

#import "ChatViewModel.h"

@interface ChatViewModel ()

@property (nonatomic, strong) id<SpreeViewModelServices> services;
@property NSString *mailboxId;
@property NSString *threadId;
@property NSString *facebookUserId;
@property NSString *facebookUserName;
@property NSString *sessionToken;
@property NSTimer *typingIndicatorTimer;
@property NSTimer *scrollLockTimer;
@property NSIndexPath *bottomRow;

@end

BOOL sentTypingIndicatorRecently = false;
BOOL lockScrolling = false;
BOOL connecting = false;

@implementation ChatViewModel

-(instancetype)initWithServices:(id<SpreeViewModelServices>)services{
    self = [super init];
    if (self) {
        _services = services;
        [self initialize];
    }
    return self;
}

-(void)initialize {
    
}

@end
