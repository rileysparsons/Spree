//
//  LoginInputViewController.h
//  
//
//  Created by Riley Steele Parsons on 8/2/15.
//
//

#import <UIKit/UIKit.h>
#import "LoginWorkflow.h"

@interface LoginInputViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property LoginWorkflow *loginWorkflow;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
- (IBAction)doneButtonTapped:(id)sender;

@end
