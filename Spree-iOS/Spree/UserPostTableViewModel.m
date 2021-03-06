//
//  UserPostTableViewModel.m
//  Spree
//
//  Created by Riley Steele Parsons on 2/10/16.
//  Copyright © 2016 Riley Steele Parsons. All rights reserved.
//

#import "UserPostTableViewModel.h"
#import "SpreePost.h"

@interface UserPostTableViewModel ()

@property (nonatomic, strong) id<SpreeViewModelServices> services;
@property PFUser *user;

@end

@implementation UserPostTableViewModel

-(instancetype)initWithServices:(id<SpreeViewModelServices>)services{
    self = [super init];
    if (self) {
        _services = services;
        [self initialize];
    }
    return self;
}

-(instancetype)initWithServices:(id<SpreeViewModelServices>)services user:(PFUser *)user params:(NSDictionary *)params{
    self = [super init];
    if (self) {
        _services = services;
        _user = user;
        self.queryParameters = params;
        [self initialize];
    }
    return self;
}

-(void)initialize{

    @weakify(self);
    
    self.refreshObserver = [[RACSubject subject] setNameWithFormat:@"UserPostsTableViewModel refreshPostsSignal"];
    
    [[[[self.refreshObserver doNext:^(id x) {
        self.isLoadingPosts = YES;
    }] flattenMap:^RACStream *(id value) {
        @strongify(self);
        return [self signalForFindPostsForUser:self.user params:self.queryParameters];
    }] doNext:^(id x) {
        self.isLoadingPosts = NO;
    }] subscribeNext:^(NSArray* posts) {
        self.posts = posts;
    }];
    
    self.postSelectedCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(SpreePost *selectedPost) {
        NSLog(@"selected %@", selectedPost.title);
        return [RACSignal return:selectedPost];
    }];
    
}

-(RACSignal *)signalForFindPostsForUser:(PFUser *)user params:(NSDictionary *)params {
    self.isLoadingPosts = YES;
    return [[[self.services getParseConnection] findPostsSignalWithUser:user params:params] timeout:10 onScheduler:RACScheduler.scheduler];
}

@end
