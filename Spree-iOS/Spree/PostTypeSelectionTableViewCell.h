//
//  PostTypeSelectionTableViewCell.h
//  
//
//  Created by Riley Steele Parsons on 6/28/15.
//
//

#import <UIKit/UIKit.h>
#import "CEReactiveView.h"

@interface PostTypeSelectionTableViewCell : UITableViewCell <CEReactiveView>

@property (weak, nonatomic) IBOutlet UIImageView *typeImage;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UIView *iconBackground;

-(void)bindViewModel:(id)viewModel;

@end
