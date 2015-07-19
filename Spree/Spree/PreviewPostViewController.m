//
//  PreviewPostViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 7/11/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "PreviewPostViewController.h"
#import "PostTitleTableViewCell.h"
#import "PostUserTableViewCell.h"
#import "PhotoGalleryTableViewCell.h"
#import "BasicInfoTableViewCell.h"
#import <YHRoundBorderedButton/YHRoundBorderedButton.h>
#import "AddPhotoHeaderView.h"

@interface PreviewPostViewController ()

@property UIButton *postButton;

@end


@implementation PreviewPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupButtons];
    
    UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 40)];
    cancel.backgroundColor = [UIColor clearColor];
    cancel.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cancel setImage:[UIImage imageNamed:@"backNormal_Dark"] forState:UIControlStateNormal];
    [cancel setImage:[UIImage imageNamed:@"backHighlight_Dark"] forState:UIControlStateHighlighted];
    [cancel addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancel];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.view.backgroundColor = [UIColor spreeOffWhite];
    self.navigationController.navigationBar.backgroundColor = [UIColor spreeOffWhite];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UITableViewCell *)cellForField:(NSString *)field {
    if ([field isEqualToString:PF_POST_TITLE]){
        static NSString *CellIdentifier = @"TitleCell";
        PostTitleTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *nibFiles = [[NSBundle mainBundle] loadNibNamed:@"PostTitleTableViewCell" owner:self options:nil];
            for(id currentObject in nibFiles){
                if ([currentObject isKindOfClass:[UITableViewCell class]]){
                    cell = (PostTitleTableViewCell*)currentObject;
                    break;
                }
            }
        }
        [cell enableEditMode];
        [cell setTitleforPost:self.post];
        [cell setDescriptionTextViewForPost:self.post];
        return cell;
    } else if ([field isEqualToString:PF_POST_PHOTOARRAY]){
        static NSString *CellIdentifier = @"PhotoGalleryCell";
        PhotoGalleryTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *nibFiles = [[NSBundle mainBundle] loadNibNamed:@"PhotoGalleryTableViewCell" owner:self options:nil];
            for(id currentObject in nibFiles){
                if ([currentObject isKindOfClass:[UITableViewCell class]]){
                    cell = (PhotoGalleryTableViewCell*)currentObject;
                    break;
                }
            }
        }
        [cell enableEditMode];
        cell.dateLabel.hidden = YES;
        [super loadPostImagesForCell:cell];
        [cell setDateLabelForPost:self.post];
        return cell;
    } else if ([field isEqualToString:PF_POST_USER]){
        static NSString *CellIdentifier = @"PostUserCell";
        PostUserTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *nibFiles = [[NSBundle mainBundle] loadNibNamed:@"PostUserTableViewCell" owner:self options:nil];
            for(id currentObject in nibFiles){
                if ([currentObject isKindOfClass:[UITableViewCell class]]){
                    cell = (PostUserTableViewCell*)currentObject;
                    break;
                }
            }
        }
        [cell enableEditMode];
        cell.accessoryView = nil;
        [cell setTag:2];
        [cell setUserLabelForPost:self.post];
        return cell;
    } else if ([field isEqualToString:PF_POST_BOOKFORCLASS]){
        static NSString *CellIdentifier = @"PostClassCell";
        BasicInfoTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *nibFiles = [[NSBundle mainBundle] loadNibNamed:@"BasicInfoTableViewCell" owner:self options:nil];
            for(id currentObject in nibFiles){
                if ([currentObject isKindOfClass:[UITableViewCell class]]){
                    cell = (BasicInfoTableViewCell*)currentObject;
                    break;
                }
            }
        }
        cell.titleLabel.text = self.post.bookForClass;
        [cell enableEditMode];
        return cell;
    } else if ([field isEqualToString:PF_POST_DATEFOREVENT]){
        static NSString *CellIdentifier = @"PostEventDateCell";
        BasicInfoTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *nibFiles = [[NSBundle mainBundle] loadNibNamed:@"BasicInfoTableViewCell" owner:self options:nil];
            for(id currentObject in nibFiles){
                if ([currentObject isKindOfClass:[UITableViewCell class]]){
                    cell = (BasicInfoTableViewCell*)currentObject;
                    break;
                }
            }
        }
        cell.titleLabel.text = self.post.eventDate;
        [cell enableEditMode];
        return cell;
    }
    static NSString *CellIdentifier = @"DefaultCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    return cell;
}

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
    self.postButton = [[YHRoundBorderedButton alloc] init];
    [self.postButton addTarget:self action:@selector(postButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.postButton sizeToFit];
    [self.postButton.titleLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
    [self.postButton setTintColor:[UIColor spreeDarkBlue]];
    [self.postButton setTitleColor:[UIColor spreeOffBlack] forState:UIControlStateHighlighted];
    [self.postButton setTitle:@"POST" forState:UIControlStateNormal];
    UIBarButtonItem *getBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.postButton];
    self.navigationItem.rightBarButtonItem = getBarButton;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor spreeRed];
}

-(void)postButtonPressed{
    NSLog(@"POSTED!");
}

-(void)backButtonPressed{
    self.postingWorkflow.step--;
    [self.navigationController popViewControllerAnimated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
