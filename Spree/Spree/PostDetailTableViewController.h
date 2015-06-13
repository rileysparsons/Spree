//
//  PostDetailTableViewController.h
//  
//
//  Created by Riley Steele Parsons on 6/9/15.
//
//

#import <UIKit/UIKit.h>
#import "SpreePost.h"

@interface PostDetailTableViewController : UITableViewController

@property NSArray *fields;

@property SpreePost *post;

@property PFUser *poster;

@end
