//
//  FacebookShareView.m
//  Spree
//
//  Created by Riley Steele Parsons on 8/25/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "SinglePhotoPostShareView.h"
#import "FBSDKCoreKit/FBSDKCoreKit.h"

@implementation SinglePhotoPostShareView

-(void)initWithPost:(SpreePost *)post{
    [self circularImage];
    
    if (post.photoArray.count > 0){
        NSMutableArray *tempPhotoArray = [[NSMutableArray alloc] init];
        for (PFFile *imageFile in post.photoArray){
            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    UIImage *image = [UIImage imageWithData:data];
                    [tempPhotoArray addObject:image];
                    [self setupImageViewsWithImageArray:tempPhotoArray];
                    [self initializationComplete];
                    // image can now be set on a UIImageView
                }
            }];
        }
    } else if (post[@"location"]){
        PFGeoPoint *geoPoint = (PFGeoPoint *)post[@"location"];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
        MKPointAnnotation *locationAnnotation = [[MKPointAnnotation alloc] init];
        [locationAnnotation setCoordinate:coordinate];
        MKMapView *mapView = [[MKMapView alloc] initWithFrame:self.imageView1.frame];
        [mapView addAnnotation:locationAnnotation];
        [mapView setRegion:MKCoordinateRegionMakeWithDistance(locationAnnotation.coordinate, 1000, 1000)];
        
        MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
        options.region = mapView.region;
        options.size = mapView.frame.size;
        options.scale = [[UIScreen mainScreen] scale];
    
        MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
        [snapshotter startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
            if (error) {
                NSLog(@"[Error] %@", error);
                return;
            }
            
            UIImage *image = snapshot.image;
            self.imageView1.image = image;
            [self initializationComplete];
        }];
        
    }
    self.postAuthorLabel.adjustsFontSizeToFitWidth = YES;
    
    NSString *authorTitlePrefix;
    
    if ([post.typePointer[@"type"] isEqualToString:@"Tasks & Services"]){
        authorTitlePrefix = @"NEEDS";
    } else {
        authorTitlePrefix = @"IS SELLING";
    }
    
    if (post.user[@"fbId"]){
        NSString *graphPath = [NSString stringWithFormat:@"%@?fields=first_name", post.user[@"fbId"]];
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:graphPath parameters:nil];
        //                         Send request to Facebook
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                NSString *authorString = [NSString stringWithFormat:@"%@ %@", [result[@"first_name"] uppercaseString], authorTitlePrefix];
                self.postAuthorLabel.text = authorString;
                [self initializationComplete];
            } else {
                NSLog(@"%@",error);
            }
        }];
    } else {
        NSString *authorString = [NSString stringWithFormat:@"%@ %@", [post.user[@"username"] uppercaseString], authorTitlePrefix];
        self.postAuthorLabel.text = authorString;
        [self initializationComplete];
    }

    
    self.postDescriptionLabel.text = post.userDescription;
    self.postPriceLabel.text = [NSString stringWithFormat:@"$%@", [post.price stringValue]];
    self.postTitleLabel.text = [NSString stringWithFormat:@"A %@", post.title];
    [self initializationComplete];
    
}

-(void)setupImageViewsWithImageArray:(NSArray *)array{
    self.imageView1.image = [array objectAtIndex:0];
}


-(void)initializationComplete{

    if (self.postAuthorLabel.text.length > 1 && self.imageView1.image){
        [self.delegate viewInitializedForPost:self];
    }
}

-(void)circularImage{
    CAShapeLayer *circle = [CAShapeLayer layer];
    // Make a circular shape
    UIBezierPath *circularPath=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.postPriceBackgroundView.frame.size.width, self.postPriceBackgroundView.frame.size.height) cornerRadius:MAX(self.postPriceBackgroundView.frame.size.width, self.postPriceBackgroundView.frame.size.height)];
    
    circle.path = circularPath.CGPath;
    
    // Configure the apperence of the circle
    circle.fillColor = [UIColor spreeOffWhite].CGColor;
    circle.strokeColor = [UIColor spreeOffWhite].CGColor;
    circle.lineWidth = 0;
    self.postPriceBackgroundView.layer.mask=circle;
}


@end
