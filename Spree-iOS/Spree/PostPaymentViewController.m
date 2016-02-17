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

typedef enum : NSUInteger {
    kAlertViewConfirmPurchase,
} AlertViewType;

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
    
    NSString *name = [self.post.user objectForKey:@"displayName"];

    
    self.recipientLabel.text = name;
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
    if (alertView.tag == kAlertViewConfirmPurchase){
        if (buttonIndex == 0) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            if  (![self.post[@"typePointer"][@"type"] isEqualToString:@"Tasks & Services"]){
                PFObject *object = [PFObject objectWithClassName:@"PaymentQueue"];
                [object setObject:[self getNumberFromString:self.amountField.text] forKey:@"offer"];
                [object setObject:[PFUser currentUser] forKey:@"buyer"];
                [object setObject:self.post.user forKey:@"seller"];
                [object setObject:self.post forKey:@"post"];
                [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                    if (succeeded){
                        [[MBProgressHUD HUDForView:self.view] setLabelText:@"Offer Sent"];
                        [[MBProgressHUD HUDForView:self.view] hide:YES afterDelay:0.3f];
                        [self.delegate userOffered:object];
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                }];
            } else {
                [self.post setObject:[NSNumber numberWithBool:1] forKey:@"sold"];
                [self dismissViewControllerAnimated:YES completion:nil];
                [self.delegate userPaidForService:self.post];
            }
        } else {
            [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
        }
    }
}

- (IBAction)sendButtonTouched:(id)sender {

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Make an Offer" message:[NSString stringWithFormat:@"You are promising to purchase this item for $%@", self.amountField.text] delegate:self cancelButtonTitle:@"Confirm" otherButtonTitles:@"Cancel", nil];
    alert.tag = kAlertViewConfirmPurchase;
    [alert show];
    
    
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

    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
