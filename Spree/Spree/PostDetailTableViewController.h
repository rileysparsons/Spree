//
//  PostDetailTableViewController.h
//  
//
//  Created by Riley Steele Parsons on 6/9/15.
//
//

#import <UIKit/UIKit.h>
#import "SpreePost.h"
#import "PhotoGalleryTableViewCell.h"

@interface PostDetailTableViewController : UITableViewController

@property NSArray *fields;

@property SpreePost *post;

@property PFUser *poster;

-(void)initWithPost:(SpreePost *)post;

-(UITableViewCell *)cellForField:(NSString *)field;

-(UITableViewCell *)loadPostImagesForCell:(PhotoGalleryTableViewCell *)cell;

@property NSArray *existingFields;
@property NSArray *existingFieldsForTable;



@end
