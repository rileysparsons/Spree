//
//  PostTypeSelectionTableViewCell.h
//  
//
//  Created by Riley Steele Parsons on 6/28/15.
//
//

#import <UIKit/UIKit.h>

@interface PostTypeSelectionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *typeImage;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;

-(void)initWithObject:(PFObject *)type;

@end
