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
#import "PostShareView.h"

@interface PostDetailTableViewController : UITableViewController <PostShareViewDelegate>

@property NSArray *fields;

@property SpreePost *post;

@property PFUser *poster;

@property BOOL hasCompletedFields;

-(void)initWithPost:(SpreePost *)post;

-(UITableViewCell *)cellForField:(NSDictionary *)field;

-(UITableViewCell *)loadPostImagesForCell:(PhotoGalleryTableViewCell *)cell;

-(void)organizeTableForFields;

@property NSArray *existingFields;
@property NSMutableArray *existingFieldsForTable;

@end
