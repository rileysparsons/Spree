//
//  EditPostPhotoSelectViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 7/19/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "EditPostPhotoSelectViewController.h"
#import "PreviewPostViewController.h"
#import <YHRoundBorderedButton/YHRoundBorderedButton.h>

@interface EditPostPhotoSelectViewController ()

@end

@implementation EditPostPhotoSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"PHOTOS: %@", self.photoArray);
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)navigationBarButtons{
    [super navigationBarButtons];
    
    UIButton *doneButton = [[YHRoundBorderedButton alloc] init];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneWithEdit:) forControlEvents:UIControlEventTouchUpInside];
    [doneButton sizeToFit];
    [doneButton.titleLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
    [doneButton setTintColor:[UIColor spreeDarkBlue]];
    [doneButton setTitleColor:[UIColor spreeOffWhite] forState:UIControlStateHighlighted];
    
    UIBarButtonItem *countBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:super.countBarButton];
    
    [self.navigationItem setRightBarButtonItems:@[[[UIBarButtonItem alloc] initWithCustomView:doneButton], countBarButtonItem] animated:YES];

    // Override super class cancel button setup, so that the modal dismisses.
    UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    cancel.backgroundColor = [UIColor clearColor];
    cancel.tag = 1;
    [cancel setBackgroundImage:[UIImage imageNamed:@"cancelOffBlack"] forState:UIControlStateNormal];
    [cancel setBackgroundImage:[UIImage imageNamed:@"cancelHighlight"] forState:UIControlStateHighlighted];
    [cancel addTarget:self action:@selector(doneWithEdit:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancel];
}

-(void)doneWithEdit:(id)sender{
    UIButton *button = (UIButton *)sender;
    if (button.tag == 1){
        
    } else {
        NSMutableArray *fileArray = [[NSMutableArray alloc] initWithCapacity:3];
        for (id photo in self.photoArray) {
            if ([photo isKindOfClass:[UIImage class]]){
                NSData* data = UIImageJPEGRepresentation(photo, 0.5f);
                PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:data];
                [fileArray addObject:imageFile];
            }
        }
        ((PreviewPostViewController*)((UINavigationController *)self.presentingViewController).topViewController).post[PF_POST_PHOTOARRAY] = fileArray;
        [((PreviewPostViewController*)((UINavigationController *)self.presentingViewController).topViewController).tableView reloadData];
    }
    
    [self dismissViewControllerAnimated: YES completion:nil];
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
