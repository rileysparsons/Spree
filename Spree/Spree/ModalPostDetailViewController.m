//
//  ModalPostDetailViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 9/4/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "ModalPostDetailViewController.h"

@interface ModalPostDetailViewController ()

@end

@implementation ModalPostDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self dismissButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissButton{
    UIButton *close = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 40)];
    close.backgroundColor = [UIColor clearColor];
    close.imageView.contentMode = UIViewContentModeScaleAspectFit;
    close.frame = CGRectMake(0, 0, 36, 36);
    close.clipsToBounds = YES;
    [close setImage:[UIImage imageNamed:@"cancelOffBlack"] forState:UIControlStateNormal];
    [close setImage:[UIImage imageNamed:@"cancelHighlight"] forState:UIControlStateHighlighted];
    [close addTarget:self action:@selector(dismissButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:close];
}

-(void)dismissButtonTouched{
    [self dismissViewControllerAnimated:YES completion:nil];
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
