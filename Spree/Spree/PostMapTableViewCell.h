//
//  PostMapTableViewCell.h
//  
//
//  Created by Riley Steele Parsons on 8/23/15.
//
//

#import <UIKit/UIKit.h>
#import "SpreePost.h"

@interface PostMapTableViewCell : UITableViewCell <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *postMapView;
@property (weak, nonatomic) IBOutlet UIButton *editButton;

-(void)setLocationsFromPost:(SpreePost*)post;
-(void)enableEditMode;

@end
