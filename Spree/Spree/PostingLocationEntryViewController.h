//
//  PostingLocationEntryViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 8/22/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "PostingDataEntryViewController.h"

@interface PostingLocationEntryViewController : PostingDataEntryViewController {
    @private
        CGRect _searchTableViewRect;
}
@property (weak, nonatomic) IBOutlet MKMapView *locationMapView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIImageView *accentIcon;
@property (weak, nonatomic) IBOutlet UIView *containingTopView;
@property PFGeoPoint *selectedGeoPoint;

@property NSDictionary *selectedLocation;
@property (nonatomic, strong) UISearchController *searchController;
@property (strong, nonatomic) MKLocalSearch *localSearch;
@property (strong, nonatomic) MKLocalSearchResponse *results;

@end
