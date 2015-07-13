//
//  PostingWorkflow.m
//  Spree
//
//  Created by Riley Steele Parsons on 6/28/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "PostingWorkflow.h"
#import "PostFieldViewController.h"
#import "PreviewPostViewController.h"
#import "PostPhotoSelectViewController.h"

@interface PostingWorkflow (){

}

@property PFObject* type;
@property NSArray* viewControllersForFields;

@end

@implementation PostingWorkflow

-(id)initWithType:(PFObject *)type{
    self = [super init];
    if (self){
        self.type = type;
        [self setupRequiredFields];
    }
    return self;
}

-(void)setupRequiredFields{
    NSArray *basicFields = [[NSArray alloc] initWithObjects:PF_POST_TITLE, PF_POST_DESCRIPTION, PF_POST_PRICE, nil];
    NSMutableArray *allFields = [[NSMutableArray alloc] initWithArray:basicFields];
    if ([self.type[@"type"] isEqualToString:POST_TYPE_BOOKS]) {
        [allFields addObjectsFromArray:@[PF_POST_PHOTOARRAY, PF_POST_BOOKFORCLASS]];
    } else if ([self.type[@"type"]  isEqualToString:POST_TYPE_ELECTRONICS]) {
        [allFields addObjectsFromArray:@[PF_POST_PHOTOARRAY]];
    } else if ([self.type[@"type"]  isEqualToString:POST_TYPE_FURNITURE]){
        [allFields addObjectsFromArray:@[PF_POST_PHOTOARRAY]];
    } else if ([self.type[@"type"]  isEqualToString:POST_TYPE_CLOTHING]){
        [allFields addObjectsFromArray:@[PF_POST_PHOTOARRAY]];
    } else if ([self.type[@"type"]  isEqualToString:POST_TYPE_TICKETS]){
        [allFields addObjectsFromArray:@[PF_POST_DATEFOREVENT]];
    } else if ([self.type[@"type"]  isEqualToString:POST_TYPE_TASK]){
        [allFields addObjectsFromArray:@[]];
    }
    self.uncompletedFields = [[NSMutableArray alloc] initWithArray:allFields];
}

-(UIViewController *)nextViewController{
    NSLog(@"Remaining fields: %@", self.uncompletedFields);
    if (self.uncompletedFields.count <= self.step){
        return [self presentPreviewPostController];
    } else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewPost" bundle:nil];
        PostFieldViewController *postFieldViewController = [storyboard instantiateViewControllerWithIdentifier:@"PostFieldViewController"];
        
        if ([[self.uncompletedFields objectAtIndex:self.step] isEqualToString: PF_POST_TITLE]){
            postFieldViewController.fieldName = PF_POST_TITLE;
            postFieldViewController.postingWorkflow = self;
        } else if([[self.uncompletedFields objectAtIndex:self.step] isEqualToString: PF_POST_DESCRIPTION]){
            postFieldViewController.fieldName = PF_POST_DESCRIPTION;
            postFieldViewController.postingWorkflow = self;
        } else if([[self.uncompletedFields objectAtIndex:self.step] isEqualToString: PF_POST_BOOKFORCLASS]){
            postFieldViewController.fieldName = PF_POST_BOOKFORCLASS;
            postFieldViewController.postingWorkflow = self;
        } else if([[self.uncompletedFields objectAtIndex:self.step] isEqualToString: PF_POST_DATEFOREVENT]){
            postFieldViewController.fieldName = PF_POST_DATEFOREVENT;
            postFieldViewController.postingWorkflow = self;
        } else if([[self.uncompletedFields objectAtIndex:self.step] isEqualToString: PF_POST_PHOTOARRAY]){
            PostPhotoSelectViewController *photoSelectViewController = [storyboard instantiateViewControllerWithIdentifier:@"PostPhotoSelectViewController"];
            photoSelectViewController.postingWorkflow = self;
            return photoSelectViewController;
        } else if ([[self.uncompletedFields objectAtIndex:self.step] isEqualToString: PF_POST_PRICE]){
            postFieldViewController.fieldName = PF_POST_PRICE;
            postFieldViewController.postingWorkflow = self;
        }
        return postFieldViewController;
    }
    return 0;
}

-(UIViewController *)presentPreviewPostController{
    PreviewPostViewController *previewPostViewController = [[PreviewPostViewController alloc] init];
    [previewPostViewController setFields:self.uncompletedFields];
    previewPostViewController.post = self.post;
    return previewPostViewController;
}

@end
