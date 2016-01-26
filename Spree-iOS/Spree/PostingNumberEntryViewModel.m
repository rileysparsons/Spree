//
//  PostingNumberEntryViewModel.m
//  Spree
//
//  Created by Riley Steele Parsons on 1/26/16.
//  Copyright © 2016 Riley Steele Parsons. All rights reserved.
//

#import "PostingNumberEntryViewModel.h"

@interface PostingNumberEntryViewModel ()

@property (nonatomic, strong) id<SpreeViewModelServices> services;
@property PFObject *field;

@end

@implementation PostingNumberEntryViewModel

-(instancetype)initWithServices:(id<SpreeViewModelServices>)services field:(PFObject *)field{
    self = [super init];
    if (self) {
        _services = services;
        _field = field;
        [self initialize];
    }
    return self;
}

-(void)initialize {
    
    RACSignal *validStringSignal = [[RACObserve(self, enteredString) map:^id(NSString *text) {
        return @(text.length > 0);
    }] distinctUntilChanged];
    
    self.nextCommand = [[RACCommand alloc] initWithEnabled:validStringSignal signalBlock:^RACSignal *(NSString* inputString) {
        return [RACSignal return:[self getNumberFromString:self.enteredString]];
    }];
    
    self.prompt = self.field[@"prompt"];
    
}

- (NSNumber *)getNumberFromString:(NSString *)number{
    if ([number length] == 0) {
        return 0;
    }
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterNoStyle;
    NSNumber *formattedNumber = [formatter numberFromString:number];
    return formattedNumber;
}

@end
