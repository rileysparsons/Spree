//
//  PostTypeSelectionTableViewCell.m
//  
//
//  Created by Riley Steele Parsons on 6/28/15.
//
//

#import "PostTypeSelectionTableViewCell.h"
#import "AppConstant.h"


@implementation PostTypeSelectionTableViewCell


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//- (void)initWithObject:(PFObject *)type{
//    self.typeLabel.text = type[@"type"];
//    [self setTypeImageforType:type[@"type"]];
//}

//- (void)setTypeImageforType:(NSString *)type{
//    if ([type isEqualToString:POST_TYPE_BOOKS]){
//
//    } else if ([type isEqualToString:POST_TYPE_CLOTHING]){
//        
//    } else if ([type isEqualToString:POST_TYPE_ELECTRONICS]){
//        
//    } else if ([type isEqualToString:POST_TYPE_FURNITURE]){
//        
//    } else if ([type isEqualToString:POST_TYPE_TASK]){
//        
//    } else if ([type isEqualToString:POST_TYPE_TICKETS]){
//        
//    }
//}

@end
