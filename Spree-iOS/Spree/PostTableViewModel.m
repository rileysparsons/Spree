//
//  PostTableViewModel.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/17/15.
//  Copyright © 2015 Riley Steele Parsons. All rights reserved.
//

#import "PostTableViewModel.h"
#import "SpreePost.h"
#import <MMPReactiveCoreLocation/MMPReactiveCoreLocation.h>

@interface PostTableViewModel ()

@property (nonatomic, strong) id<SpreeViewModelServices> services;
@property CLLocation *currentLocation;
@property (nonatomic, strong) MMPReactiveCoreLocation *service;
@property CLAuthorizationStatus authStatus;

@property NSArray *keywordArray; // Will map search string into this array from user input.

@end

@implementation PostTableViewModel

-(instancetype)initWithServices:(id<SpreeViewModelServices>)services{
    self = [super init];
    if (self) {
        _services = services;
        [self initialize];
    }
    return self;
}

-(instancetype)initWithServices:(id<SpreeViewModelServices>)services Params:(NSDictionary *)params{
    self = [super init];
    if (self) {
        _services = services;
        _queryParameters = params;
        [self initialize];
    }
    return self;
}


-(void)initialize{
    
    self.posts = [[NSArray alloc] init];
    
    [self initializeLocationService];
    
    @weakify(self);

    self.refreshPosts = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        return [self signalForFindPostsSignalWithLocation:self.currentLocation params:_queryParameters keywords:_keywordArray];
        
    }];
    

    RAC(self, posts) =
    [[[self.refreshPosts executionSignals]
      switchToLatest]
     ignore:nil];
    
    [[[self didBecomeActiveSignal]
    flattenMap:^id(id value) {
        return [[RACObserve(self, currentLocation) ignore:NULL] take:1];
    }] subscribeNext:^(id x) {
        NSLog(@"returned from initial block: %@", x);
        [self.refreshPosts execute:_queryParameters];
    }];
    

    // create the tweet selected command, that simply logs
    self.postSelectedCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(SpreePost *selectedPost) {
        NSLog(@"selected %@", selectedPost.title);
        return [RACSignal return:selectedPost];
    }];
    
    RAC(self, keywordArray) = [RACObserve(self, searchString) map:^id(NSString *string) {
        return [self sanitizeSearchString:string];
    }];
    
}

- (void)initializeLocationService{
    
    self.service = [MMPReactiveCoreLocation service];
    
    RAC(self, currentLocation) = [self locationSignal];
    
    RAC(self, shouldHidePosts) = [[self.service authorizationStatus] map:^id(NSNumber* value) {
        if ([value integerValue] == 2){
            return @YES;
        } else {
            return @NO;
        }
    }];

}

-(RACSignal *)signalForFindPostsSignalWithLocation:(CLLocation *)location params:(NSDictionary *)params keywords:(NSArray *)keywords{
    return [[[self.services getParseConnection] findPostsSignalWithLocation:location params:params keywords:keywords] timeout:10 onScheduler:RACScheduler.scheduler];
}

- (RACSignal *)requestLocationAuthSignal {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        [[[self.service authorizeWhenInUse] authorize] subscribeNext:^(id x) {
            [subscriber sendNext:x];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

- (RACSignal *)locationSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[_service locations] subscribeNext:^(id x) {
            [subscriber sendNext:x];
        }];
        return nil;
    }];
}

#pragma mark - Search Functions

//if (self.searchQuery){
//    [self.searchQuery cancel];
//}
//self.searchQuery = [PFQuery queryWithClassName:@"Post"];
//[self.searchQuery whereKeyExists:@"title"];  //this is based on whatever query you are trying to accomplish
//[self.searchQuery whereKeyExists:@"price"]; //this is based on whatever query you are trying to accomplish
//[self.searchQuery whereKey:@"typePointer" equalTo:self.postType];
//
//NSMutableArray *parts = [NSMutableArray arrayWithArray:[searchTerm componentsSeparatedByCharactersInSet:[NSCharacterSet  whitespaceCharacterSet]]];
//[parts removeObjectIdenticalTo:@""];
//
//NSLog(@"Parts %@", parts);
//
//NSArray *lowercaseTerms = [parts valueForKey:@"lowercaseString"];
//
//[self.searchQuery whereKey:@"keywords" containsAllObjectsInArray:lowercaseTerms];
//
//[self.searchQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
//    if (!error){
//        NSLog(@"%@", objects);
//        NSLog(@"%lu", (unsigned long)objects.count);
//        [self.searchResults removeAllObjects];
//        [self.searchResults addObjectsFromArray:objects];
//        // hand over the filtered results to our search results table
//        ResultsTableViewController *tableController = (ResultsTableViewController *)self.searchController.searchResultsController;
//        tableController.filteredProducts = self.searchResults;
//        [tableController.postsTableView reloadData];
//        self.searchQuery = nil;
//    }
//}];

-(NSArray *)sanitizeSearchString:(NSString *)string {
    NSMutableArray *parts = [NSMutableArray arrayWithArray:[string componentsSeparatedByCharactersInSet:[NSCharacterSet  whitespaceCharacterSet]]];
    [parts removeObjectIdenticalTo:@""];
    
    NSLog(@"Parts for search: %@", parts);
    
    NSArray *lowercaseTerms = [parts valueForKey:@"lowercaseString"];
    
    return lowercaseTerms;
}

@end
