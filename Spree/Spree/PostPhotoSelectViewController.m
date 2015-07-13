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
#import <QBImagePickerController/QBImagePickerController.h>

@interface PostPhotoSelectViewController () <QBImagePickerControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property NSMutableArray *photoArray;

@end

@implementation PostPhotoSelectViewController

int maxImageCount = 3;

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
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
    
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars=NO;
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    
    
    QBImagePickerController *picker = [QBImagePickerController new];
    picker.delegate = self;
    picker.prompt = @"Add a few pictures";
    picker.navigationItem.title = @"test";
    picker.navigationController.navigationItem.title = @"test";
    
    picker.allowsMultipleSelection = YES;
    picker.maximumNumberOfSelection = 6;
    picker.showsNumberOfSelectedAssets = YES;
    [picker.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    
    picker.mediaType = QBImagePickerMediaTypeImage;
    [picker.navigationItem setTitle:@"Photos"];
    
    [self presentViewController:picker animated:YES completion:NULL];
    picker.navigationItem.title = @"Test";
    picker.navigationController.navigationBar.shadowImage = [UIImage new];
    picker.navigationController.view.backgroundColor = [UIColor spreeOffWhite];
    picker.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];

    // Do any additional setup after loading the view.
}

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets {
    for (PHAsset *asset in assets) {
        // Do something with the asset
        PHContentEditingInputRequestOptions *editOptions = [[PHContentEditingInputRequestOptions alloc]init];
        editOptions.networkAccessAllowed = YES;
        [asset requestContentEditingInputWithOptions:editOptions completionHandler:^(PHContentEditingInput *contentEditingInput, NSDictionary *info) {
            [self.photoArray replaceObjectAtIndex:[assets indexOfObject:asset] withObject:contentEditingInput.displaySizeImage];
            [self.tableView reloadData];
            NSLog(@"%@", self.photoArray);
        }];
    }

    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return maxImageCount;
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
        [cell emptyCell];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
