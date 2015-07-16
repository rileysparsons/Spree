//
//  PostPhotoSelectViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 7/11/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "PostPhotoSelectViewController.h"
#import "PhotoSelectTableViewCell.h"
#import "AddPhotoHeaderView.h"
#import "UIColor+SpreeColor.h"
#import <YHRoundBorderedButton/YHRoundBorderedButton.h>
#import <CTAssetsPickerController/CTAssetsPickerController.h>

@interface PostPhotoSelectViewController () <CTAssetsPickerControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property NSMutableArray *photoArray;

@end

@implementation PostPhotoSelectViewController

int maxImageCount = 3;
int currentPhotoCount = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"PHOTO SELECT");
    
    self.photoArray = [[NSMutableArray alloc] initWithCapacity:3];
    [self.photoArray addObjectsFromArray:@[[NSNull null], [NSNull null], [NSNull null]]];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.autoresizesSubviews = YES;
    self.tableView.estimatedRowHeight = 100.0f;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.view.backgroundColor = [UIColor spreeOffWhite];
    self.view.backgroundColor = [UIColor spreeOffWhite];
    self.tableView.backgroundColor = [UIColor spreeOffWhite];
    self.navigationController.navigationBar.backgroundColor = [UIColor spreeOffWhite];
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
    
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars=NO;
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelWorkflow)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor spreeRed];
    
    UIButton *nextButton = [[YHRoundBorderedButton alloc] init];
    [nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextBarButtonItemTouched:) forControlEvents:UIControlEventTouchUpInside];
    [nextButton sizeToFit];
    [nextButton setTintColor:[UIColor spreeDarkBlue]];
    [nextButton setTitleColor:[UIColor spreeOffWhite] forState:UIControlStateHighlighted];
    
    [self.navigationItem setRightBarButtonItems:@[[[UIBarButtonItem alloc] initWithCustomView:nextButton]] animated:YES];

    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.delegate = self;
    picker.assetsFilter = [ALAssetsFilter allPhotos];
    picker.title = @"Add a few pictures";
    
    picker.showsNumberOfAssets = YES;
    [picker.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];

    [picker.navigationItem setTitle:@"Photos"];
    
    [self presentViewController:picker animated:YES completion:NULL];
    picker.navigationItem.title = @"Test";
    picker.navigationController.navigationBar.shadowImage = [UIImage new];
    picker.navigationController.view.backgroundColor = [UIColor spreeOffWhite];
    picker.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];

    // Do any additional setup after loading the view.
}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    for (ALAsset *asset  in assets){
        [self.photoArray replaceObjectAtIndex:[assets indexOfObject:asset] withObject:[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage]];
        currentPhotoCount++;
    }
    
    [self.tableView reloadData];
    NSLog(@"%d", currentPhotoCount);
    [self performSelector:@selector(scrollToBottom) withObject:nil afterDelay:0.1];
}

- (void)scrollToBottom
{
    CGFloat yOffset = 0;
    
    if (self.tableView.contentSize.height > self.tableView.bounds.size.height) {
        yOffset = self.tableView.contentSize.height - self.tableView.bounds.size.height;
    }
    
    [self.tableView setContentOffset:CGPointMake(0, yOffset) animated:YES];
}


- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(ALAsset *)asset
{
    if (picker.selectedAssets.count >= 4)
    {
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:@"Attention"
                                   message:@"Please select not more than 10 assets"
                                  delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:@"OK", nil];
        
        [alertView show];
    }
    
    if (!asset.defaultRepresentation)
    {
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:@"Attention"
                                   message:@"Your asset has not yet been downloaded to your device"
                                  delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:@"OK", nil];
        
        [alertView show];
    }
    
    return (picker.selectedAssets.count < 4 && asset.defaultRepresentation != nil);
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (currentPhotoCount == maxImageCount){
        return maxImageCount;
    } else {
        return currentPhotoCount+1;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    
    PhotoSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nibFiles = [[NSBundle mainBundle] loadNibNamed:@"PhotoSelectTableViewCell" owner:self options:nil];
        for(id currentObject in nibFiles){
            if ([currentObject isKindOfClass:[UITableViewCell class]]){
                cell = (PhotoSelectTableViewCell*)currentObject;
                break;
            }
        }
    }
    
    [cell.deleteButton addTarget:self action:@selector(deleteButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    cell.deleteButton.tag = indexPath.row;
    
    if ([[self.photoArray objectAtIndex:indexPath.row] isKindOfClass:[NSNull class]]) {
        [cell emptyCellMode];
        [cell.pickPhotoButton addTarget:self action:@selector(pickPhotoButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [cell.takePhotoButton addTarget:self action:@selector(takephotoButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [cell initWithImage:[self.photoArray objectAtIndex:indexPath.row]];
        [cell.deleteButton addTarget:self action:@selector(deleteButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

-(void)deleteButtonTouched:(id)sender{
    
    NSInteger indexOfDeletedPhoto = [(UIButton *)sender tag];
 
    [self.photoArray removeObjectAtIndex:indexOfDeletedPhoto];
    [self.photoArray insertObject:[NSNull null] atIndex:self.photoArray.count];
    currentPhotoCount--;
    
    NSLog(@"After Delete %@", self.photoArray);
    [self.tableView reloadData];
}

-(void)addPhotoButtonTouched:(id)sender{
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 150;
    }
    return 0;
    
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
                    custom.titleLabel.text = @"Those photos look great. Want to add another?";
                    [custom sizeToFit];
                    break;
                }
            }
        }
        return custom;
    }
    return 0;
}

-(void)cancelWorkflow{
    self.postingWorkflow.step--;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nextBarButtonItemTouched:(id)sender{
    NSMutableArray *fileArray = [[NSMutableArray alloc] initWithCapacity:3];
    for (id photo in self.photoArray) {
        if ([photo isKindOfClass:[UIImage class]]){
            NSData* data = UIImageJPEGRepresentation(photo, 0.5f);
            PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:data];
            [fileArray addObject:imageFile];
        }
    }
    self.postingWorkflow.post[@"photoArray"] = fileArray;
    self.postingWorkflow.step++;
    UIViewController *nextViewController =[self.postingWorkflow nextViewController];
    [self.navigationController pushViewController:nextViewController animated:YES];
}

-(void)takePhotoButtonTouched:(id)sender{
    
}

-(void)pickPhotoButtonTouched:(id)sender{
    
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
