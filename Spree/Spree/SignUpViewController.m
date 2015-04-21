//
//  SignUpViewController.m


#import "SignUpViewController.h"


@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.signUpView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spreeIcon"]]];

    [self.signUpView.signUpButton setTintColor:[UIColor spreeDarkBlue]];

    [self.signUpView.usernameField setTextColor:[UIColor spreeDarkBlue]];
    [self.signUpView.passwordField setTextColor:[UIColor spreeDarkBlue]];
    [self.signUpView.emailField setTextColor:[UIColor spreeDarkBlue]];
}

@end