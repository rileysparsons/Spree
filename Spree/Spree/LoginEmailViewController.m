//
//  LoginInputViewController.m
//  
//
//  Created by Riley Steele Parsons on 8/2/15.
//
//

#import "LoginEmailViewController.h"

@interface LoginEmailViewController ()

@end

@implementation LoginEmailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self.textField addRightButtonOnKeyboardWithText:@"Next" target:self action:@selector(nextBarButtonItemTouched:) shouldShowPlaceholder:YES];
    
    // Do any additional setup after loading the view.
    self.textField.delegate = self;
    self.textField.returnKeyType = UIReturnKeyGo;
    self.titleView.text = @"Log in";
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSString *domainName = [NSString stringWithFormat:@"@%@.edu", self.loginWorkflow.campus[@"networkCode"]];
    self.domainLabel.text = domainName;
}

- (void)nextButtonTouched{
    [self resignFirstResponder];
    if (self.textField.text && self.textField.text.length != 0) {
        NSString *fullEmail = [NSString stringWithFormat:@"%@%@", self.textField.text, self.domainLabel.text];
        NSLog(@"%@", fullEmail);
        [self.loginWorkflow setEmailForUser:fullEmail];
        if (self.loginWorkflow.viewControllersForFields.count <= (self.loginWorkflow.step+1)){
            [self.loginWorkflow completeWorkflow];
        } else {
            [self.navigationController pushViewController:[self.loginWorkflow nextViewController] animated:YES];
        }
    } else {
        [self shakeAnimation:self.textField];
//        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
//                                    message:@"Make sure you fill out all of the information!"
//                                   delegate:nil
//                          cancelButtonTitle:@"ok"
//                          otherButtonTitles:nil] show];
        
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self nextButtonTouched];
    return YES;
}


@end
