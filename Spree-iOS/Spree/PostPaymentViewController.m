//
//  PostPaymentViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 9/14/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "PostPaymentViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "SpreeUtility.h"
#import "RatingViewController.h"

@interface PostPaymentViewController () <UIAlertViewDelegate, RatingViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *amountField;
@property (weak, nonatomic) IBOutlet UILabel *recipientLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *payButton;


@end


@implementation PostPaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self formatPriceEntryView];
    self.amountField.text = [NSString stringWithFormat:@"%@", [self.post.price stringValue]];
    self.recipientLabel.text = [SpreeUtility firstNameForDisplayName:self.post.user[@"displayName"]];
    self.descriptionField.text = self.post.title;
    // Do any additional setup after loading the view.
    
    // Add a "textFieldDidChange" notification method to the text field control.
    [self.amountField addTarget:self
                            action:@selector(textFieldDidChange:)
                  forControlEvents:UIControlEventEditingChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)initializeWithPost:(SpreePost *)post{
    if (post && post.user && post.price){
        self.post = post;
    }
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sendButtonTouched:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    void(^handler)(VENTransaction *, BOOL, NSError *) = ^(VENTransaction *transaction, BOOL success, NSError *error) {
//        if (error) {
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:error.localizedDescription
//                                                                message:error.localizedRecoverySuggestion
//                                                               delegate:self
//                                                      cancelButtonTitle:nil
//                                                      otherButtonTitles:@"OK", nil];
//            [alertView show];
//            [MBProgressHUD hideHUDForView:self.view animated:YES];
//        }
//        else {
//            [[MBProgressHUD HUDForView:self.view] setLabelText:@"Transaction Succeeded"];
//            [[MBProgressHUD HUDForView:self.view] hide:YES afterDelay:0.3f];
//            self.post.sold = YES;
//            self.post[@"buyer"] = [PFUser currentUser];
//            [self.post saveInBackground];
//            UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
//            RatingViewController *rating = [main instantiateViewControllerWithIdentifier:@"rating"];
//            rating.delegate = self;
//            rating.post = self.post;
//            rating.user = self.post.user;
//            rating.ratingType = @"seller";
//            [self presentViewController:rating animated:YES completion:nil];
//        }
//    };
    
    NSLog(@"Title %@", self.post.title);
    
    // Payment
//    [[Venmo sharedInstance] sendPaymentTo:self.post.user[@"venmoId"]
//                                   amount:[[self getNumberFromString:self.amountField.text] floatValue]
//                                     note:self.post.title
//                        completionHandler:handler];
    
}

- (IBAction)cancelButtonTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)formatPriceEntryView{
    self.amountContainer.layer.borderWidth = 0.5f;
    self.amountContainer.layer.borderColor = [[UIColor spreeOffBlack] CGColor];
    self.amountContainer.layer.cornerRadius = 5.0f;
}


-(BOOL)validatePrice:(NSString *)price{
    
    NSLog(@"%lu", (unsigned long)price.length);
    if (price && price.length > 0 && price.length){
        return YES;
    } else {
        return NO;
    }
}

-(void)textFieldDidChange:(id)sender{
    [self.navigationItem.rightBarButtonItem setEnabled:[self validatePrice:self.amountField.text]];
    
}

- (NSNumber *)getNumberFromString:(NSString *)number{
    if ([number length] == 0) {
        return 0;
    }
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterNoStyle;
    NSNumber *formattedNumber = [formatter numberFromString:number];
    return formattedNumber;
}

#pragma mark - RatingViewControllerDelegate

-(void)ratingViewControllerDelegateDidClose{
    [self.delegate userCompletedPurchase];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
