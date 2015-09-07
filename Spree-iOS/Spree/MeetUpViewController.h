//
//  MeetUpViewController.h
//  
//
//  Created by Maxwell on 5/14/15.
//
//

#import <UIKit/UIKit.h>

@interface MeetUpViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>
@property (retain, nonatomic) NSString *groupId;
@property (retain, nonatomic) PFObject *post;
@property (retain, nonatomic) NSString *chatTitle;

@end
