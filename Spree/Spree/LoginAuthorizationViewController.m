//
//  LoginAuthorizationViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 8/2/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "LoginAuthorizationViewController.h"
#import "AppDelegate.h"
#import "PostTableViewController.h"

@interface LoginAuthorizationViewController ()

@end

@implementation LoginAuthorizationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 40)];
    cancel.backgroundColor = [UIColor clearColor];
    cancel.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cancel setImage:[UIImage imageNamed:@"backNormal_Dark"] forState:UIControlStateNormal];
    [cancel setImage:[UIImage imageNamed:@"backHighlight_Dark"] forState:UIControlStateHighlighted];
    [cancel addTarget:self action:@selector(backButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancel];
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)didCompleteWorkflow:(LoginWorkflow *)loginWorkflow{
    NSLog(@"%@", self.navigationController.presentingViewController);
    UIStoryboard *stb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    PostTableViewController *postTableViewController = [stb instantiateInitialViewController];
    [UIView transitionWithView:appDelegate.window
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{ appDelegate.window.rootViewController = postTableViewController; }
                    completion:nil];
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)backButtonTouched{
    self.loginWorkflow.step--;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)authorizeButtonTapped:(id)sender {
    if (self.loginWorkflow.viewControllersForFields.count <= (self.loginWorkflow.step+1)){
        [self.loginWorkflow completeWorkflow];
    } else {
        [self.navigationController pushViewController:[self.loginWorkflow nextViewController] animated:YES];
    }
}
@end
