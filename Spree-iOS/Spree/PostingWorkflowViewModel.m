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
#import "PostingLocationEntryViewController.h"
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
    
    self.post[@"completedFields"] = [[NSArray alloc] init];
    
    self.locationService = [MMPReactiveCoreLocation service];
    
    [self.locationService.location subscribeNext:^(id x) {
        self.post[@"location"] = [PFGeoPoint geoPointWithLocation:x];
    }];
    
    self.allFields = [[NSMutableArray alloc] init];
    self.completedFields = [[NSMutableArray alloc] init];
    self.uncompletedFields = [[NSMutableArray alloc] init];
    self.photosForDisplay = [[NSMutableArray alloc] init];
    
    [RACObserve(self.post, typePointer) map:^id(id value) {
        for (id field in value[@"fields"]){
            [self.uncompletedFields addObject:field];
            self.allFields = self.uncompletedFields;
        }
        return nil;
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
    previewPostViewController.post = self.post;
    previewPostViewController.postingWorkflow = self;
    return previewPostViewController;
}

-(SelectPostTypeViewController *)selectPostTypeViewController{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewPost" bundle:[NSBundle mainBundle]];
    SelectPostTypeViewController* selectPostTypeViewController = [storyboard instantiateViewControllerWithIdentifier:@"SelectPostTypeViewController"];
    SpreeViewModelServicesImpl *viewModelServices = [[SpreeViewModelServicesImpl alloc] init];
    SelectPostTypeViewModel *selectPostTypeViewModel = [[SelectPostTypeViewModel alloc] initWithServices:viewModelServices];
    selectPostTypeViewController.viewModel = selectPostTypeViewModel;
    [[[selectPostTypeViewModel.typeSelectedCommand executionSignals] switchToLatest] subscribeNext:^(id x) {
        self.step++;
        self.post[@"postType"] = x;
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
    [[[selectPostSubTypeViewModel.subTypeSelectedCommand executionSignals] switchToLatest] subscribeNext:^(id x) {
        self.step++;
        self.post[@"postSubtype"] = x;
        [self updateViewControllersForPresentationForType:self.post[@"postType"] subType:self.post[@"postSubtype"]];
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

-(PostingPhotoEntryViewController *)postingPhotoEntryViewControllerForField:(NSDictionary *)field{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewPost" bundle:[NSBundle mainBundle]];
    PostingPhotoEntryViewController *postingPhotoEntryViewController = [storyboard instantiateViewControllerWithIdentifier:@"PostingPhotoEntryViewController"];
    SpreeViewModelServicesImpl *viewModelServices = [[SpreeViewModelServicesImpl alloc] init];
    PostingPhotoEntryViewModel *postingPhotoEntryViewModel = [[PostingPhotoEntryViewModel alloc] initWithServices:viewModelServices];
    postingPhotoEntryViewController.viewModel = postingPhotoEntryViewModel;
    @weakify(self)
    [[[postingPhotoEntryViewModel.nextCommand executionSignals] switchToLatest] subscribeNext:^(NSArray *files) {
        @strongify(self)
        self.step++;
        [self.post setObject:[self convertDataFilesToPFFiles:files] forKey:@"photoArray"];
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
        [self.viewControllersForPresentation addObject:[self presentPreviewPostController]];
    }];
}

-(UIViewController *)viewControllerForField:(NSDictionary *)field{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewPost" bundle:nil];
    if ([field[@"dataType"] isEqualToString: @"string"]){
        return [self postingStringEntryViewControllerForField:field];
    } else if ([field[@"dataType"] isEqualToString: @"geoPoint"]){
        PostingLocationEntryViewController *postingLocationEntryViewController = [storyboard instantiateViewControllerWithIdentifier:@"PostingLocationEntryViewController"];
        [postingLocationEntryViewController initWithField:field postingWorkflow:self];
        return postingLocationEntryViewController;
    } else if ([field[@"dataType"] isEqualToString: @"number"]){
        return [self postingNumberEntryViewControllerForField:field];
    } else if ([field[@"dataType"] isEqualToString: @"image"]){
        return [self postingPhotoEntryViewControllerForField:field];
    } else if ([field[@"dataType"] isEqualToString: @"date"]){
        PostingDateEntryViewController *postPhotoSelectViewController = [storyboard instantiateViewControllerWithIdentifier:@"PostingDateEntryViewController"];
        [postPhotoSelectViewController initWithField:field postingWorkflow:self];
        return postPhotoSelectViewController;
    }
    return 0;
}

-(NSArray *)convertDataFilesToPFFiles:(NSArray *)files{
    NSMutableArray *PFFiles = [[NSMutableArray alloc] init];
    for (NSData *data in files) {
        [PFFiles addObject:[PFFile fileWithData:data]];
    }
    return PFFiles;
}

@end
