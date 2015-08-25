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
#import "PostMapTableViewCell.h"
#import "EditPostPhotoSelectViewController.h"
#import "PostPhotoSelectViewController.h"
#import <YHRoundBorderedButton/YHRoundBorderedButton.h>
#import "AddPhotoHeaderView.h"

@interface PreviewPostViewController ()

@property UIButton *postButton;

@end


@implementation PreviewPostViewController

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
//    self.existingFieldsForTable = self.post[@"completedFields"];
//    NSLog(@"Workflow %@", self.postingWorkflow);
//    NSLog(@"Post %@", self.postingWorkflow.post);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(UITableViewCell *)cellForField:(NSString*)field {
//
//    if ([field isEqualToString:PF_POST_DESCRIPTION]){
//        static NSString *CellIdentifier = @"DescriptionCell";
//        PostDescriptionTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        if (cell == nil) {
//            NSArray *nibFiles = [[NSBundle mainBundle] loadNibNamed:@"PostDescriptionTableViewCell" owner:self options:nil];
//            for(id currentObject in nibFiles){
//                if ([currentObject isKindOfClass:[UITableViewCell class]]){
//                    cell = (PostDescriptionTableViewCell*)currentObject;
//                    break;
//                }
//            }
//        }
//        [cell.editDescriptionButton addTarget:self action:@selector(editButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
//        cell.editDescriptionButton.tag = [self indexOfField:field];
//        [cell setDescriptionTextViewForPost:self.post];
//        return cell;
//    } else if ([field isEqualToString:PF_POST_TITLE]){
//        static NSString *CellIdentifier = @"TitleCell";
//        PostTitleTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        if (cell == nil) {
//            NSArray *nibFiles = [[NSBundle mainBundle] loadNibNamed:@"PostTitleTableViewCell" owner:self options:nil];
//            for(id currentObject in nibFiles){
//                if ([currentObject isKindOfClass:[UITableViewCell class]]){
//                    cell = (PostTitleTableViewCell*)currentObject;
//                    break;
//                }
//            }
//        }
//        [cell enableEditMode];
//        [cell setTitleforPost:self.post];
//        [cell.editTitleButton addTarget:self action:@selector(editButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
//        cell.editTitleButton.tag = [self indexOfField:field];
//        return cell;
//    } else if ([field isEqualToString:PF_POST_PHOTOARRAY]){
//        static NSString *CellIdentifier = @"PhotoGalleryCell";
//        PhotoGalleryTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        if (cell == nil) {
//            NSArray *nibFiles = [[NSBundle mainBundle] loadNibNamed:@"PhotoGalleryTableViewCell" owner:self options:nil];
//            for(id currentObject in nibFiles){
//                if ([currentObject isKindOfClass:[UITableViewCell class]]){
//                    cell = (PhotoGalleryTableViewCell*)currentObject;
//                    break;
//                }
//            }
//        }
//        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:3];
//        for (id object in self.postingWorkflow.photosForDisplay){
//            if ([object isKindOfClass:[UIImage class]]){
//                [tempArray addObject:object];
//            }
//        }
//        
//        CGSize sysSize = [cell.contentView systemLayoutSizeFittingSize:CGSizeMake(self.tableView.bounds.size.width, CGFLOAT_MAX)];
//        cell.contentView.bounds = CGRectMake(0,0, sysSize.width, sysSize.height);
//        [cell.contentView layoutIfNeeded];
//        
//        [cell setPhotoGalleryForImages:tempArray];
//        [cell enableEditMode];
//        [cell.editButton addTarget:self action:@selector(editButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
//        NSLog(@"Number of photos %@", self.postingWorkflow.photosForDisplay);
//        cell.editButton.tag = [self indexOfField:field];;
//        cell.dateLabel.hidden = YES;
//        return cell;
//    } else if ([field isEqualToString:PF_POST_USER]){
//        static NSString *CellIdentifier = @"PostUserCell";
//        PostUserTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        if (cell == nil) {
//            NSArray *nibFiles = [[NSBundle mainBundle] loadNibNamed:@"PostUserTableViewCell" owner:self options:nil];
//            for(id currentObject in nibFiles){
//                if ([currentObject isKindOfClass:[UITableViewCell class]]){
//                    cell = (PostUserTableViewCell*)currentObject;
//                    break;
//                }
//            }
//        }
//        cell.userInteractionEnabled = NO;
//        cell.accessoryView = nil;
//        [cell setUserLabelForPost:self.post];
//        return cell;
//    } else if ([field isEqualToString:PF_POST_BOOKFORCLASS]){
//        static NSString *CellIdentifier = @"PostClassCell";
//        BasicInfoTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        if (cell == nil) {
//            NSArray *nibFiles = [[NSBundle mainBundle] loadNibNamed:@"BasicInfoTableViewCell" owner:self options:nil];
//            for(id currentObject in nibFiles){
//                if ([currentObject isKindOfClass:[UITableViewCell class]]){
//                    cell = (BasicInfoTableViewCell*)currentObject;
//                    break;
//                }
//            }
//        }
//        cell.editButton.tag = [self indexOfField:field];
//        [cell.editButton addTarget:self action:@selector(editButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
//        cell.titleLabel.text = self.post.bookForClass;
//        [cell enableEditMode];
//        return cell;
//    } else if ([field isEqualToString:PF_POST_DATEFOREVENT]){
//        static NSString *CellIdentifier = @"PostEventDateCell";
//        BasicInfoTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        if (cell == nil) {
//            NSArray *nibFiles = [[NSBundle mainBundle] loadNibNamed:@"BasicInfoTableViewCell" owner:self options:nil];
//            for(id currentObject in nibFiles){
//                if ([currentObject isKindOfClass:[UITableViewCell class]]){
//                    cell = (BasicInfoTableViewCell*)currentObject;
//                    break;
//                }
//            }
//        }
//        cell.editButton.tag = [self indexOfField:field];
//        [cell.editButton addTarget:self action:@selector(editButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
//        cell.titleLabel.text = self.post.eventDate;
//        [cell enableEditMode];
//        return cell;
//    } else if ([field isEqualToString:@"pickupLocation"] || [field isEqualToString:@"destinationLocation"]){
//        PostMapTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PostMapTableViewCell"];
//        [cell setLocationsFromPost:self.post];
//        [cell enableEditMode];
//        return cell;
//    }
//
//    static NSString *CellIdentifier = @"DefaultCell";
//    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    return cell;
//}



-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0){
        UIView * topHeader = [self.tableView headerViewForSection:0];
        AddPhotoHeaderView *custom =[[AddPhotoHeaderView alloc] init];
        if (topHeader == nil){
            NSArray *nibFiles = [[NSBundle mainBundle] loadNibNamed:@"AddPhotoHeaderView" owner:self options:nil];
            for(id currentObject in nibFiles){
                if ([currentObject isKindOfClass:[AddPhotoHeaderView class]]){
                    custom = currentObject;
                    custom.titleLabel.text = @"Everything look OK?";
                    break;
                }
            }
        }
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

-(void)postButtonPressed{
    NSLog(@"POSTED: %@", self.post);
    [self.post setExpired:NO];
    [self.post setSold:NO];
    self.post.photoArray = [self sanitizePhotoArray:self.post.photoArray];
    [[PFUser currentUser][@"campus"] fetchInBackgroundWithBlock:^(PFObject *object, NSError *error){
        if (error){
            NSLog(@"Campus was not fetched");
        } else {
           [self.post setNetwork:object[@"networkCode"]];
            [self.post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                if (error){
                    NSLog(@"Failed to post with reason: %@", error);
                } else {
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
    
    if ([[self.existingFieldsForTable objectAtIndex:indexPath.row][@"dataType"] isEqualToString:@"image"]){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewPost" bundle:[NSBundle mainBundle]];
        EditPostPhotoSelectViewController *editPostPhotoViewController = [storyboard instantiateViewControllerWithIdentifier:@"EditPostPhotoSelectViewController"];
        editPostPhotoViewController.postingWorkflow = self.postingWorkflow;
        UINavigationController *navControl = [[UINavigationController alloc] initWithRootViewController:editPostPhotoViewController];
        [self presentViewController:navControl animated:YES completion:nil];
    } else if ([[self.existingFieldsForTable objectAtIndex:indexPath.row][@"dataType"] isEqualToString:@"string"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewPost" bundle:[NSBundle mainBundle]];
        EditPostFieldViewController *postFieldViewController = [storyboard instantiateViewControllerWithIdentifier:@"EditPostFieldViewController"];
        [postFieldViewController initWithField:[self.existingFieldsForTable objectAtIndex:indexPath.row] post:self.post];
        UINavigationController *navControl = [[UINavigationController alloc] initWithRootViewController:postFieldViewController];
        [self presentViewController:navControl animated:YES completion:nil];
//    } else if ([[self.detailCells objectAtIndex:editButton.tag][@"dataType"] isEqualToString:@"geoPoint"]) {
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewPost" bundle:[NSBundle mainBundle]];
//        EditPostFieldViewController *postFieldViewController = [storyboard instantiateViewControllerWithIdentifier:@"EditPostFieldViewController"];
//        [postFieldViewController initWithField:[self.existingFields objectAtIndex:editButton.tag] post:self.post];
//        UINavigationController *navControl = [[UINavigationController alloc] initWithRootViewController:postFieldViewController];
//        [self presentViewController:navControl animated:YES completion:nil];
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
        }
    [self.existingFieldsForTable sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:YES]]];
    }
}

-(UITableViewCell *)cellForField:(NSDictionary *)field {
    if ([field[@"dataType"] isEqualToString:@"geoPoint"]){
        NSString *className = NSStringFromClass([PostMapTableViewCell class]);
        UINib *nib = [UINib nibWithNibName:className bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:@"PostMapTableViewCell"];
        PostMapTableViewCell *mapCell = [self.tableView dequeueReusableCellWithIdentifier:@"PostMapTableViewCell"];
        mapCell.editButton.hidden = NO;
        [mapCell.editButton addTarget:self action:@selector(editButton) forControlEvents:UIControlEventTouchUpInside];
        [mapCell setLocationsFromPost:self.post];
        return mapCell;
    } else if ([field[@"dataType"] isEqualToString:@"string"]){
        if ([field[@"field"] isEqualToString:@"userDescription"]){
            NSString *className = NSStringFromClass([PostDescriptionTableViewCell class]);
            UINib *nib = [UINib nibWithNibName:className bundle:nil];
            [self.tableView registerNib:nib forCellReuseIdentifier:className];
            PostDescriptionTableViewCell *descriptionCell = [self.tableView dequeueReusableCellWithIdentifier:className];
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
            UITableViewCell *otherCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"other"];
            [otherCell setBackgroundColor:[UIColor spreeOffWhite]];
            otherCell.textLabel.textColor = [UIColor spreeOffBlack];
            otherCell.textLabel.font = [UIFont fontWithName:@"Lato-Regular" size:18];
            [otherCell.textLabel setText:self.post[field[@"field"]]];
            return otherCell;
        }
    } else if ([field[@"dataType"] isEqualToString:@"image"]){
        NSString *className = NSStringFromClass([PhotoGalleryTableViewCell class]);
        UINib *nib = [UINib nibWithNibName:className bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:className];
        PhotoGalleryTableViewCell *photoCell = [self.tableView dequeueReusableCellWithIdentifier:className];
        [photoCell setDateLabelForPost:self.post];
        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:3];
        NSLog(@"Photos for display %@", self.postingWorkflow.photosForDisplay);
        for (id object in self.postingWorkflow.photosForDisplay){
            if ([object isKindOfClass:[UIImage class]]){
                [tempArray addObject:object];
                NSLog(@"TEMP ARRAY %@", tempArray);
            }
        }
        [photoCell setPhotoGalleryForImages:tempArray];
        [photoCell enableEditMode];
        [photoCell.editButton addTarget:self action:@selector(editButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        photoCell.dateLabel.hidden = YES;
        return photoCell;
    }
    return 0;
}



@end
