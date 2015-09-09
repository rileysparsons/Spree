//
//  AlternateLoginViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 9/8/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "AlternateLoginViewController.h"
#import "AppDelegate.h"
#import "PostTableViewController.h"


@interface AlternateLoginViewController ()

@end

@implementation AlternateLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)showMeButtonTouched:(id)sender {
    if (self.emailTextView.text.length > 0){
        NSLog(@"%@", [PFUser currentUser]);
        [PFAnonymousUtils logInWithBlock:^(PFUser *user, NSError *error){
            if (error){
                NSLog(@"%@", error);
            } else {
                NSLog(@"%@", user);
            }
            user[@"email"] = self.emailTextView.text;
            user[@"network"] = @"DEMO";
            [user saveInBackgroundWithBlock:^(BOOL success, NSError *error){
                [self closeOnboarding];
            }];
        }];
    }
}

-(void)closeOnboarding{
    UIStoryboard *stb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    PostTableViewController *postTableViewController = [stb instantiateInitialViewController];
    [UIView transitionWithView:appDelegate.window
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{ appDelegate.window.rootViewController = postTableViewController; }
                    completion:nil];
}

@end
