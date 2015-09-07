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
@property (weak, nonatomic) IBOutlet UILabel *slideSubtitle;


-(void)setTitleWithString:(NSString *)title;
-(void)setBackgroundImageWithImage:(UIImage *)image;

-(void)setupForMetadata:(NSDictionary *)metadata;

@end
