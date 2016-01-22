//
//  SelectPostSubTypeViewModel.m
//  
//
//  Created by Riley Steele Parsons on 1/21/16.
//
//

#import "SelectPostSubTypeViewModel.h"

@interface SelectPostSubTypeViewModel ()

@property (nonatomic, strong) id<SpreeViewModelServices> services;
@property RACCommand *loadPostSubTypes;
@property PFObject *type;

@end

@implementation SelectPostSubTypeViewModel

-(instancetype)initWithServices:(id<SpreeViewModelServices>)services type:(PFObject *)type{
    self = [super init];
    if (self) {
        _services = services;
        _type = type;
        [self initialize];
    }
    return self;
}

-(void)initialize{
    
    self.loadPostSubTypes = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [self signalForFindPostSubTypesForType:self.type];
    }];
    
    [[self didBecomeActiveSignal] subscribeNext:^(id x) {
        [self.loadPostSubTypes execute:nil];
    }];
    
    RAC(self, postSubTypes) = [[self.loadPostSubTypes executionSignals] switchToLatest];
    
    // create the tweet selected command, that simply logs
    self.typeSelectedCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(PFObject *selectedType) {
        return [RACSignal return:selectedType];
    }];
    
}

-(RACSignal *)signalForFindPostSubTypesForType:(PFObject *)type{
    return [[[self.services getParseConnection] findPostSubTypesForType:type] timeout:10 onScheduler:RACScheduler.scheduler];
}


@end
