//
//  PreviewPostViewModel.m
//  Spree
//
//  Created by Riley Steele Parsons on 2/7/16.
//  Copyright © 2016 Riley Steele Parsons. All rights reserved.
//

#import "PreviewPostViewModel.h"
#import "PostDescriptionTableViewCell.h"
#import "EditPostFieldViewController.h"
#import "PostMapTableViewCell.h"
#import "PostTitleTableViewCell.h"
#import "PostUserTableViewCell.h"
#import "PhotoGalleryTableViewCell.h"
#import "BasicInfoTableViewCell.h"

@interface PreviewPostViewModel ()

@property id<SpreeViewModelServices> services;
@property NSMutableArray *cellsForTable;

@end

@implementation PreviewPostViewModel

-(instancetype)initWithServices:(id<SpreeViewModelServices>)services post:(SpreePost *)post{
    self = [super init];
    if (self) {
        _services = services;
        _post = post;
        [self initialize];
    }
    return self;
}

-(void)initialize{
    self.completePostCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal return:nil];
    }];
    self.existingFieldsToShow = [self findFieldsToShow:self.post[@"completedFields"]];
    
    self.editFieldCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal return:[self viewControllerForField:input]];
    }];
    
    self.fieldWasEditedCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal return:nil];
    }];
}

// Sorts the existing fields by priority for the view.
-(NSArray *)findFieldsToShow:(NSDictionary *)fields{
    NSMutableArray *fieldsToShow = [[NSMutableArray alloc] init];
    for (id field in fields){
        if (!field[@"priority"]){
            [field setObject:@(99) forKey:@"priority"];
        }
        if ([field[@"dataType"] isEqualToString:@"geoPoint"]){
            NSDictionary *mapCellDictionary;
            for (id dictionary in fieldsToShow){
                if ([dictionary[@"dataType"] isEqualToString:@"geoPoint"]){
                    mapCellDictionary = dictionary;
                }
            }
            if (!mapCellDictionary){
                [fieldsToShow addObject:field];
            }
        } else if ([field[@"dataType"] isEqualToString:@"string"]){
            [fieldsToShow addObject:field];
        } else if ([field[@"dataType"] isEqualToString:@"image"]){
            [fieldsToShow addObject:field];
        } else if ([field[@"dataType"] isEqualToString:@"date"]){
            [fieldsToShow addObject:field];
        }
        [fieldsToShow sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:YES]]];
    }
    return fieldsToShow;
}

-(UIViewController *)viewControllerForField:(NSDictionary *)field{
    if ([field[@"dataType"] isEqualToString: @"string"]){
        return [self editPostingStringEntryViewControllerForField:field];
    }
//    } else if ([field[@"dataType"] isEqualToString: @"number"]){
//        return [self postingNumberEntryViewControllerForField:field];
//    } else if ([field[@"dataType"] isEqualToString: @"image"]){
//        return [self postingPhotoEntryViewControllerForField:field];
//    } else if ([field[@"dataType"] isEqualToString: @"date"]){
//        return [self postingDateEntryViewControllerForField:field];
//    }
    return 0;
}
/*
-(void)editButtonTouched:(id)sender{
    UIButton *button = (UIButton *)sender;
    CGRect buttonFrame = [button convertRect:button.bounds toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonFrame.origin];
    NSLog(@"%ld", (long)indexPath.row);
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewPost" bundle:[NSBundle mainBundle]];
    
    if ([[self.existingFieldsForTable objectAtIndex:indexPath.row][@"dataType"] isEqualToString:@"image"]){
        if (button.tag == 1){ // Price edit button is nested in photo cell
            
            EditPostingNumberEntryViewController *editPostingNumberViewController = [storyboard instantiateViewControllerWithIdentifier:@"EditPostingNumberEntryViewController"];
            [editPostingNumberViewController initWithField:[self getFieldForTitle:@"price"] post:self.post];
            UINavigationController *navControl = [[UINavigationController alloc] initWithRootViewController:editPostingNumberViewController];
            [self presentViewController:navControl animated:YES completion:nil];
        } else if (button.tag == 2){
            EditPostPhotoSelectViewController *editPostPhotoViewController = [storyboard instantiateViewControllerWithIdentifier:@"EditPostPhotoSelectViewController"];
            editPostPhotoViewController.postingWorkflow = self.postingWorkflow;
            UINavigationController *navControl = [[UINavigationController alloc] initWithRootViewController:editPostPhotoViewController];
            [self presentViewController:navControl animated:YES completion:nil];
        }
    } else if ([[self.existingFieldsForTable objectAtIndex:indexPath.row][@"dataType"] isEqualToString:@"string"]) {
        EditPostFieldViewController *postFieldViewController = [storyboard instantiateViewControllerWithIdentifier:@"EditPostFieldViewController"];
        [postFieldViewController initWithField:[self.existingFieldsForTable objectAtIndex:indexPath.row] post:self.post];
        UINavigationController *navControl = [[UINavigationController alloc] initWithRootViewController:postFieldViewController];
        [self presentViewController:navControl animated:YES completion:nil];
    } else if ([[self.existingFieldsForTable objectAtIndex:indexPath.row][@"dataType"] isEqualToString:@"geoPoint"]) {
        
        EditPostingLocationEntryViewController *postFieldViewController = [storyboard instantiateViewControllerWithIdentifier:@"EditPostingLocationEntryViewController"];
        [postFieldViewController initWithField:[self.existingFieldsForTable objectAtIndex:indexPath.row] post:self.post];
        UINavigationController *navControl = [[UINavigationController alloc] initWithRootViewController:postFieldViewController];
        [self presentViewController:navControl animated:YES completion:nil];
    } else if ([[self.existingFieldsForTable objectAtIndex:indexPath.row][@"dataType"] isEqualToString:@"date"]){
        EditPostingDateEntryViewController *postFieldViewController = [storyboard instantiateViewControllerWithIdentifier:@"EditPostingDateEntryViewController"];
        [postFieldViewController initWithField:[self.existingFieldsForTable objectAtIndex:indexPath.row] post:self.post];
        UINavigationController *navControl = [[UINavigationController alloc] initWithRootViewController:postFieldViewController];
        [self presentViewController:navControl animated:YES completion:nil];
    }
}
*/

-(EditPostFieldViewController *)editPostingStringEntryViewControllerForField:(NSDictionary *)field{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewPost" bundle:[NSBundle mainBundle]];
    EditPostFieldViewController *editPostingStringEntryViewController = [storyboard instantiateViewControllerWithIdentifier:@"EditPostFieldViewController"];
    PostingStringEntryViewModel *postingStringEntryViewModel = [[PostingStringEntryViewModel alloc] initWithServices:self.services field:field];
    editPostingStringEntryViewController.viewModel = postingStringEntryViewModel;
    postingStringEntryViewModel.enteredString  = [self.post objectForKey:field[@"field"]];
    @weakify(self)
    [[[postingStringEntryViewModel.nextCommand executionSignals] switchToLatest] subscribeNext:^(NSString *string) {
        @strongify(self)
        [self.post setObject:string forKey:(NSString *)field[@"field"]];
        [self.fieldWasEditedCommand execute:nil];
    }];
    return editPostingStringEntryViewController;
}
/*
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
    [[[postingDateEntryViewModel.nextCommand executionSignals] switchToLatest] subscribeNext:^(NSString *string) {
        @strongify(self)
        self.step++;
        [self.post setObject:string forKey:(NSString *)field[@"field"]];
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
*/
@end
