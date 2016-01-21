//
//  SelectPostTypeViewModel.m
//  Spree
//
//  Created by Riley Steele Parsons on 1/20/16.
//  Copyright © 2016 Riley Steele Parsons. All rights reserved.
//

#import "SelectPostTypeViewModel.h"

@interface SelectPostTypeViewModel ()

@property (nonatomic, strong) id<SpreeViewModelServices> services;
@property RACCommand *loadPostTypes;

@end

@implementation SelectPostTypeViewModel

-(instancetype)initWithServices:(id<SpreeViewModelServices>)services{
    self = [super init];
    if (self) {
        _services = services;
        [self initialize];
    }
    return self;
}

-(void)initialize{
    
    self.loadPostTypes = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [self signalForFindPostTypes];
    }];
    
    [[self didBecomeActiveSignal] subscribeNext:^(id x) {
        [self.loadPostTypes execute:nil];
    }];
    
    RAC(self, postTypes) = [[self.loadPostTypes executionSignals] switchToLatest];
    
    // create the tweet selected command, that simply logs
    self.typeSelectedCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(PFObject *selectedType) {
        return [RACSignal return:selectedType];
    }];
    
}

-(RACSignal *)signalForFindPostTypes{
    return [[[self.services getParseConnection] findPostTypes] timeout:10 onScheduler:RACScheduler.scheduler];
}


@end
