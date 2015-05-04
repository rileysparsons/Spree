//
//  SignUpViewController.m


#import "SignUpViewController.h"


@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spreeIcon"]];
    logoView.contentMode = UIViewContentModeScaleAspectFit;

    [self.signUpView setLogo:logoView];

    [self.signUpView.signUpButton setTintColor:[UIColor spreeDarkBlue]];
    self.signUpView.backgroundColor = [UIColor whiteColor];

    [self.signUpView.usernameField setTextColor:[UIColor spreeDarkBlue]];
    [self.signUpView.passwordField setTextColor:[UIColor spreeDarkBlue]];
    [self.signUpView.emailField setTextColor:[UIColor spreeDarkBlue]];
    
    [self.signUpView.signUpButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.signUpView.signUpButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self.signUpView.signUpButton setBackgroundColor:[UIColor spreeBabyBlue]];
}


-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self.signUpView.logo setFrame:CGRectMake(0, 30, self.signUpView.bounds.size.width, 125)];
    
}



@end