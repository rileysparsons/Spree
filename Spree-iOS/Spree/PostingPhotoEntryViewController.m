//
//  PostPhotoSelectViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 7/11/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "PostingPhotoEntryViewController.h"
#import "PhotoDisplayTableViewCell.h"
#import "PhotoSelectFooterView.h"
#import "AddPhotoHeaderView.h"
#import "UIColor+SpreeColor.h"
#import "UIImage+ResizeAdditions.h"
#import <CTAssetsPickerController/CTAssetsPickerController.h>

@interface PostingPhotoEntryViewController () <CTAssetsPickerControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UIAlertViewDelegate, UITableViewDataSource>

@property UIButton *nextButton;

@end

@implementation PostingPhotoEntryViewController

- (void)navigationBarButtons {
    UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 40)];
    cancel.backgroundColor = [UIColor clearColor];
    cancel.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cancel setImage:[UIImage imageNamed:@"backNormal_Dark"] forState:UIControlStateNormal];
    [cancel setImage:[UIImage imageNamed:@"backHighlight_Dark"] forState:UIControlStateHighlighted];
    [cancel addTarget:self action:@selector(cancelWorkflow) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancel];

    self.nextButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 40)];
    self.nextButton.backgroundColor = [UIColor clearColor];
    [self.nextButton setImage:[UIImage imageNamed:@"forwardNormal_Dark"] forState:UIControlStateNormal];
    [self.nextButton setImage:[UIImage imageNamed:@"forwardHighlight_Dark"] forState:UIControlStateHighlighted];
    self.nextButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.nextButton addTarget:self action:@selector(nextBarButtonItemTouched:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *nextBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.nextButton];
    self.nextButton.rac_command = self.viewModel.nextCommand;
    
    [self.navigationItem setRightBarButtonItems:@[nextBarButtonItem] animated:YES];
}

-(void)bindToViewModel {
    
    [self.viewModel.photoSelected.executionSignals subscribeNext:^(id x) {
        UIAlertView *deletePhotoAlert = [[UIAlertView alloc] initWithTitle:@"Delete Photo?" message:@"Are you sure you want to delete this photo?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Confirm", nil];
        [deletePhotoAlert show];
    }];
    
    @weakify(self)
    [self.viewModel.tableViewNeedsUpdateCommand.executionSignals subscribeNext:^(id x) {
        @strongify(self)
        [self.tableView reloadData];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];

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
    
    [self bindToViewModel];
    self.tableView.delegate = self;
    
    self.navigationController.navigationBar.backgroundColor = [UIColor spreeOffWhite];
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
    
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars=NO;
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    [self navigationBarButtons];

    self.header = [[AddPhotoHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 200)];
    [self.header layoutSubviews];
    self.tableView.tableHeaderView = self.header;

}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    PHImageRequestOptions *options =[[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    for (PHAsset *asset  in assets){
        PHImageManager *manager = [PHImageManager defaultManager];
        [manager requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info) {
            [self.viewModel.files addObject:[NSData dataWithContentsOfURL:[info objectForKey:@"PHImageFileURLKey"]]];
        }];
    }
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


- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(PHAsset *)asset
{
    if (picker.selectedAssets.count >= self.viewModel.maxPhotos)
    {
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:@"Too many photos"
                                   message:[NSString stringWithFormat:@"Select a maximum of %d photos.", self.viewModel.maxPhotos]
                                  delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:@"OK", nil];
        
        [alertView show];
    }
    
    return (picker.selectedAssets.count < self.viewModel.maxPhotos);
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.viewModel.files.count;
}

-(void)updatePhotoCount{
    if (self.viewModel.remainingPhotos >= 0){
        self.countBarButton.tintColor = [UIColor spreeDarkBlue];
    } else {
        self.countBarButton.tintColor = [UIColor spreeRed];
    }
    [self.countBarButton setTitle:[NSString stringWithFormat:@"%d", self.viewModel.remainingPhotos] forState:UIControlStateNormal];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
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
    cell.deleteButton.tag = indexPath.row;
    cell.deleteButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(UIButton *button) {
        [self.viewModel.files removeObjectAtIndex:button.tag];
        return [RACSignal return:nil];
    }];
    [cell bindViewModel:[self.viewModel.files objectAtIndex:indexPath.row]];
    
    CGSize sysSize = [cell.contentView systemLayoutSizeFittingSize:CGSizeMake(self.tableView.bounds.size.width, CGFLOAT_MAX)];
    cell.contentView.bounds = CGRectMake(0,0, sysSize.width, sysSize.height);
    [cell.contentView layoutIfNeeded];
    
    return cell;
}

//-(void)deleteButtonTouched:(id)sender{
//    
//    NSInteger indexOfDeletedPhoto = [(UIButton *)sender tag];
//    
//    [self.viewModel.files removeObjectAtIndex:indexOfDeletedPhoto];
//    [self.viewModel.files insertObject:[NSNull null] atIndex:self.viewModel.files.count];
//    currentPhotoCount--;
//    [self updatePhotoCount];
//    [self.tableView reloadData];
//}

//-(void)addPhotoButtonTouched:(id)sender{
//}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return 100;
    }
    return 0;
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 0){
        return [self tableViewFooter];
    }
    return 0;
}

-(void)cancelWorkflow{
    self.postingWorkflow.step--;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nextBarButtonItemTouched:(id)sender{
//    NSLog(@"PHOTO ARRAY %@", self.photoArray);
//    self.postingWorkflow.photosForDisplay = self.photoArray;
//    self.postingWorkflow.post.photoArray = self.fileArray;
//    [self.postingWorkflow.post[@"completedFields"] addObject: self.fieldDictionary];
//    self.postingWorkflow.step++;
//    UIViewController *nextViewController =[self.postingWorkflow nextViewController];
//    [self.navigationController pushViewController:nextViewController animated:YES];
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
    if (self.viewModel.remainingPhotos == 0){
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:@"Too many photos"
                                   message:[NSString stringWithFormat:@"Select a maximum of %d photos.", self.viewModel.maxPhotos]
                                  delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:@"OK", nil];
        
        [alertView show];
    } else {
        NSBlockOperation *saveImage = [NSBlockOperation blockOperationWithBlock:^{
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            NSData* data = UIImageJPEGRepresentation(image, 0.5f);
            PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:data];
            [self.viewModel.files addObject:imageFile];
        }];
        
        [saveImage setCompletionBlock:^{
        
        }];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [queue addOperation:saveImage];
    }
}


-(void)pickPhotoButtonTouched:(id)sender{
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // init picker
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            [picker.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
            picker.navigationController.navigationBar.shadowImage = [UIImage new];
            picker.navigationController.view.backgroundColor = [UIColor spreeOffWhite];
            picker.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
            [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];

            picker.title = @"Add a few pictures";
            // set delegate
            picker.delegate = self;
            picker.showsNumberOfAssets = YES;
            // present picker
            [self presentViewController:picker animated:YES completion:nil];
        });
    }];
}

//-(void)getChangesToPost{
//    currentPhotoCount = 0;
//    if (self.postingWorkflow.post.photoArray){
//        
//        for (PFFile *file in self.postingWorkflow.post.photoArray) {
//            [self.fileArray replaceObjectAtIndex:[self.postingWorkflow.post.photoArray indexOfObject:file] withObject:file];
//        }
//        
//        for (UIImage *image in self.postingWorkflow.photosForDisplay){
//            if ([image isKindOfClass:[UIImage class]]){
//                [self.photoArray replaceObjectAtIndex:[self.postingWorkflow.photosForDisplay indexOfObject:image] withObject:image];
//                currentPhotoCount++;
//            }
//            
//        }
//        
//        [self.tableView reloadData];
//    }
//}

- (PFFile *)compressAndSaveImage:(UIImage *)anImage {
    UIImage *resizedImage = [anImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(560.0f, 560.0f) interpolationQuality:kCGInterpolationHigh];
//    UIImage *thumbnailImage = [anImage thumbnailImage:86.0f transparentBorder:0.0f cornerRadius:10.0f interpolationQuality:kCGInterpolationDefault];
    
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.8f);
    
    PFFile *file = [PFFile fileWithData:imageData];
    
    
    
//    NSData *thumbnailImageData = UIImagePNGRepresentation(thumbnailImage);
    
    
    
    return file;
}

-(PhotoSelectFooterView *)tableViewFooter{
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

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1){
        [self.viewModel.deletePhoto execute:self.tableView.indexPathForSelectedRow];
    }
    
}

@end
