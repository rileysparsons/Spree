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
    @weakify(self)
    self.loadPostSubTypes = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self)
        self.isLoading = YES;
        return [self signalForFindPostSubTypesForType:self.type];
    }];

    [[[self.loadPostSubTypes executionSignals] switchToLatest] subscribeNext:^(id x) {
        @strongify(self)
        self.isLoading = NO;
    }];
    
    [[self didBecomeActiveSignal] subscribeNext:^(id x) {
        @strongify(self)
        [self.loadPostSubTypes execute:nil];
    }];
    
    RAC(self, postSubTypes) = [[self.loadPostSubTypes executionSignals] switchToLatest];
    
    // create the tweet selected command, that simply logs
    self.subTypeSelectedCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(PFObject *selectedType) {
        return [RACSignal return:selectedType];
    }];
    
}

-(RACSignal *)signalForFindPostSubTypesForType:(PFObject *)type{
    return [[[self.services getParseConnection] findPostSubTypesForType:type] timeout:10 onScheduler:RACScheduler.scheduler];
}


@end
