//
//  ChatViewModel.m
//  Spree
//
//  Created by Riley Steele Parsons on 4/10/16.
//  Copyright © 2016 Riley Steele Parsons. All rights reserved.
//

#import "ChatViewModel.h"
#import <SocketRocket/SRWebSocket.h>

@interface ChatViewModel () <SRWebSocketDelegate>

@property SRWebSocket *socket;
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

-(void)reconnect {
    self.socket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"wss://chat.smick.co/socket/"]]];
    self.socket.delegate = self;
}

//-(RACSignal*)didBecomeActiveSignal{
//    
//}

-(void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    
}

@end
