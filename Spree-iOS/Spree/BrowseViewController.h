//
//  HomeViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 12/12/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

@interface BrowseViewController : PFQueryTableViewController {

}

@property NSArray *postTypeArray;
@property NSInteger pastPostNumber;

- (IBAction)newPostButtonPressed:(id)sender;

@end

