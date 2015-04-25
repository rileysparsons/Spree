//
//  PostLocationViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 12/15/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class PostLocationViewController;

@protocol PostLocationViewControllerDelegate <NSObject>

@optional

-(void)postLocationViewController:(PostLocationViewController *)controller didFinishSelecting:(NSDictionary *)location;

@end

@interface PostLocationViewController : UIViewController <MKMapViewDelegate, UISearchControllerDelegate, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id <PostLocationViewControllerDelegate> postLocationDelegate;
@property NSString* locationFormerlySelected;
@property (weak, nonatomic) IBOutlet MKMapView *locationMapView;
@property (weak, nonatomic) IBOutlet UISearchBar *locationSearchBar;
- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;



@end
