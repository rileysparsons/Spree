//
//  PostPhotoSelectViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 7/11/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "PostPhotoSelectViewController.h"
#import "PhotoDisplayTableViewCell.h"
#import "PhotoSelectFooterView.h"
#import "AddPhotoHeaderView.h"
#import "UIColor+SpreeColor.h"
#import <YHRoundBorderedButton/YHRoundBorderedButton.h>
#import <CTAssetsPickerController/CTAssetsPickerController.h>

@interface PostPhotoSelectViewController () <CTAssetsPickerControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>


@end

@implementation PostPhotoSelectViewController

int maxImageCount = 3;
int currentPhotoCount = 0;

- (void)navigationBarButtons {
    UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 40)];
    cancel.backgroundColor = [UIColor clearColor];
    cancel.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cancel setImage:[UIImage imageNamed:@"backNormal_Dark"] forState:UIControlStateNormal];
    [cancel setImage:[UIImage imageNamed:@"backHighlight_Dark"] forState:UIControlStateHighlighted];
    [cancel addTarget:self action:@selector(cancelWorkflow) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancel];
    
    self.countBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.countBarButton.frame = CGRectZero;
    self.countBarButton.titleLabel.font = [UIFont fontWithName:@"Lato-Bold" size:16];
    
    self.countBarButton.userInteractionEnabled = NO;
    [self.countBarButton setTitle:[NSString stringWithFormat:@"%d", maxImageCount-currentPhotoCount] forState:UIControlStateNormal];
    [self.countBarButton setTitleColor:[UIColor spreeDarkBlue] forState:UIControlStateNormal];
    [self.countBarButton sizeToFit];
    self.countBarButton.backgroundColor = [UIColor clearColor];
    
    UIBarButtonItem *countBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.countBarButton];
    
    UIButton *nextButton = [[YHRoundBorderedButton alloc] init];
    [nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextBarButtonItemTouched:) forControlEvents:UIControlEventTouchUpInside];
    [nextButton sizeToFit];
    [nextButton.titleLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
    [nextButton setTintColor:[UIColor spreeDarkBlue]];
    [nextButton setTitleColor:[UIColor spreeOffWhite] forState:UIControlStateHighlighted];
    
    [self.navigationItem setRightBarButtonItems:@[[[UIBarButtonItem alloc] initWithCustomView:nextButton], countBarButtonItem] animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"PHOTO SELECT");
    if (self.photoArray == nil){
        self.photoArray = [[NSMutableArray alloc] initWithCapacity:3];
        [self.photoArray addObjectsFromArray:@[[NSNull null], [NSNull null], [NSNull null]]];
    } 
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.autoresizesSubviews = YES;
    self.tableView.estimatedRowHeight = 180.0f;
    
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
    
    [self navigationBarButtons];

}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    for (ALAsset *asset  in assets){
        [self.photoArray replaceObjectAtIndex:currentPhotoCount withObject:[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage]];
        currentPhotoCount++;
    }
    NSLog(@"CURRENT PHOTOS %d. Current remaining %d", currentPhotoCount, maxImageCount-currentPhotoCount);
    [self updatePhotoCount];
    [self.tableView reloadData];
    [self performSelector:@selector(scrollToBottom) withObject:nil afterDelay:0.1];
}

-(BOOL)fieldIsFilled{
    if (currentPhotoCount > 0 && currentPhotoCount <= maxImageCount){
        return YES;
    } else {
        return NO;
    }
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
    if (picker.selectedAssets.count >= (maxImageCount-currentPhotoCount))
    {
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:@"Too many photos"
                                   message:[NSString stringWithFormat:@"Select a maximum of %d photos.", maxImageCount]
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
    
    return (picker.selectedAssets.count < (maxImageCount-currentPhotoCount) && asset.defaultRepresentation != nil);
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return currentPhotoCount;
}

-(void)updatePhotoCount{
    if (currentPhotoCount <= maxImageCount){
        self.countBarButton.tintColor = [UIColor spreeDarkBlue];
    } else {
        self.countBarButton.tintColor = [UIColor spreeRed];
    }
    [self.countBarButton setTitle:[NSString stringWithFormat:@"%d", maxImageCount-currentPhotoCount] forState:UIControlStateNormal];
    [[self.navigationItem.rightBarButtonItems objectAtIndex:0] setEnabled: [self fieldIsFilled]];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    
     PhotoDisplayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nibFiles = [[NSBundle mainBundle] loadNibNamed:@"PhotoDisplayTableViewCell" owner:self options:nil];
        for(id currentObject in nibFiles){
            if ([currentObject isKindOfClass:[UITableViewCell class]]){
                cell = (PhotoDisplayTableViewCell*)currentObject;
                break;
            }
        }
    }
    
    [cell.deleteButton addTarget:self action:@selector(deleteButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    cell.deleteButton.tag = indexPath.row;
    
    if ([[self.photoArray objectAtIndex:indexPath.row] isKindOfClass:[NSNull class]]) {

    } else {
        NSLog(@"%@", [self.photoArray objectAtIndex:indexPath.row]);
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
    [self updatePhotoCount];
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

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return 100;
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

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 0){
        UIView * footer = [self.tableView headerViewForSection:0];
        PhotoSelectFooterView *custom =[[PhotoSelectFooterView alloc] init];
        if (footer == nil){
            NSArray *nibFiles = [[NSBundle mainBundle] loadNibNamed:@"PhotoSelectFooterView" owner:self options:nil];
            for(id currentObject in nibFiles){
                if ([currentObject isKindOfClass:[PhotoSelectFooterView class]]){
                    custom = currentObject;
                    custom.buttonWidthLayoutContraint.constant = self.tableView.frame.size.width/2;
                    [custom.pickPhotoButton addTarget:self action:@selector(pickPhotoButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
                    [custom.takePhotoButton addTarget:self action:@selector(takePhotoButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                }
            }
        }
        return custom;
    }
    return 0;
}

-(void)cancelWorkflow{
    if (self.postingWorkflow.post.photoArray == nil){
        currentPhotoCount = 0;
    }
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
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        [imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    [imagePickerController setDelegate:self];
    [self presentViewController:imagePickerController animated:YES completion:nil];
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (currentPhotoCount >= maxImageCount){
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:@"Too many photos"
                                   message:[NSString stringWithFormat:@"Select a maximum of %d photos.", maxImageCount]
                                  delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:@"OK", nil];
        
        [alertView show];
    } else {
        NSBlockOperation *saveImage = [NSBlockOperation blockOperationWithBlock:^{
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            NSLog(@"%@", image);
            [self.photoArray replaceObjectAtIndex:currentPhotoCount withObject:image];
        }];
        
        [saveImage setCompletionBlock:^{
            currentPhotoCount++;
            [self.tableView reloadData];
            [self updatePhotoCount];
        }];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [queue addOperation:saveImage];
    }
}


-(void)pickPhotoButtonTouched:(id)sender{
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.delegate = self;
    picker.assetsFilter = [ALAssetsFilter allPhotos];
    picker.title = @"Add a few pictures";
    
    picker.showsNumberOfAssets = YES;
    [picker.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    picker.navigationController.navigationBar.shadowImage = [UIImage new];
    picker.navigationController.view.backgroundColor = [UIColor spreeOffWhite];
    picker.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
    
    [self presentViewController:picker animated:YES completion:nil];
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
