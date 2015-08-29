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
#import "MessageUI/MessageUI.h"

@interface PostDetailTableViewController : UITableViewController <MFMessageComposeViewControllerDelegate> {
    
}

@property NSArray *fields;

@property SpreePost *post;

@property PFUser *poster;

-(UITableViewCell *)cellForField:(NSString *)field;

-(UITableViewCell *)loadPostImagesForCell:(PhotoGalleryTableViewCell *)cell;


@end
