//
//  HomeViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 12/12/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

@interface HomeViewController : UITableViewController < UITabBarDelegate, UITableViewDataSource> {

}
@property NSArray *postTypeArray;
@property NSInteger pastPostNumber;

- (IBAction)newPostButtonPressed:(id)sender;

@end

