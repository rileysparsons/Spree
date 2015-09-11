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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)shareButtonPressed:(id)sender {
    NSLog(@"shareButton pressed");
    
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"article_id"] = @"1234";
    params[@"$og_title"] = @"MyApp is disrupting apps";
    params[@"$og_image_url"] = @"http://yoursite.com/pics/987666.png";
    params[@"$desktop_url"] = @"mysite.com/article1234";
    
    [[Branch getInstance] getShortURLWithParams:params andChannel:@"sms" andFeature:BRANCH_FEATURE_TAG_SHARE andCallback:^(NSString *url, NSError *error) {
        if (!error) {
            
            //NSString *texttoshare = @"Check out Spree: %@";
            NSString *texttoshare = [NSString stringWithFormat:@"Check out Spree: %@", url];
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
