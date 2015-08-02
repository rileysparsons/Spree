//
//  BaseOnboardingViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 8/2/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "BaseOnboardingViewController.h"
#import "RTWalkthroughPageViewController.h"
#import "RTWalkthroughViewController.h"
#import "FinalOnboardingViewController.h"
#import "LoginWorkflow.h"

@interface BaseOnboardingViewController ()

@end

@implementation BaseOnboardingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startOnboarding];
    
    // Do any additional setup after loading the view.
}

-(void)startOnboarding{
    UIStoryboard *stb = [UIStoryboard storyboardWithName:@"Walkthrough" bundle:nil];
    RTWalkthroughViewController *walkthrough = [stb instantiateViewControllerWithIdentifier:@"walk"];
    RTWalkthroughPageViewController *pageZero = [stb instantiateViewControllerWithIdentifier:@"walk0"];
    RTWalkthroughPageViewController *pageOne = [stb instantiateViewControllerWithIdentifier:@"walk1"];
    RTWalkthroughPageViewController *pageTwo = [stb instantiateViewControllerWithIdentifier:@"walk2"];
    FinalOnboardingViewController *final = [stb instantiateViewControllerWithIdentifier:NSStringFromClass(([FinalOnboardingViewController class]))];
    walkthrough.delegate = self;
    [walkthrough addViewController:pageOne];
    [walkthrough addViewController:pageTwo];
    [walkthrough addViewController:pageZero];
    [walkthrough addViewController:final];
    [self presentViewController:walkthrough animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)walkthroughControllerDidClose:(RTWalkthroughViewController *)controller{
    LoginWorkflow *loginWorkflow = [[LoginWorkflow alloc] init];
    [self.navigationController pushViewController:[loginWorkflow firstViewController] animated:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"%@", self.navigationController);
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
