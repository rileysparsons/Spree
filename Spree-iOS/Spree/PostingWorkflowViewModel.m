//
//  PostingWorkflow.m
//  Spree
//
//  Created by Riley Steele Parsons on 6/28/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "PostingWorkflowViewModel.h"
#import "PostingStringEntryViewController.h"
#import "PreviewPostViewController.h"
#import "PostingPhotoEntryViewController.h"
#import "PostingNumberEntryViewController.h"
#import "PostingDateEntryViewController.h"
#import "PostingStringEntryViewModel.h"

#import "PostingPhotoEntryViewModel.h"

#import "PostingNumberEntryViewModel.h"
#import "PostingNumberEntryViewController.h"

#import "SelectPostTypeViewController.h"
#import "SelectPostSubTypeViewController.h"
#import "SelectPostSubTypeViewModel.h"
#import "SelectPostTypeViewModel.h"
#import "SpreeViewModelServicesImpl.h"
#import <MBProgressHUD/MBProgressHUD.h>

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <MMPReactiveCoreLocation/MMPReactiveCoreLocation.h>


@interface PostingWorkflowViewModel (){

}

@property (nonatomic, strong) id<SpreeViewModelServices> services;
@property NSMutableArray *allFields;
@property (nonatomic)  NSArray* viewControllersForFields;
@property (nonatomic, strong) MMPReactiveCoreLocation *locationService;

@end

@implementation PostingWorkflowViewModel

-(instancetype)initWithServices:(id<SpreeViewModelServices>)services{
    self = [super init];
    if (self) {
        _services = services;
        [self initialize];
    }
    return self;
}

-(void)initialize{
    
    self.step = 0;
    
    self.post = [SpreePost new];
    
    [self.post setExpired:NO];
    [self.post setSold:NO];
    self.post[@"expirationDate"] = [[NSDate date] dateByAddingTimeInterval:864000];
    self.post.user = [PFUser currentUser];
    
    self.post[@"completedFields"] = [[NSArray alloc] init];
    
    self.locationService = [MMPReactiveCoreLocation service];
    
    @weakify(self)
    [self.locationService.location subscribeNext:^(id x) {
        @strongify(self)
        self.post[@"location"] = [PFGeoPoint geoPointWithLocation:x];
    }];
    
    self.allFields = [[NSMutableArray alloc] init];
    self.completedFields = [[NSMutableArray alloc] init];
    self.uncompletedFields = [[NSMutableArray alloc] init];
    self.photosForDisplay = [[NSMutableArray alloc] init];
    
    [RACObserve(self.post, typePointer) map:^id(id value) {
        @strongify(self)
        for (id field in value[@"fields"]){
            [self.uncompletedFields addObject:field];
            self.allFields = self.uncompletedFields;
        }
        return nil;
    }];
    
    self.endPostingWorkflowCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal return:nil];
    }];
    
    self.viewControllersForPresentation = [[NSMutableArray alloc] init];
    [self.viewControllersForPresentation addObject:[self selectPostTypeViewController]];
    
    self.presentNextViewControllerSignal = [[RACSubject subject] setNameWithFormat:@"PostingWorkflowViewModel presentNextViewControllerSignal"];
}


-(PreviewPostViewController *)presentPreviewPostController{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewPost" bundle:nil];
    PreviewPostViewController *previewPostViewController = [storyboard instantiateViewControllerWithIdentifier:@"PreviewPostViewController"];
    NSMutableArray *previewFields = [[NSMutableArray alloc] init];
    
    for (id field in self.allFields){
        [previewFields addObject:field[@"field"]];
    }
    SpreeViewModelServicesImpl *viewModelServices = [[SpreeViewModelServicesImpl alloc] init];
    PreviewPostViewModel *previewPostViewModel = [[PreviewPostViewModel alloc] initWithServices:viewModelServices post:self.post];
    previewPostViewController.viewModel = previewPostViewModel;
    
    MBProgressHUD *progressHUD = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
    progressHUD.labelText = @"Saving Post...";
    [[UIApplication sharedApplication].keyWindow addSubview:progressHUD];
    
    @weakify(self)
    
    [[[previewPostViewController.viewModel.confirmLocationCommand.executionSignals switchToLatest] flattenMap:^RACStream *(id value) {
        @strongify(self)
        [progressHUD show:YES];
        return [self signalForCompletingPost:self.post];
    }] subscribeNext:^(id x) {
        @strongify(self)
        [progressHUD hide:YES afterDelay:0.5];
        [self.endPostingWorkflowCommand execute:nil];
    }];
    
    return previewPostViewController;
}

-(SelectPostTypeViewController *)selectPostTypeViewController{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewPost" bundle:[NSBundle mainBundle]];
    SelectPostTypeViewController* selectPostTypeViewController = [storyboard instantiateViewControllerWithIdentifier:@"SelectPostTypeViewController"];
    SpreeViewModelServicesImpl *viewModelServices = [[SpreeViewModelServicesImpl alloc] init];
    SelectPostTypeViewModel *selectPostTypeViewModel = [[SelectPostTypeViewModel alloc] initWithServices:viewModelServices];
    selectPostTypeViewController.viewModel = selectPostTypeViewModel;
    @weakify(self)
    [[[selectPostTypeViewModel.typeSelectedCommand executionSignals] switchToLatest] subscribeNext:^(id x) {
        @strongify(self)
        self.step++;
        self.post[@"typePointer"] = x;
        [self.viewControllersForPresentation addObject:[self selectPostSubTypeViewControllerForType:x]];
        [self shouldPresentNextViewInWorkflow];
    }];
    return selectPostTypeViewController;
}

-(SelectPostSubTypeViewController *)selectPostSubTypeViewControllerForType:(PFObject *)type{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewPost" bundle:[NSBundle mainBundle]];
    SelectPostSubTypeViewController *selectPostSubTypeViewController = [storyboard instantiateViewControllerWithIdentifier:@"SelectPostSubTypeViewController"];
    SpreeViewModelServicesImpl *viewModelServices = [[SpreeViewModelServicesImpl alloc] init];
    SelectPostSubTypeViewModel *selectPostSubTypeViewModel = [[SelectPostSubTypeViewModel alloc] initWithServices:viewModelServices type:type];
    selectPostSubTypeViewController.viewModel = selectPostSubTypeViewModel;
    @weakify(self)
    [[[selectPostSubTypeViewModel.subTypeSelectedCommand executionSignals] switchToLatest] subscribeNext:^(id x) {
        @strongify(self)
        self.step++;
        self.post[@"subtype"] = x;
        [self updateViewControllersForPresentationForType:self.post[@"typePointer"] subType:self.post[@"subtype"]];
        [self shouldPresentNextViewInWorkflow];
    }];
    return selectPostSubTypeViewController;
}

-(PostingStringEntryViewController *)postingStringEntryViewControllerForField:(NSDictionary *)field{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewPost" bundle:[NSBundle mainBundle]];
    PostingStringEntryViewController *postingStringEntryViewController = [storyboard instantiateViewControllerWithIdentifier:@"PostFieldViewController"];
    SpreeViewModelServicesImpl *viewModelServices = [[SpreeViewModelServicesImpl alloc] init];
    PostingStringEntryViewModel *postingStringEntryViewModel = [[PostingStringEntryViewModel alloc] initWithServices:viewModelServices field:field];
    postingStringEntryViewController.viewModel = postingStringEntryViewModel;
    @weakify(self)
    [[[postingStringEntryViewModel.nextCommand executionSignals] switchToLatest] subscribeNext:^(NSString *string) {
        @strongify(self)
        self.step++;
        [self.post setObject:string forKey:(NSString *)field[@"field"]];
        NSMutableArray *completedFields = [[NSMutableArray alloc] initWithArray:[self.post objectForKey:@"completedFields"]];
        [completedFields addObject:field];
        self.post[@"completedFields"] = (NSArray *)completedFields;
        [self shouldPresentNextViewInWorkflow];
    }];
    return postingStringEntryViewController;
}

-(PostingNumberEntryViewController *)postingNumberEntryViewControllerForField:(NSDictionary *)field{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewPost" bundle:[NSBundle mainBundle]];
    PostingNumberEntryViewController *postingNumberEntryViewController = [storyboard instantiateViewControllerWithIdentifier:@"PostingNumberEntryViewController"];
    SpreeViewModelServicesImpl *viewModelServices = [[SpreeViewModelServicesImpl alloc] init];
    PostingNumberEntryViewModel *postingNumberEntryViewModel = [[PostingNumberEntryViewModel alloc] initWithServices:viewModelServices field:field];
    postingNumberEntryViewController.viewModel = postingNumberEntryViewModel;
    @weakify(self)
    [[[postingNumberEntryViewModel.nextCommand executionSignals] switchToLatest] subscribeNext:^(NSString *string) {
        @strongify(self)
        self.step++;
        [self.post setObject:string forKey:(NSString *)field[@"field"]];
        NSMutableArray *completedFields = [[NSMutableArray alloc] initWithArray:[self.post objectForKey:@"completedFields"]];
        [completedFields addObject:field];
        self.post[@"completedFields"] = (NSArray *)completedFields;
        [self shouldPresentNextViewInWorkflow];
    }];
    return postingNumberEntryViewController;
}

-(PostingDateEntryViewController *)postingDateEntryViewControllerForField:(NSDictionary *)field{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewPost" bundle:[NSBundle mainBundle]];
    PostingDateEntryViewController *postingDateEntryViewController = [storyboard instantiateViewControllerWithIdentifier:@"PostingDateEntryViewController"];
    SpreeViewModelServicesImpl *viewModelServices = [[SpreeViewModelServicesImpl alloc] init];
    PostingDateEntryViewModel *postingDateEntryViewModel = [[PostingDateEntryViewModel alloc] initWithServices:viewModelServices field:field];
    postingDateEntryViewController.viewModel = postingDateEntryViewModel;
    @weakify(self)
    [[[postingDateEntryViewModel.nextCommand executionSignals] switchToLatest] subscribeNext:^(NSDate *date) {
        @strongify(self)
        self.step++;
        [self.post setObject:date forKey:(NSString *)field[@"field"]];
        NSMutableArray *completedFields = [[NSMutableArray alloc] initWithArray:[self.post objectForKey:@"completedFields"]];
        [completedFields addObject:field];
        self.post[@"completedFields"] = (NSArray *)completedFields;
        [self shouldPresentNextViewInWorkflow];
    }];
    return postingDateEntryViewController;
}

-(PostingPhotoEntryViewController *)postingPhotoEntryViewControllerForField:(NSDictionary *)field{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewPost" bundle:[NSBundle mainBundle]];
    PostingPhotoEntryViewController *postingPhotoEntryViewController = [storyboard instantiateViewControllerWithIdentifier:@"PostingPhotoEntryViewController"];
    SpreeViewModelServicesImpl *viewModelServices = [[SpreeViewModelServicesImpl alloc] init];
    PostingPhotoEntryViewModel *postingPhotoEntryViewModel = [[PostingPhotoEntryViewModel alloc] initWithServices:viewModelServices photos:nil];
    postingPhotoEntryViewController.viewModel = postingPhotoEntryViewModel;
    @weakify(self)
    [[[postingPhotoEntryViewModel.nextCommand executionSignals] switchToLatest] subscribeNext:^(NSArray *files) {
        @strongify(self)
        self.step++;
        [self.post setObject:files forKey:@"photoArray"];
        NSMutableArray *completedFields = [[NSMutableArray alloc] initWithArray:[self.post objectForKey:@"completedFields"]];
        [completedFields addObject:field];
        self.post[@"completedFields"] = (NSArray *)completedFields;
        [self shouldPresentNextViewInWorkflow];
    }];
    return postingPhotoEntryViewController;
}

-(void)shouldPresentNextViewInWorkflow{
    [(RACSubject *)self.presentNextViewControllerSignal sendNext:nil];
}

-(void)updateViewControllersForPresentationForType:(PFObject *)type subType:(PFObject *)subType{
    @weakify(self)
    [[[[[self.services getParseConnection] fetchObjectInBackground:type] map:^id(id value) {
        @strongify(self)
        for (NSDictionary *field in type[@"fields"]){
            [self.viewControllersForPresentation addObject:[self viewControllerForField:field]];
        }
        return nil;
    }] then:^RACSignal *{
        @strongify(self)
        return [[self.services getParseConnection] fetchObjectInBackground:subType];
    }] subscribeNext:^(PFObject *subType) {
        for (NSDictionary *field in subType[@"additionalFields"]){
            @strongify(self)
            [self.viewControllersForPresentation addObject:[self viewControllerForField:field]];
        }
        NSLog(@"%@", self.viewControllersForPresentation);
    }];
}

-(UIViewController *)viewControllerForField:(NSDictionary *)field{
    if ([field[@"dataType"] isEqualToString: @"string"]){
        return [self postingStringEntryViewControllerForField:field];
    } else if ([field[@"dataType"] isEqualToString: @"number"]){
        return [self postingNumberEntryViewControllerForField:field];
    } else if ([field[@"dataType"] isEqualToString: @"image"]){
        return [self postingPhotoEntryViewControllerForField:field];
    } else if ([field[@"dataType"] isEqualToString: @"date"]){
        return [self postingDateEntryViewControllerForField:field];
    }
    return 0;
}

-(RACSignal *)signalForCompletingPost:(SpreePost *)post{
    return [[self.services getParseConnection] postObjectInBackground:post];
}

@end
