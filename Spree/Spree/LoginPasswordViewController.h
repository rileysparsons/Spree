//
//  LoginPasswordViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 8/2/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginFieldViewController.h"
#import <JVFloatLabeledTextField/JVFloatLabeledTextField.h>

@interface LoginPasswordViewController : LoginFieldViewController

@property (weak, nonatomic) IBOutlet UITextField *textField;

@end
