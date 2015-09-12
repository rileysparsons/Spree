//
//  ReferralViewController.m
//  Spree
//
//  Created by Hamilton Coke on 9/10/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "ReferralViewController.h"
#import "Branch.h"


@interface ReferralViewController ()

@end

@implementation ReferralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Spree Referral Program";
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)shareButtonPressed:(id)sender {
    NSLog(@"shareButton pressed");
    
    [[Branch getInstance] getShortURLWithParams:nil andChannel:@"sms" andFeature:BRANCH_FEATURE_TAG_SHARE andCallback:^(NSString *url, NSError *error) {
        if (!error) {
            
            //NSString *texttoshare = @"Check out Spree: %@";
            NSString *texttoshare = [NSString stringWithFormat:@"Check out Spree. It's a iPhone app that helps students sell goods and services to one another. %@", url];
            //UIImage *imagetoshare = spreeLogoSmall; //this is your image to share
            NSArray *activityItems = @[texttoshare];
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
            activityVC.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePrint];
            [self presentViewController:activityVC animated:TRUE completion:nil];
        }
    }];
    
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
