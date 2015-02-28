//
//  HomeViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 12/12/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>


@interface HomeViewController : UITableViewController <MBProgressHUDDelegate, UITabBarDelegate, UITableViewDataSource> {
    MBProgressHUD *loadingHUD;
    MBProgressHUD *HUD;
}
@property NSArray *postTypeArray;
@property NSInteger pastPostNumber;

- (IBAction)newPostButtonPressed:(id)sender;

@end

