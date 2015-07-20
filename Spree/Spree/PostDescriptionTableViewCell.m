//
//  PostDescriptionTableViewCell.m
//  
//
//  Created by Riley Steele Parsons on 7/19/15.
//
//

#import "PostDescriptionTableViewCell.h"


@implementation PostDescriptionTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

-(void)setDescriptionTextViewForPost:(SpreePost *)post{
    self.descriptionTextView.text = post.userDescription;
    self.descriptionTextView.scrollEnabled = NO;
    [self.descriptionTextView sizeToFit];
}

-(void)enableEditMode{
    self.editDescriptionButton.hidden = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
