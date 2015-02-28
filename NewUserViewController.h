//
//  NewUserViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 12/21/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TPKeyboardAvoiding/TPKeyboardAvoidingScrollView.h>

@class NewUserViewController;

@protocol NewUserViewControllerDelegate <NSObject>

- (void)newUserViewControllerDidSignup:(NewUserViewController *)controller;

@end

@interface NewUserViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, weak) id<NewUserViewControllerDelegate> delegate;
- (IBAction)setUpButtonPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *finishButton;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextView;
@property (weak, nonatomic) IBOutlet UITextField *emailTextView;

@property (weak, nonatomic) IBOutlet UILabel *requiredPhoneNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *requiredEmailLabel;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *keyboardAvoidingView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

-(void)processFieldEntries;

@end
