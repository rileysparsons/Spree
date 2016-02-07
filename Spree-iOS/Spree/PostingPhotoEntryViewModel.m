//
//  PostingPhotoEntryViewModel.m
//  Spree
//
//  Created by Riley Steele Parsons on 1/30/16.
//  Copyright © 2016 Riley Steele Parsons. All rights reserved.
//

#import "PostingPhotoEntryViewModel.h"

@interface PostingPhotoEntryViewModel () <CEObservableMutableArrayDelegate>

@property (nonatomic, strong) id<SpreeViewModelServices> services;
@property BOOL nextEnabled;

@end

@implementation PostingPhotoEntryViewModel

-(instancetype)initWithServices:(id<SpreeViewModelServices>)services{
    self = [super init];
    if (self) {
        _services = services;
        [self initialize];
    }
    return self;
}

-(void)initialize {
    self.prompt = @"Add a couple photos";
 
    self.maxPhotos = 3;
    self.remainingPhotos = self.maxPhotos;
    self.files = [[CEObservableMutableArray alloc] init];
    
    self.files.delegate = self;
    
    NSLog(@"%@", self.files.delegate);
    
    self.nextCommand = [[RACCommand alloc] initWithEnabled:RACObserve(self, nextEnabled) signalBlock:^RACSignal *(id input) {
        return [RACSignal return:self.files];
    }];
    
    self.photoSelected = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        NSLog(@"%@", input);
        return nil;
    }];
    
    self.deletePhoto = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSNumber* input) {
        [self.files removeObjectAtIndex:[input integerValue]];
        return [RACSignal return:nil];
    }];
    
    self.tableViewNeedsUpdateCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal return:nil];
    }];
}

-(void)array:(CEObservableMutableArray *)array didAddItemAtIndex:(NSUInteger)index{
    if (array.count > 0 && array.count < 4){
        self.nextEnabled = YES;
    } else {
        self.nextEnabled = NO;
    }
    [self.tableViewNeedsUpdateCommand execute:nil];
}

-(void)array:(CEObservableMutableArray *)array didRemoveItemAtIndex:(NSUInteger)index{
    if (array.count > 0 && array.count < 4){
        self.nextEnabled = YES;
    } else {
        
        self.nextEnabled = NO;
    }
    [self.tableViewNeedsUpdateCommand execute:nil];
}


@end
