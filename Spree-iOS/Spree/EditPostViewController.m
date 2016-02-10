//
//  EditPostViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 8/27/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "EditPostViewController.h"
#import "BasicInfoTableViewCell.h"
#import "PostMapTableViewCell.h"
#import "PostTitleTableViewCell.h"
#import "PostDescriptionTableViewCell.h"

@interface EditPostViewController ()

@end

@implementation EditPostViewController
/*
-(void)initWithPost:(SpreePost *)post{
    [super initWithPost:post];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupButtons];
    self.tableView.dataSource = self;
}

-(void)setupButtons{
    UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 40)];
    cancel.backgroundColor = [UIColor clearColor];
    cancel.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cancel setImage:[UIImage imageNamed:@"cancelOffBlack"] forState:UIControlStateNormal];
    [cancel setImage:[UIImage imageNamed:@"cancelHighlight"] forState:UIControlStateHighlighted];
    [cancel addTarget:self action:@selector(cancelEdit) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancel];
    
    UIButton *postButton = [[UIButton alloc] initWithFrame:CGRectZero];
    postButton.backgroundColor = [UIColor clearColor];
    [postButton setTitle:@"Save" forState:UIControlStateNormal];
    [postButton setTitleColor:[UIColor spreeDarkBlue] forState:UIControlStateNormal];
    [postButton sizeToFit];
    [postButton addTarget:self action:@selector(saveButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:postButton];
}

-(void)saveButtonPressed{
    [self.post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if (succeeded){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadPost" object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadTable" object:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}


-(void)cancelEdit{
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
        NSMutableArray *tempPhotoArray = [[NSMutableArray alloc] initWithCapacity:3];
        for (PFFile *imageFile in self.post.photoArray){
            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    UIImage *image = [UIImage imageWithData:data];
                    [tempPhotoArray addObject:image];
                    [photoCell setPhotoGalleryForImages:tempPhotoArray];
                    // image can now be set on a UIImageView
                }
            }];
        }
        [photoCell setupPriceLabelForPost:self.post];
        photoCell.editPriceButton.tag = 1;
        [photoCell.editPriceButton addTarget:self action:@selector(editButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
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

*/
@end
