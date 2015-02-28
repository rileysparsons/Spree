//
//  NewUserViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/21/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import "NewUserViewController.h"
#import <Facebook-iOS-SDK/FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import "UIColor+SpreeColor.h"

@interface NewUserViewController ()

@end

@implementation NewUserViewController

- (void)viewDidLoad {
    [_keyboardAvoidingView contentSizeToFit];
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _requiredPhoneNumberLabel.alpha = 0;
    _requiredEmailLabel.alpha = 0;
    _requiredEmailLabel.text = @"Required";
    _requiredEmailLabel.textColor = [UIColor spreeRed];
    _requiredPhoneNumberLabel.text = @"Required";
    _requiredPhoneNumberLabel.textColor = [UIColor spreeRed];
    
    [self animatePhoneNumberRequired];
    [self animateEmailRequired];
    
    _phoneNumberTextView.delegate = self;
    _emailTextView.delegate = self;

    UIView *leftViewPhone = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, _phoneNumberTextView.frame.size.height)];
    _phoneNumberTextView.leftView = leftViewPhone;
    _phoneNumberTextView.leftViewMode = UITextFieldViewModeAlways;
    _phoneNumberTextView.layer.cornerRadius = _emailTextView.frame.size.height/2;
    _phoneNumberTextView.layer.masksToBounds=YES;
    _phoneNumberTextView.layer.borderColor=[[UIColor whiteColor]CGColor];
    _phoneNumberTextView.layer.borderWidth= 1.0f;

    UIView *leftViewEmail = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, _emailTextView.frame.size.height)];
    _emailTextView.leftView = leftViewEmail;
    _emailTextView.leftViewMode = UITextFieldViewModeAlways;
    _emailTextView.layer.cornerRadius = _emailTextView.frame.size.height/2;
    _emailTextView.layer.masksToBounds=YES;
    _emailTextView.layer.borderColor=[[UIColor whiteColor]CGColor];
    _emailTextView.layer.borderWidth= 1.0f;


    
    _finishButton.layer.cornerRadius = _finishButton.frame.size.height/2;
    _finishButton.layer.masksToBounds=YES;
    _finishButton.layer.borderColor=[[UIColor whiteColor]CGColor];
    _finishButton.layer.borderWidth= 2.0f;
    _finishButton.layer.bounds = _finishButton.bounds;
    _finishButton.tintColor = [UIColor whiteColor];
    
    CALayer *red = [CALayer layer];
    red.frame = self.view.bounds;
    red.backgroundColor = [[UIColor spreeDarkBlue] CGColor];
    red.opacity = 1.0f;
    [self.view.layer insertSublayer:red atIndex:0];
    
    CALayer *white = [CALayer layer];
    white.frame = self.view.bounds;
    white.backgroundColor = [[UIColor whiteColor] CGColor];
    white.opacity = 0.4f;
    [self.view.layer insertSublayer:white atIndex:1];

    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    
    
    
    [self.keyboardAvoidingView addGestureRecognizer:tap];
    
}

-(void)dismissKeyboard{
    [_emailTextView resignFirstResponder];
    [_phoneNumberTextView resignFirstResponder];
    [_keyboardAvoidingView setContentOffset: CGPointMake(0,0) animated:YES];
}

- (void)disableFinishButton{
    _finishButton.tintColor = [UIColor lightGrayColor];
    _finishButton.enabled = NO;
}

-(void)animateEmailRequired{
    [UIView animateWithDuration:1.0 animations:^{
    } completion: ^(BOOL finished) {
        if (finished)
            [UIView animateWithDuration:1.0 animations:^{
                _requiredEmailLabel.alpha = 1.0;
            } completion:nil];
    }];
}

-(void)animatePhoneNumberRequired{
    [UIView animateWithDuration:1.0 animations:^{
    } completion: ^(BOOL finished) {
        if (finished)
            [UIView animateWithDuration:1.0 animations:^{
                _requiredPhoneNumberLabel.alpha = 1.0;
            } completion:nil];
    }];
}

-(void)animateFinishButton{
    [UIView animateWithDuration:2.0 animations:^{
        _finishButton.tintColor = [UIColor spreeBabyBlue];
        _finishButton.enabled = YES;
    } completion:nil];
}

-(void)animateEmailFieldFilled{
    [UIView animateWithDuration:2.0 animations:^{
        _requiredEmailLabel.alpha = 0;
    } completion:nil];
}

-(void)animatePhoneNumberFieldFilled{
    [UIView animateWithDuration:2.0 animations:^{
        _requiredPhoneNumberLabel.alpha = 0;
    } completion:nil];
}


-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if (_phoneNumberTextView.text.length > 0 && _emailTextView.text.length > 0){
        _finishButton.enabled = YES;
        _finishButton.tintColor = [UIColor spreeBabyBlue];
    }
}

- (void)processFieldEntries {
    // Check that we have a non-zero username and passwords.
    // Compare password and passwordAgain for equality
    // Throw up a dialog that tells them what they did wrong if they did it wrong.
    
    NSString *email = _emailTextView.text;
    NSString *phoneNumber =_phoneNumberTextView.text;
    NSString *emailBlankText = @"enter a valid email address";
    NSString *phoneNumberBlankText = @"enter a correct phone number";
    NSString *errorText = @"Please ";
    NSString *joinText = @", and ";
    BOOL textError = NO;
    
    // Messaging nil will return 0, so these checks implicitly check for nil text.
    if (email.length == 0 || phoneNumber.length == 0 || [self getLength:phoneNumber] != 10 || [self NSStringIsValidEmail:email] == NO)   {
        textError = YES;
        
        // Set up the keyboard for the first field missing input:
        if (email.length == 0) {
            [self.emailTextView becomeFirstResponder];
        }
        if (phoneNumber.length == 0) {
            [self.emailTextView becomeFirstResponder];
        }
        
        if ([self getLength:phoneNumber] != 10) {
            [self.phoneNumberTextView becomeFirstResponder];
        }
        
        if ([self NSStringIsValidEmail:email] == NO){
            [self.emailTextView becomeFirstResponder];
        }
        
        if (phoneNumber.length == 0 || [self getLength:phoneNumber] != 10) {
            errorText = [errorText stringByAppendingString:phoneNumberBlankText];
        }
        
        if (email.length == 0 || [self NSStringIsValidEmail:email] == NO) {
            if (phoneNumber.length == 0 || [self getLength:phoneNumber] != 10) { // We need some joining text in the error:
                errorText = [errorText stringByAppendingString:joinText];
            }
            errorText = [errorText stringByAppendingString:emailBlankText];
        }
    }
    
    if (textError) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:errorText message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
        return;
    }

    [PFUser currentUser][@"email"] = email;
    [PFUser currentUser][@"phoneNumber"] = [self removeFormatting: phoneNumber];
    [[PFUser currentUser] saveInBackground];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.delegate newUserViewControllerDidSignup:self];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)setUpButtonPressed:(id)sender {
    [self processFieldEntries];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (_emailTextView.text.length > 0){
        [self animateEmailFieldFilled];
    } else if ([_emailTextView.text isEqualToString:@""]){
        [self animateEmailRequired];
    }
    if (_phoneNumberTextView.text.length > 0){
        [self animatePhoneNumberFieldFilled];
    } else if ([_phoneNumberTextView.text isEqualToString:@""]) {
        [self animatePhoneNumberRequired];
    }
    if (_phoneNumberTextView.text.length > 0 && _emailTextView.text.length > 0){
        [self animateFinishButton];
    } else if (_phoneNumberTextView.text.length == 0 && _emailTextView.text.length == 0){
        [self disableFinishButton];
    }

}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (textField == _phoneNumberTextView){
        int length = [self getLength:textField.text];
        //NSLog(@"Length  =  %d ",length);
        
        if(length == 10)
        {
            if(range.length == 0)
                return NO;
        }
        
        if(length == 3)
        {
            NSString *num = [self formatNumber:textField.text];
            textField.text = [NSString stringWithFormat:@"(%@) ",num];
            if(range.length > 0)
                textField.text = [NSString stringWithFormat:@"%@",[num substringToIndex:3]];
        }
        else if(length == 6)
        {
            NSString *num = [self formatNumber:textField.text];
            //NSLog(@"%@",[num  substringToIndex:3]);
            //NSLog(@"%@",[num substringFromIndex:3]);
            textField.text = [NSString stringWithFormat:@"(%@) %@-",[num  substringToIndex:3],[num substringFromIndex:3]];
            if(range.length > 0)
                textField.text = [NSString stringWithFormat:@"(%@) %@",[num substringToIndex:3],[num substringFromIndex:3]];
        }
        
        return YES;
    }
    return YES;
}

-(NSString*)formatNumber:(NSString*)mobileNumber
{
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    NSLog(@"%@", mobileNumber);
    
    int length = (int)[mobileNumber length];
    if(length > 10)
    {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
        NSLog(@"%@", mobileNumber);
        
    }
    
    
    return mobileNumber;
}


-(int)getLength:(NSString*)mobileNumber
{
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    int length = (int)[mobileNumber length];
    
    return length;
    
    
}

-(NSString *)removeFormatting:(NSString*)mobileNumber{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    return mobileNumber;
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

@end
