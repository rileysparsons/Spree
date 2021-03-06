//
//  PostTableViewModel.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/17/15.
//  Copyright © 2015 Riley Steele Parsons. All rights reserved.
//

#import "PostTableViewModel.h"
#import "SpreePost.h"
#import "SpreeMarketManager.h"
#import <MMPReactiveCoreLocation/MMPReactiveCoreLocation.h>

#define read_permission_bay_area @"read_permission_bay_area"
#define order_permission_santa_clara @"order_permission_santa_clara"
#define post_permission_santa_clara @"post_permission_santa_clara"

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
     @weakify(self);
    
    self.posts = [[NSArray alloc] init];
    
    self.refreshObserver = [[RACSubject subject] setNameWithFormat:@"PostTableViewModel refreshPostsSignal"];
    
    [[[[self.refreshObserver doNext:^(id x) {
        @strongify(self)
        self.isLoadingPosts = YES;
    }] flattenMap:^RACStream *(id value) {
        @strongify(self)
        return [self signalForFindPostsWithRegion:[[SpreeMarketManager sharedManager] readRegionFromLocation:self.currentLocation] params:_queryParameters keywords:_keywordArray];
    }] doNext:^(id x) {
        @strongify(self)
        self.isLoadingPosts = NO;
    }] subscribeNext:^(NSArray* posts) {
        @strongify(self)
        self.posts = posts;
    }];
 
    [RACObserve(self, promptForLocation) subscribeNext:^(id x) {
        @strongify(self)
        if ([x integerValue])
            self.shouldHidePosts = NO;
    }];
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        @strongify(self)
        self.promptForLocation = YES;
    } else {
        @strongify(self)
        self.isFindingLocation = YES;
        [self initializeLocationService];
    }

    /*
    self.refreshPosts = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        return [[self signalForFindPostsWithRegion:[[SpreeMarketManager sharedManager] readRegionFromLocation:self.currentLocation] params:_queryParameters keywords:_keywordArray] doCompleted:^{
            self.isLoadingPosts = NO;
        }];
    }];
     */
    
    self.requestLocationServices = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        [self initializeLocationService];
        return [RACSignal return:nil];
    }];
    

//    RAC(self, posts) = [[self.refreshPosts executionSignals] switchToLatest];
    
   [[[[[RACObserve(self, currentLocation) ignore:NULL] take:1] timeout:10.0f onScheduler:[RACScheduler scheduler]]
    filter:^BOOL(id value) {
        @strongify(self)
        return !self.isLoadingPosts;
    }] subscribeNext:^(id x) {
        NSLog(@"returned from initial block: %@", x);
        @strongify(self)
        [(RACSubject *)self.refreshObserver sendNext:nil];
        self.isFindingLocation = NO;
    } error:^(NSError *error) {
        @strongify(self)
        self.isFindingLocation = NO;
    }];

    // create the tweet selected command, that simply logs
    self.postSelectedCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(SpreePost *selectedPost) {
        NSLog(@"selected %@", selectedPost.title);
        return [RACSignal return:selectedPost];
    }];
    

    RAC(self, keywordArray) = [RACObserve(self, searchString) map:^id(NSString *string) {
        @strongify(self)
        return [self sanitizeSearchString:string];
    }];
    
}

- (void)initializeLocationService{
    
    self.service = [MMPReactiveCoreLocation service];

    
    RAC(self, currentLocation) = [self locationSignal];
    
    /*
    @weakify(self)
    [[self.service authorizationStatus] subscribeNext:^(NSNumber* newAuthStatus) {
        @strongify(self)
        if ([newAuthStatus integerValue] == kCLAuthorizationStatusDenied){
            self.posts = nil;
        } else {
            [[[[[RACObserve(self, currentLocation) ignore:NULL] take:1] timeout:10.0f onScheduler:[RACScheduler scheduler]]
              filter:^BOOL(id value) {
                  return [[self.refreshPosts executing] not];
              }] subscribeNext:^(id x) {
                  @strongify(self)
                  self.isFindingLocation = NO;
                  [self.refreshPosts execute:_queryParameters];
              } error:^(NSError *error) {
                  self.isFindingLocation = NO;
              }];
        }
    }];
     */
    
    RAC(self, shouldHidePosts) = [RACSignal combineLatest:@[RACObserve(self, currentLocation), [self.service authorizationStatus]] reduce:^id(CLLocation *location, NSNumber *number){
        return @(location == nil || [number integerValue] == 2);
    }];
    
    [[[[RACSignal combineLatest:@[RACObserve(self, currentLocation), [self.service authorizationStatus]] reduce:^id(CLLocation *location, NSNumber *number){
        self.promptForLocation = NO;
        return @(location == nil || [number integerValue] == 2);
    }] ignore:@NO] take:1] subscribeNext:^(id x) {
        [(RACSubject *)self.refreshObserver sendNext:nil];
    }];
}


-(RACSignal *)signalForFindPostsWithRegion:(CLCircularRegion *)region params:(NSDictionary *)params keywords:(NSArray *)keywords{
    self.isLoadingPosts = YES;
    return [[self.services getParseConnection] findPostsSignalWithRegion:region params:params keywords:keywords];
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
