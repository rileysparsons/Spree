//
//  PostTypeViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 12/17/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface PostTypeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property NSString *postType;

@property (weak, nonatomic) IBOutlet MKMapView *postMapView;
@property (weak, nonatomic) IBOutlet UITableView *postTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedViewControl;
@property UISearchBar *searchBar;
@property UISearchDisplayController *postSearchDisplayController;

- (IBAction)indexChanged:(id)sender;

@end
