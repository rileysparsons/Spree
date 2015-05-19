//
//  SignUpViewController.m


#import "SignUpViewController.h"


@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spreeLogoWithName"]];
    logoView.contentMode = UIViewContentModeScaleAspectFit;

    [self.signUpView setLogo:logoView];

    [self.signUpView.signUpButton setTintColor:[UIColor spreeDarkBlue]];
    self.signUpView.backgroundColor = [UIColor whiteColor];

    [self.signUpView.usernameField setTextColor:[UIColor spreeDarkBlue]];
    [self.signUpView.passwordField setTextColor:[UIColor spreeDarkBlue]];
    [self.signUpView.emailField setTextColor:[UIColor spreeDarkBlue]];
    self.signUpView.emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email (\".edu\" is highly suggested)" attributes: @{NSFontAttributeName : [UIFont systemFontOfSize:13.0]}];
    [self.signUpView.signUpButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.signUpView.signUpButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self.signUpView.signUpButton setBackgroundColor:[UIColor spreeBabyBlue]];
}


-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self.signUpView.logo setFrame:CGRectMake(0, 30, self.signUpView.bounds.size.width, 125)];
    
    [self.signUpView.usernameField setFrame:CGRectMake(35.0f, 30+150+30, 250.0f, 50.0f)];
    [self.signUpView.passwordField setFrame:CGRectMake(35.0f, 30+150+30+50, 250.0f, 50.0f)];
    [self.signUpView.emailField setFrame:CGRectMake(35.0f, 30+150+30+50+50, 250.0f, 50.0f)];
    [self.signUpView.signUpButton setFrame:CGRectMake(35.0f, 30+150+20+70+50+60+60, 250.0f, 40.0f)];
}


@end