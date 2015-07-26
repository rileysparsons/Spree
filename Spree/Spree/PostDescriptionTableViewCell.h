//
//  PostDescriptionTableViewCell.h
//  
//
//  Created by Riley Steele Parsons on 7/19/15.
//
//

#import <UIKit/UIKit.h>
#import "SpreePost.h"

@interface PostDescriptionTableViewCell : UITableViewCell

-(void)setDescriptionTextViewForPost:(SpreePost *)post;

@property (weak, nonatomic) IBOutlet UIButton *editDescriptionButton;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@end
