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
#import "PostPhotoSelectViewController.h"
#import "PostingNumberEntryViewController.h"
#import "PostingLocationEntryViewController.h"
#import "PostingDateEntryViewController.h"
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

@synthesize type = _type;
@synthesize subtype = _subtype;

-(instancetype)initWithServices:(id<SpreeViewModelServices>)services{
    self = [super init];
    if (self) {
        _services = services;
        [self initialize];
    }
    return self;
}

-(id)initWithPost:(SpreePost *)post{
    self = [super init];
    if (self){
        self.post = post;
        self.post[@"completedFields"] = [[NSMutableArray alloc] init];
        self.locationService = [MMPReactiveCoreLocation service];
        self.allFields = [[NSMutableArray alloc] init];
        [self.locationService.location subscribeNext:^(id x) {
            NSLog(@"location %@", x);
            self.post[@"location"] = [PFGeoPoint geoPointWithLocation:x];
        }];
        self.uncompletedFields = [[NSMutableArray alloc] init];
        self.photosForDisplay = [[NSMutableArray alloc] init];
        [self setType:post.typePointer];
    }
    return self;
}

-(void)initialize{
    self.post = [SpreePost new];
    
    self.locationService = [MMPReactiveCoreLocation service];
    
    [self.locationService.location subscribeNext:^(id x) {
        NSLog(@"location %@", x);
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

}

-(void)setSubtype:(PFObject *)subtype{
    _subtype = subtype;
    NSLog(@"SUBTYPE %@", subtype);
    for (id field in subtype[@"additionalFields"]){
        [self.uncompletedFields addObject:field];
        self.allFields = self.uncompletedFields;
    }
}

-(void)setType:(PFObject *)type{
    _type = type;
    NSLog(@"TYPE %@", type);
    for (id field in type[@"fields"]){
        [self.uncompletedFields addObject:field];
        self.allFields = self.uncompletedFields;
    }
}


-(UIViewController *)nextViewController{
    NSLog(@"Remaining fields: %@", self.uncompletedFields);
    
    if (self.uncompletedFields.count <= self.step){
        return [self presentPreviewPostController];
    } else {
        NSDictionary *nextField = [self.uncompletedFields objectAtIndex:self.step];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewPost" bundle:nil];
        if ([nextField[@"dataType"] isEqualToString: @"string"]){
            PostingStringEntryViewController *postFieldViewController = [storyboard instantiateViewControllerWithIdentifier:@"PostFieldViewController"];
            [postFieldViewController initWithField:nextField postingWorkflow:self];
            return postFieldViewController;
        } else if ([nextField[@"dataType"] isEqualToString: @"geoPoint"]){
            PostingLocationEntryViewController *postingLocationEntryViewController = [storyboard instantiateViewControllerWithIdentifier:@"PostingLocationEntryViewController"];
            [postingLocationEntryViewController initWithField:nextField postingWorkflow:self];
            return postingLocationEntryViewController;
        } else if ([nextField[@"dataType"] isEqualToString: @"number"]){
            PostingNumberEntryViewController *postPriceEntryViewController = [storyboard instantiateViewControllerWithIdentifier:@"PostPriceEntryViewController"];
            [postPriceEntryViewController initWithField:nextField postingWorkflow:self];
            return postPriceEntryViewController;
        } else if ([nextField[@"dataType"] isEqualToString: @"image"]){
            PostPhotoSelectViewController *postPhotoSelectViewController = [storyboard instantiateViewControllerWithIdentifier:@"PostPhotoSelectViewController"];
            postPhotoSelectViewController.postingWorkflow = self;
            postPhotoSelectViewController.fieldDictionary = nextField;
            return postPhotoSelectViewController;
        } else if ([nextField[@"dataType"] isEqualToString: @"date"]){
        PostingDateEntryViewController *postPhotoSelectViewController = [storyboard instantiateViewControllerWithIdentifier:@"PostingDateEntryViewController"];
            [postPhotoSelectViewController initWithField:nextField postingWorkflow:self];
            
            return postPhotoSelectViewController;
        }
    }
    return 0;
}

-(UIViewController *)presentPreviewPostController{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewPost" bundle:nil];
    PreviewPostViewController *previewPostViewController = [storyboard instantiateViewControllerWithIdentifier:@"PreviewPostViewController"];
    NSMutableArray *previewFields = [[NSMutableArray alloc] init];
    
    for (id field in self.allFields){
        [previewFields addObject:field[@"field"]];
    }
    NSLog(@"PHotos for display %@", self.photosForDisplay);
//    previewPostViewController.post = self.post;
//    previewPostViewController.postingWorkflow = self;
    [previewPostViewController initWithPost:self.post workflow:self];
    return previewPostViewController;
}

@end
