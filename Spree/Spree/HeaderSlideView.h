//
//  HeaderSlideView.h
//  
//
//  Created by Riley Steele Parsons on 7/31/15.
//
//

#import <UIKit/UIKit.h>

@interface HeaderSlideView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UILabel *slideTitle;
@property (nonatomic, strong) HeaderSlideView *customView;


-(void)setTitleWithString:(NSString *)title;
-(void)setBackgroundImageWithImage:(UIImage *)image;

@end
