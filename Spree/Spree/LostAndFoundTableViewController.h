//
//  LostAndFoundTableViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 12/20/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LostAndFoundTableViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>

@property UISearchBar *searchBar;
@property UISearchDisplayController *postSearchDisplayController;

@end
