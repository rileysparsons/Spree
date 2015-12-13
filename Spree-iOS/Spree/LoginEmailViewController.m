//
//  LoginInputViewController.m
//  
//
//  Created by Riley Steele Parsons on 8/2/15.
//
//

#import "LoginEmailViewController.h"
#import "SpreeViewModelServices.h"
#import "SpreeViewModelServicesImpl.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface LoginEmailViewController ()

@property id<SpreeViewModelServices> viewModelServices;

@end

@implementation LoginEmailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self.textField addRightButtonOnKeyboardWithText:@"Next" target:self action:@selector(nextBarButtonItemTouched:) shouldShowPlaceholder:YES];
    
    self.nextButton = [[UIButton alloc] init];
    [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [self.nextButton addTarget:self action:@selector(nextButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [self.nextButton sizeToFit];
    [self.nextButton.titleLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
    [self.nextButton setTintColor:[UIColor spreeDarkBlue]];
    [self.nextButton setTitleColor:[UIColor spreeDarkBlue] forState:UIControlStateNormal];
    [self.navigationItem setRightBarButtonItems:@[[[UIBarButtonItem alloc] initWithCustomView:self.nextButton]] animated:YES];
    
    
    // Do any additional setup after loading the view.
    self.viewModelServices = [[SpreeViewModelServicesImpl alloc] init];
    self.viewModel = [[EnterEmailViewModel alloc] initWithServices:self.viewModelServices];
    
    self.textField.delegate = self;
    self.textField.returnKeyType = UIReturnKeyGo;
    self.titleView.text = @"Log in";
    [self bindToViewModel];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.domainLabel.text = self.domain;
}

-(void)bindToViewModel{
    RAC(self.viewModel, email) = self.textField.rac_textSignal;
    
    self.nextButton.rac_command = self.viewModel.checkForExistingUser;
    [[self.viewModel.checkForExistingUser.executionSignals concat]
     subscribeNext:^(id value) {
         NSLog(@"Value: %@", value);
        [self.delegate logInViewController:self didCheckEmail:self.textField.text userExists:YES];
    }];
    
    [self.viewModel.checkForExistingUser.errors
     subscribeNext:^(NSError *error) {
        if (error.code == 101){
            [self.delegate logInViewController:self didCheckEmail:self.textField.text userExists:NO];
        } else {
            NSLog(@"%@", error);
        }
    }];
}

//- (void)nextButtonTouched{
//    [self resignFirstResponder];
//    NSString *fullEmail = [NSString stringWithFormat:@"%@%@", self.textField.text, self.domain];
//    self.user.username = fullEmail;
//    self.user.email = fullEmail;
//    self.nextButton.enabled = NO;
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    if ([self.delegate logInViewController:self shouldBeginLogInWithEmail:self.textField.text]){
//        PFQuery *userQuery = [PFUser query];
//        [userQuery whereKey:@"email" equalTo:fullEmail];
//        [userQuery getFirstObjectInBackgroundWithBlock: ^(PFObject *result, NSError *error){
//                if (result){
//                    hud.labelText = @"Welcome back.";
//                    self.nextButton.enabled = YES;
//                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.75 * NSEC_PER_SEC);
//                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                        // Do something...
//                        [hud hide:YES];
//                        [self.delegate logInViewController:self didCheckEmail:self.textField.text userExists:YES];
//                    });
//                    
//                } else {
//                    hud.labelText = @"Welcome to Spree!";
//                    self.nextButton.enabled = YES;
//                    
//                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.75 * NSEC_PER_SEC);
//                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                        // Do something...
//                        [hud hide:YES];
//                        [self.delegate logInViewController:self didCheckEmail:self.textField.text userExists:NO];
//                    });
//                }
//        }];
//    } else {
//        hud.labelText = @"Something went wrong";
//        hud.detailsLabelText = @"Check your email and try again.";
//        [self shakeAnimation:self.textField];
//        [hud hide:YES afterDelay:0.5f];
//        self.nextButton.enabled = YES;
//    }
//}


-(void)backButtonTouched{
    [self.delegate logInViewControllerWentBackwards:self];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self nextButtonTouched];
    return YES;
}

@end
