//
//  PostingDateEntryViewModel.m
//  Spree
//
//  Created by Riley Steele Parsons on 2/7/16.
//  Copyright © 2016 Riley Steele Parsons. All rights reserved.
//

#import "PostingDateEntryViewModel.h"

@interface PostingDateEntryViewModel ()

@property id<SpreeViewModelServices> services;
@property PFObject *field;

@end

@implementation PostingDateEntryViewModel

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
    @weakify(self)
    self.nextCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self)
        return [RACSignal return:self.enteredDate];
    }];
    
    self.prompt = self.field[@"prompt"];
}


@end
