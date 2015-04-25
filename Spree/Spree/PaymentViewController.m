//
//  PaymentViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/25/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import "PaymentViewController.h"
#import "UIColor+SpreeColor.h"


@interface PaymentViewController ()

@end

@implementation PaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *singularType;
    if ([_post.type isEqualToString:@"Tickets"]){
        singularType = @"ticket";
    } else if ([_post.type isEqualToString:@"Books"]) {
        singularType = @"book";
    } else if ([_post.type isEqualToString:@"Electronics"]) {
        singularType = @"electronics item";
    } else if ([_post.type isEqualToString:@"Free"]) {
        singularType = @"free item";
    }
    self.informationLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.informationLabel.numberOfLines = 0;
    self.informationLabel.text  = [NSString stringWithFormat: @"Thanks for your interest in this %@. Please contact %@ for information on payment methods and how to meet up!", singularType, [[_poster[@"name"] componentsSeparatedByString:@" "] objectAtIndex:0]];
    
   
    
}




/*

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)submitPurchasePressed:(id)sender {
    
    //This is for client push
//    UIAlertView *requestToPurchase = [[UIAlertView alloc] initWithTitle:@"Confirm request" message:@"This will send a notification to the poster requesting to buy their item."  delegate:self cancelButtonTitle:@"No" otherButtonTitles: @"Yes", nil];
//    requestToPurchase.tag = 0;
//    [requestToPurchase show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 0){
        //Client push code
//        if (buttonIndex ==1){
//            PFQuery *userQuery = [PFInstallation query];
//            [userQuery whereKey:@"user" equalTo:_poster];
//            NSDictionary *pushDictionary = @{
//            @"alert" : [NSString stringWithFormat:@"Someone wants to buy your %@.", _post[@"type"]] , @"post" : [NSString   stringWithFormat:@"%@", _post.objectId]};
//            PFPush *push = [[PFPush alloc] init];
//            [push setQuery:userQuery];
//            [push setData:pushDictionary];
//            [push sendPushInBackground];
//        }
    }
    if (alertView.tag == 1){
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = _poster[@"email"];
    }
}

#pragma contact methods

- (IBAction)contactButtonPressed:(id)sender {
    UIAlertController *contactMethod = [UIAlertController alertControllerWithTitle:@"Select communication method" message:@"How would you like to contact the seller?" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [contactMethod addAction:[UIAlertAction actionWithTitle:@"Phone" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (self.poster[@"phoneNumber"] != nil){
            NSString *phoneNumber = [@"telprompt://" stringByAppendingString:[self.poster objectForKey:@"phoneNumber"]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No phone number found" message:@"Poster failed to provide required contact information" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            alert.tag = 0;
            [alert show];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }]
     ];
    
    [contactMethod addAction:[UIAlertAction actionWithTitle:@"Email" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([MFMailComposeViewController canSendMail]) {
            
            MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] init];
            [composeViewController setMailComposeDelegate:self];
            [composeViewController setToRecipients:@[_poster[@"email"]]];
            [composeViewController setSubject:[NSString stringWithFormat:@"Post on Spree: %@", _post[@"title"]]];
            [composeViewController setMessageBody:[NSString stringWithFormat:@"Hi %@,\n\n I'm interested in purchasing your '%@' on Spree.",  [[_poster[@"name"] componentsSeparatedByString:@" "] objectAtIndex:0], _post[@"title"]]isHTML:NO];
            composeViewController.navigationBar.tintColor = [UIColor whiteColor];
            [self.navigationController presentViewController:composeViewController animated:YES completion:nil];
        } else {
            NSString *message = [NSString stringWithFormat:@"You have not set up Mail on iPhone. User's email is %@", _poster[@"email"]];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Phone cannot send email" message:message  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Copy email to clipboard", nil];
            alert.tag = 1;
            [alert show];
        }
    }]
     ];
    [contactMethod addAction:[UIAlertAction actionWithTitle:@"SMS" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([MFMessageComposeViewController canSendText] && _poster[@"phoneNumber"]){
            MFMessageComposeViewController *textMessageViewController = [[MFMessageComposeViewController alloc] init];
            textMessageViewController.messageComposeDelegate = self;
            NSString *phoneNumber = (NSString *)_poster[@"phoneNumber"];
            [textMessageViewController setRecipients:@[phoneNumber]];
            [self presentViewController:textMessageViewController animated:YES completion:nil];
        } else {
            UIAlertView *cannotSendMessageAlert = [[UIAlertView alloc] initWithTitle:@"Unable to send message" message:@"Sorry, your phone is not set up to send SMS or the seller did not provide adequate contact information" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [cannotSendMessageAlert show];
        }
    }]
     ];
    [contactMethod addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]
     ];
    
    [self presentViewController:contactMethod animated:YES completion:nil];
}


-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    NSLog(@"Did Finish?");
    if (error){
        NSString *errorTitle = @"Mail Error";
        NSString *errorDescription = [error localizedDescription];
        UIAlertView *errorView = [[UIAlertView alloc]initWithTitle:errorTitle message:errorDescription delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        errorView.tag = 2;
        [errorView show];
    }
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Messages failed to open" message:@"Please try again." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    
    
    switch(result) {
        case MessageComposeResultCancelled:
            // user canceled sms
        case MessageComposeResultSent:
            // user sent sms
            //perhaps put an alert here and dismiss the view on one of the alerts buttons
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case MessageComposeResultFailed:
            [errorView show];
            break;
        default:
            break;
    }
}


@end
