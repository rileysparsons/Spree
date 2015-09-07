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

@protocol LoginEmailViewControllerDelegate;

@interface LoginEmailViewController : LoginFieldViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *domainLabel;
@property NSString *domain;
@property PFUser *user;
@property id<LoginEmailViewControllerDelegate> delegate;

@end

@protocol LoginEmailViewControllerDelegate <NSObject>

@optional

///--------------------------------------
/// @name Customizing Behavior
///--------------------------------------

- (BOOL)logInViewController:(LoginEmailViewController *)logInController
shouldBeginLogInWithEmail:(NSString *)email;

///--------------------------------------
/// @name Responding to Actions
///--------------------------------------

- (void)logInViewController:(LoginEmailViewController *)logInController didCheckEmail:(NSString *)email userExists:(BOOL)exists;


- (void)logInViewController:(LoginEmailViewController *)logInController
    didFailToCheckEmailWithError:(NSError *)error;

- (void)logInViewControllerWentBackwards:(LoginEmailViewController *)logInController;

@end
