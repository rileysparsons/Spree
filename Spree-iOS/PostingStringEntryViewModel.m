//
//  PostingStringEntryViewModel.m
//  
//
//  Created by Riley Steele Parsons on 1/24/16.
//
//

#import "PostingStringEntryViewModel.h"

@interface PostingStringEntryViewModel ()

@property (nonatomic, strong) id<SpreeViewModelServices> services;
@property PFObject *field;


@end

@implementation PostingStringEntryViewModel

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
    NSLog(@"entered string: %@", self.enteredString);
    self.maxCharacters = [(NSNumber *)self.field[@"characterLimit"] intValue];
    self.remainingCharacters = self.maxCharacters;
    @weakify(self)
    [RACObserve(self, enteredString) subscribeNext:^(NSString *string) {
        @strongify(self)
        self.remainingCharacters = (self.maxCharacters - (int)string.length);
    }];
    
    RACSignal *validStringSignal = [[RACObserve(self, enteredString) map:^id(NSString *text) {
        return @(text.length > 3 && text.length <= self.maxCharacters);
    }] distinctUntilChanged];
    
    self.nextCommand = [[RACCommand alloc] initWithEnabled:validStringSignal signalBlock:^RACSignal *(id input) {
        return [RACSignal return:self.enteredString];
    }];
    
    self.prompt = self.field[@"prompt"];
    NSLog(@"prompt in view model: %@", self.prompt);
}


@end
