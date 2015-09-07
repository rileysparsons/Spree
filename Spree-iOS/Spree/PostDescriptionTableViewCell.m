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
    [self.editButtonWidth setConstant:0.0f];
    [self.editDescriptionButton setHidden:YES];
//    CGSize sizeThatShouldFitTheContent = [self.descriptionTextView sizeThatFits:CGSizeMake(self.frame.size.width, MAXFLOAT)];
//    self.textViewHeight.constant = sizeThatShouldFitTheContent.height;
    
    [self layoutIfNeeded];
}

-(void)setDescriptionTextViewForPost:(SpreePost *)post{
    
    self.descriptionTextView.scrollEnabled = NO;
    self.descriptionTextView.text = post.userDescription;
//    CGSize sizeThatShouldFitTheContent = [self.descriptionTextView sizeThatFits:CGSizeMake(self.frame.size.width, MAXFLOAT)];
//    self.textViewHeight.constant = sizeThatShouldFitTheContent.height;
}

-(void)enableEditMode{
    [self.editButtonWidth setConstant:46.0f];
    
//    CGSize sizeThatShouldFitTheContent = [self.descriptionTextView sizeThatFits:CGSizeMake(self.frame.size.width, MAXFLOAT)];
//    self.textViewHeight.constant = sizeThatShouldFitTheContent.height;

    
    self.editDescriptionButton.hidden = NO;
    [self layoutIfNeeded];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
