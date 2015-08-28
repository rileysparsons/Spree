//
//  PostMapTableViewCell.m
//  
//
//  Created by Riley Steele Parsons on 8/23/15.
//
//

#import "PostMapTableViewCell.h"
#import "SpreePost.h"

@implementation PostMapTableViewCell 


- (void)awakeFromNib {
    self.editButton.hidden = YES;
    self.postMapView.delegate = self;
    self.postMapView.userInteractionEnabled = NO;
    // Initialization code
}

-(void)setLocationsFromPost:(SpreePost*)post {
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    for (id field in post[@"completedFields"]){
        NSLog(@"Field %@ Type %@", post[field[@"field"]], field[@"dataType"]);
        if ([field[@"dataType"] isEqualToString: @"geoPoint"] && post[field[@"field"]]){
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            PFGeoPoint *geopoint = post[field[@"field"]];
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(geopoint.latitude, geopoint.longitude);
            [annotation setCoordinate: coordinate];
            [annotation setTitle:field[@"field"]];
            [annotations addObject:annotation];
        }
    }
    [self.postMapView removeAnnotations:self.postMapView.annotations];
    [self.postMapView addAnnotations:annotations];
    [self.postMapView showAnnotations:self.postMapView.annotations animated:NO];
}

-(void)enableEditMode{
    self.editButton.hidden = NO;
}

@end
