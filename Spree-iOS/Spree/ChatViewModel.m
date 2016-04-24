//
//  ChatViewModel.m
//  Spree
//
//  Created by Riley Steele Parsons on 4/10/16.
//  Copyright © 2016 Riley Steele Parsons. All rights reserved.
//

#import "ChatViewModel.h"
#import <jetfire/JFRWebSocket.h>
#import <AFNetworking/AFNetworking.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface ChatViewModel () 
@property JFRWebSocket *socket;
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
    
    self.mailboxId = @"";
    self.threadId = @"";
    self.sessionToken = @"";
    
    [self.didBecomeActiveSignal subscribeNext:^(id x) {
        if (!self.socket.isConnected){
            [self attemptConnection];
        }
        
        [self requestFacebookProfile];
    }];
    
    [self.didBecomeInactiveSignal subscribeNext:^(id x) {
        if (self.socket.isConnected){
            [self.socket disconnect];
        }
    }];
    
    self.sendMessageCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSString* input) {
        [self sendMessage:self.typedText];
        return [RACSignal return:nil];
    }];
    
}

-(void) requestFacebookProfile{
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me?fields=id,name" parameters:nil];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (error != nil) {
            NSLog(@"FB Failure");
            return;
        }
        
        NSDictionary *respDict = result;
        
        if (respDict){
            NSLog(@"%@", respDict);
            self.facebookUserId = respDict[@"id"];
            self.facebookUserName = respDict[@"name"];
        }
    }];
    
}


-(void)attemptConnection{
    NSURL *URL = [NSURL URLWithString:@"https://www.smick.tv/auth/smickchat"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:URL.absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        if (responseObject){
            self.mailboxId = responseObject[@"mailbox_id"];
            self.threadId = responseObject[@"thread_id"];
            self.sessionToken = responseObject[@"session_token"];
            
            [self connectToHearstWithMailboxId:self.mailboxId threadId:self.threadId sessionToken:self.sessionToken];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Attempt connection failed. Error: %@", error);
    }];
}

-(void)connectToHearstWithMailboxId:(NSString *)mailboxId threadId:(NSString *)threadId sessionToken:(NSString *)sessionToken {
    self.socket = [[JFRWebSocket alloc] initWithURL:[NSURL URLWithString:@"wss://chat.smick.co/socket/"] protocols:nil];

    [self.socket addHeader:mailboxId forKey:@"X-Hearst-Mailbox"];
    [self.socket addHeader:sessionToken forKey:@"X-Hearst-Session"];

    @weakify(self)
    self.socket.onConnect = ^{
        
        NSString *jsonString = [NSString stringWithFormat:@"{\"model\" : \"thread\", \"action\" : \"list\", \"follow\" : \"true\", \"history_topic\" : \"chat-message\", \"limit\" : \"100\", \"thread_id\" : \"%@\"}", threadId];
        
        @strongify(self)
        [self.socket writeString:jsonString];
        NSLog(@"Websocket is connected %@", jsonString);
    };
    
    self.socket.onText = ^(NSString *text){
        NSData *jsonData = [text dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"json: %@", json);
        
        BOOL isFirstLoad = (self.messages.count == 0);
        BOOL actualMessageAdded = FALSE;
        
        for (NSDictionary *val in json){
            NSLog(@"val: %@", val);
        }
        
    };
    
    self.socket.onDisconnect = ^(NSError * error){
        NSLog(@"Websocket is Disconnected %@", error.localizedDescription);
    };
    
    [self.socket connect];
    
}

-(void)sendMessage:(NSString *)message{
    sentTypingIndicatorRecently = FALSE;
    
    NSDictionary *insertRequest = @{@"model":@"message", @"action":@"request"};
    NSDictionary* messageDescription = @{
                              @"ThreadId" : self.threadId,
                              @"SenderMailboxId" : self.mailboxId,
                              @"Body" : message,
                              @"Labels" : @{@"SenderFacebookName" : self.facebookUserName,@"SenderFacebookId" : self.facebookUserId},
                              @"Payload" : @[],
                              @"Topic" : @"chat-message"
                              };
    
    
    NSError *error;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:insertRequest options:NSJSONWritingPrettyPrinted error:&error];
    
    NSData * messageData = [NSJSONSerialization dataWithJSONObject:messageDescription options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString* requestString = [requestData base64EncodedStringWithOptions:NSUTF8StringEncoding];
    NSString* messageString = [messageData base64EncodedStringWithOptions:NSUTF8StringEncoding];
    if (requestString != nil && messageString != nil) {
        [self.socket writeString:requestString];
        [self.socket writeString:messageString];
    }
    
}

@end
