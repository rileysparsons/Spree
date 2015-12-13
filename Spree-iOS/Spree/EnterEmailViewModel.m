//
//  EnterEmailViewModel.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/12/15.
//  Copyright © 2015 Riley Steele Parsons. All rights reserved.
//

#import "EnterEmailViewModel.h"

@interface EnterEmailViewModel ()

@property (nonatomic, weak) id<SpreeViewModelServices> services;

@end

@implementation EnterEmailViewModel

-(instancetype)initWithServices:(id<SpreeViewModelServices>)services{
    self = [super init];
    if (self) {
        _services = services;
        [self initialize];
    }
    return self;
}

-(void)initialize{
    
    RACSignal *validEmailEntered = [[RACObserve(self, email) map:^id(NSString *text) {
        NSLog(@"%lu", (unsigned long)text.length);
        return @(text.length > 3);
    }] distinctUntilChanged];
    
    self.checkForExistingUser = [[RACCommand alloc] initWithEnabled:validEmailEntered signalBlock:^RACSignal *(id input) {
        return [self checkForExistingUserSignal];
    }];
}

-(RACSignal *)checkForExistingUserSignal {
    NSString *fullEmail = [NSString stringWithFormat:@"%@@scu.edu", self.email];
    return [[self.services getParseConnection] checkIfUserWithEmailExists:fullEmail];
}

@end
