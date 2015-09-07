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
    self.domainLabel.text = self.domain;
}

- (void)nextButtonTouched{
    [self resignFirstResponder];
    NSString *fullEmail = [NSString stringWithFormat:@"%@%@", self.textField.text, self.domain];
    self.user.username = fullEmail;
    self.user.email = fullEmail;
    self.nextButton.enabled = NO;
    if ([self.delegate logInViewController:self shouldBeginLogInWithEmail:self.textField.text]){
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"email" equalTo:fullEmail];
        [userQuery getFirstObjectInBackgroundWithBlock: ^(PFObject *result, NSError *error){
            if (result){
                [self.delegate logInViewController:self didCheckEmail:self.textField.text userExists:YES];
                self.nextButton.enabled = YES;
            } else {
                [self.delegate logInViewController:self didCheckEmail:self.textField.text userExists:NO];
                self.nextButton.enabled = YES;
            }
        }];
    } else {
        [self shakeAnimation:self.textField];
        self.nextButton.enabled = YES;
    }
}


-(void)backButtonTouched{
    [self.delegate logInViewControllerWentBackwards:self];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self nextButtonTouched];
    return YES;
}

@end
