//
//  PreviewPostViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 7/11/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "PreviewPostViewController.h"
#import "PostDescriptionTableViewCell.h"
#import "PostTitleTableViewCell.h"
#import "PostUserTableViewCell.h"
#import "PhotoGalleryTableViewCell.h"
#import "BasicInfoTableViewCell.h"
#import "EditPostFieldViewController.h"
#import "EditPostingLocationEntryViewController.h"
#import "EditPostingNumberEntryViewController.h"
#import "EditPostingDateEntryViewController.h"
#import "PostMapTableViewCell.h"
#import "EditPostPhotoSelectViewController.h"
#import "PostPhotoSelectViewController.h"
#import "AddPhotoHeaderView.h"

@interface PreviewPostViewController ()

@property UIButton *postButton;

@end


@implementation PreviewPostViewController

-(void)initWithPost:(SpreePost *)post{
    self.post = post;
    self.existingFieldsForTable = [[NSMutableArray alloc] init];
    self.existingFields = self.post[@"completedFields"];
    self.hasCompletedFields = YES;
    [self organizeTableForFields];
}


-(void)initWithPost:(SpreePost *)post workflow:(PostingWorkflow *)workflow{
    self.post = post;
    self.existingFieldsForTable = [[NSMutableArray alloc] init];
    self.existingFields = self.post[@"completedFields"];
    self.postingWorkflow = workflow;
    self.hasCompletedFields = YES;
    [self organizeTableForFields];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupButtons];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.view.backgroundColor = [UIColor spreeOffWhite];
    self.navigationController.navigationBar.backgroundColor = [UIColor spreeOffWhite];
    
    // Do any additional setup after loading the view.
    
    NSLog(@"Post %@", self.post);
    NSLog(@"Workflow %@", self.postingWorkflow);

    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0){
        AddPhotoHeaderView *custom =[[AddPhotoHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 150)];
        custom.titleLabel.text = @"Everything look OK?";
        return custom;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 150;
    }
    return 0;
    
}

-(void)setupButtons{
    UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 40)];
    cancel.backgroundColor = [UIColor clearColor];
    cancel.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cancel setImage:[UIImage imageNamed:@"cancelOffBlack"] forState:UIControlStateNormal];
    [cancel setImage:[UIImage imageNamed:@"cancelHighlight"] forState:UIControlStateHighlighted];
    [cancel addTarget:self action:@selector(cancelPost) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancel];
    
    UIButton *postButton = [[UIButton alloc] initWithFrame:CGRectZero];
    postButton.backgroundColor = [UIColor clearColor];
    [postButton setTitle:@"Post" forState:UIControlStateNormal];
    [postButton setTitleColor:[UIColor spreeDarkBlue] forState:UIControlStateNormal];
    [postButton sizeToFit];
    [postButton addTarget:self action:@selector(postButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:postButton];
}

-(void)updatePostStatus{
    
}

-(void)postButtonPressed{
    NSLog(@"POSTED: %@", self.post);
    [self.post setExpired:NO];
    [self.post setSold:NO];
    self.post[@"expirationDate"] = [[NSDate date] dateByAddingTimeInterval:864000];
    self.post.photoArray = [self sanitizePhotoArray:self.post.photoArray];
    
    
    PFQuery *userQuery = [PFUser query];
    [userQuery includeKey:@"campus"];
    
    [userQuery getObjectInBackgroundWithId:[[PFUser currentUser] objectId] block:^(PFObject *user, NSError *error){
        if (error){
            NSLog(@"Campus was not fetched");
        } else {
            [self.post setNetwork:user[@"campus"][@"networkCode"]];
            [self.post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                if (error){
                    NSLog(@"Failed to post with reason: %@", error);
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadTable" object:nil];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }];
        }
    }];

    
}

-(void)cancelPost{
    self.postingWorkflow = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

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

-(NSUInteger)indexOfField:(NSDictionary*)cell{
    NSUInteger index = [self.existingFieldsForTable indexOfObject:cell];
    return index;
}

-(NSArray *)sanitizePhotoArray:(NSArray*)photoArray{
    NSMutableArray *purePhotoArray = [[NSMutableArray alloc] initWithCapacity:3];
    for (id item in photoArray) {
        if ([item isKindOfClass:[PFFile class]]){
            [purePhotoArray addObject:item];
        }
    }
    return purePhotoArray;
}

-(void)organizeTableForFields{
    for (id field in self.existingFields){
        if ([field[@"dataType"] isEqualToString:@"geoPoint"]){
            NSDictionary *mapCellDictionary;
            for (id dictionary in self.existingFieldsForTable){
                if ([dictionary[@"dataType"] isEqualToString:@"geoPoint"]){
                    mapCellDictionary = dictionary;
                }
            }
            if (!mapCellDictionary){
                [self.existingFieldsForTable addObject:field];
            }
        } else if ([field[@"dataType"] isEqualToString:@"string"]){
            [self.existingFieldsForTable addObject:field];
        } else if ([field[@"dataType"] isEqualToString:@"image"]){
            [self.existingFieldsForTable addObject:field];
        } else if ([field[@"dataType"] isEqualToString:@"date"]){
            [self.existingFieldsForTable addObject:field];
        }
    [self.existingFieldsForTable sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:YES]]];
    }
}

-(UITableViewCell *)cellForField:(NSDictionary *)field {
    
    // This cell subclass covers any fields that do not have their own custom subclass.
    NSString *className = NSStringFromClass([BasicInfoTableViewCell class]);
    UINib *nib = [UINib nibWithNibName:className bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:className];
    BasicInfoTableViewCell *basicInfoCell = [self.tableView dequeueReusableCellWithIdentifier:className];
    
    if ([field[@"dataType"] isEqualToString:@"geoPoint"]){
        NSString *className = NSStringFromClass([PostMapTableViewCell class]);
        UINib *nib = [UINib nibWithNibName:className bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:@"PostMapTableViewCell"];
        PostMapTableViewCell *mapCell = [self.tableView dequeueReusableCellWithIdentifier:@"PostMapTableViewCell"];
        [mapCell editButton];
        [mapCell.editButton addTarget:self action:@selector(editButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [mapCell setLocationsFromPost:self.post];
        return mapCell;
    } else if ([field[@"dataType"] isEqualToString:@"string"]){
        if ([field[@"field"] isEqualToString:@"userDescription"]){
            NSString *className = NSStringFromClass([PostDescriptionTableViewCell class]);
            UINib *nib = [UINib nibWithNibName:className bundle:nil];
            [self.tableView registerNib:nib forCellReuseIdentifier:className];
            PostDescriptionTableViewCell *descriptionCell = [self.tableView dequeueReusableCellWithIdentifier:className];
            [descriptionCell enableEditMode];
            [descriptionCell.editDescriptionButton addTarget:self action:@selector(editButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
            [descriptionCell setDescriptionTextViewForPost:self.post];
            return descriptionCell;
        } else if ([field[@"field"] isEqualToString:@"title"]){
            NSString *className = NSStringFromClass([PostTitleTableViewCell class]);
            UINib *nib = [UINib nibWithNibName:className bundle:nil];
            [self.tableView registerNib:nib forCellReuseIdentifier:className];
            PostTitleTableViewCell *titleCell = [self.tableView dequeueReusableCellWithIdentifier:className];
            [titleCell setTitleforPost:self.post];
            [titleCell enableEditMode];
            [titleCell.editTitleButton addTarget:self action:@selector(editButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
            return titleCell;
        } else {
            [basicInfoCell.fieldTitleLabel setText:[field[@"name"] capitalizedString]];
            [basicInfoCell.dataLabel setText:self.post[field[@"field"]]];
            [basicInfoCell enableEditMode];
            [basicInfoCell.editButton addTarget:self action:@selector(editButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
            return basicInfoCell;
        }
    } else if ([field[@"dataType"] isEqualToString:@"image"]){
        NSString *className = NSStringFromClass([PhotoGalleryTableViewCell class]);
        UINib *nib = [UINib nibWithNibName:className bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:className];
        PhotoGalleryTableViewCell *photoCell = [self.tableView dequeueReusableCellWithIdentifier:className];
        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:3];
        for (id object in self.postingWorkflow.photosForDisplay){
            if ([object isKindOfClass:[UIImage class]]){
                [tempArray addObject:object];
                NSLog(@"TEMP ARRAY %@", tempArray);
            }
        }
        [photoCell setPhotoGalleryForImages:tempArray];
        [photoCell setupPriceLabelForPost:self.post];
        [photoCell enableEditMode];
        photoCell.editPriceButton.tag = 1;
        photoCell.editButton.tag = 2;
        [photoCell.editPriceButton addTarget:self action:@selector(editButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [photoCell.editButton addTarget:self action:@selector(editButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        
        photoCell.dateLabel.hidden = YES;
        
        return photoCell;
        
    } else if ([field[@"dataType"] isEqualToString:@"date"]){
        basicInfoCell.fieldTitleLabel.text = [field[@"name"] capitalizedString];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mma"];
        NSString *dateString = [dateFormatter stringFromDate:self.post[field[@"field"]]];
        [basicInfoCell.dataLabel setText:dateString];
        [basicInfoCell.editButton addTarget:self action:@selector(editButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [basicInfoCell enableEditMode];
        return basicInfoCell;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    footerView.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    NSString *fullDateString = [NSString stringWithFormat:@"Posted on %@", dateString];
    label.font = [UIFont fontWithName:@"Lato-Regular" size:16];
    label.textColor = [UIColor spreeOffBlack];
    label.text = fullDateString;
    [label setFrame:CGRectMake(8, 8, footerView.frame.size.width, 30)];
    
    [footerView addSubview:label];
    
    return footerView;
}

-(NSDictionary *)getFieldForTitle:(NSString *)title{
    NSLog(@"%@", self.post[@"completedFields"]);
    for (NSDictionary *field in self.post[@"completedFields"]){
        if ([field[@"field"] isEqualToString:title]){
            return field;
        }
    }
    return 0;
}

@end
