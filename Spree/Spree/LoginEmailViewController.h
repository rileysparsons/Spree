//
//  LoginInputViewController.h
//  
//
//  Created by Riley Steele Parsons on 8/2/15.
//
//

#import <UIKit/UIKit.h>
#import "LoginFieldViewController.h"
#import <JVFloatLabeledTextField.h>

@interface LoginEmailViewController : LoginFieldViewController

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *domainLabel;

@end
