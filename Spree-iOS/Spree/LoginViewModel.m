//
//  EnterEmailViewModel.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/12/15.
//  Copyright © 2015 Riley Steele Parsons. All rights reserved.
//

#import "LoginViewModel.h"

@interface LoginViewModel ()

@property (nonatomic, weak) id<SpreeViewModelServices> services;

@end

@implementation LoginViewModel

-(instancetype)initWithServices:(id<SpreeViewModelServices>)services{
    self = [super init];
    if (self) {
        _services = services;
        [self initialize];
    }
    return self;
}

-(void)initialize{
    
    self.loginWithFacebook = [[RACCommand alloc] initWithEnabled:nil signalBlock:^RACSignal *(id input) {
        return [self loginWithFacebookSignal];
    }];
    
}

-(RACSignal *)loginWithFacebookSignal {
    return [[self.services getParseConnection] loginWithFacebook];
}

@end
