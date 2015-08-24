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
    self.postMapView.delegate = self;
    self.postMapView.userInteractionEnabled = NO;
    // Initialization code
}

-(void)setLocationsFromPost:(SpreePost*)post {
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    for (id field in post[@"field"]){
        if ([field[@"dataType"] isEqualToString: @"geoType"] && post[field[@"field"]]){
            [annotations addObject:post[field[@"field"]]];
        }
    }
    [self.postMapView addAnnotations:annotations];
    [self.postMapView showAnnotations:self.postMapView.annotations animated:YES];
}

-(void)enableEditMode{
    self.editButton.hidden = NO;
}

@end
