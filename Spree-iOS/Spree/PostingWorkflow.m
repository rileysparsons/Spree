//
//  PostingWorkflow.m
//  Spree
//
//  Created by Riley Steele Parsons on 6/28/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "PostingWorkflow.h"
#import "PostingStringEntryViewController.h"
#import "PreviewPostViewController.h"
#import "PostPhotoSelectViewController.h"
#import "PostingNumberEntryViewController.h"
#import "PostingLocationEntryViewController.h"
#import "PostingDateEntryViewController.h"



@interface PostingWorkflow (){

}

@property NSMutableArray *allFields;
@property (nonatomic)  NSArray* viewControllersForFields;

@end

@implementation PostingWorkflow

@synthesize type = _type;
@synthesize subtype = _subtype;

-(id)initWithPost:(SpreePost *)post{
    self = [super init];
    if (self){
        self.post = post;
        self.post[@"completedFields"] = [[NSMutableArray alloc] init];
        self.allFields = [[NSMutableArray alloc] init];
        self.uncompletedFields = [[NSMutableArray alloc] init];
        self.photosForDisplay = [[NSMutableArray alloc] init];
        [self setType:post.typePointer];
        [self setupRequiredFields];
    }
    return self;
}

-(id)initWithType:(PFObject *)type{
    self = [super init];
    if (self){
        self.type = type;
        self.photosForDisplay = [[NSMutableArray alloc] init];
        [self setupRequiredFields];
    }
    return self;
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
 
-(void)setupRequiredFields{
//    NSArray *basicFields = [[NSArray alloc] initWithObjects:PF_POST_TITLE, PF_POST_DESCRIPTION, PF_POST_PRICE, nil];
//    NSMutableArray *allFields = [[NSMutableArray alloc] initWithArray:basicFields];
//    if ([self.type[@"type"] isEqualToString:POST_TYPE_BOOKS]) {
//        [allFields addObjectsFromArray:@[PF_POST_PHOTOARRAY, PF_POST_BOOKFORCLASS]];
//    } else if ([self.type[@"type"]  isEqualToString:POST_TYPE_ELECTRONICS]) {
//        [allFields addObjectsFromArray:@[PF_POST_PHOTOARRAY]];
//    } else if ([self.type[@"type"]  isEqualToString:POST_TYPE_FURNITURE]){
//        [allFields addObjectsFromArray:@[PF_POST_PHOTOARRAY]];
//    } else if ([self.type[@"type"]  isEqualToString:POST_TYPE_CLOTHING]){
//        [allFields addObjectsFromArray:@[PF_POST_PHOTOARRAY]];
//    } else if ([self.type[@"type"]  isEqualToString:POST_TYPE_TICKETS]){
//        [allFields addObjectsFromArray:@[PF_POST_DATEFOREVENT]];
//    } else if ([self.type[@"type"]  isEqualToString:POST_TYPE_TASK]){
//        [allFields addObjectsFromArray:@[]];
//    }
//    self.uncompletedFields = [[NSMutableArray alloc] initWithArray:allFields];
    
    
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
