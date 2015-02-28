//
//  ContainerTableViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/20/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import "ContainerTableViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "UIColor+SpreeColor.h"
#import "PaymentViewController.h"

@interface ContainerTableViewController ()

@end

@implementation ContainerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _priceLabel.text = [NSString stringWithFormat:@"$%@", _detailPost.price];
    
    _descriptionTextView.text = _detailPost.userDescription;
    _managePostLabel.textColor = [UIColor spreeRed];
    
    self.tableView.allowsSelection = NO;
    if ([[(PFUser *)_detailPost.user objectId] isEqualToString: [[PFUser currentUser] objectId]]){
        if (_detailPost.expired == YES) {
            [self enableRespostFeature];
        } else {
            [self disableRepostFeature];
        }
        if (_detailPost.sold == YES){
            [self disableSoldFeature];
            [self disableRepostFeature];
        }
    } else {
        self.soldButton.hidden = YES;
        self.repostButton.hidden = YES;
        self.managePostLabel.hidden = YES;
    }
    
    self.tableView.layer.cornerRadius = 15.0;
    self.tableView.layer.masksToBounds=YES;
    self.tableView.layer.borderColor=[[UIColor clearColor]CGColor];
    self.tableView.layer.borderWidth= 1.0f;

    
    NSString *userObjectId = [_detailPost.user objectId];
//    NSLog(@"objectId %@", userObjectId);
//    PFUser *postingUser = [PFQuery getUserObjectWithId:userObjectId];
//    NSLog(@"%@", postingUser);
    
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    
    [query getObjectInBackgroundWithId:userObjectId block:^(PFObject *object, NSError *error) {
        self.poster = object;
    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/




- (IBAction)purchaseButtonPressed:(id)sender {
    NSLog(@"purchase");
    
    PaymentViewController *paymentViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PaymentViewController"];
    paymentViewController.navigationItem.title = @"Payment";
    paymentViewController.post = _detailPost;
    paymentViewController.poster = _poster;
    [self.navigationController pushViewController:paymentViewController animated:YES];
}

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

    [contactMethod addAction:[UIAlertAction actionWithTitle:@"SMS" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([MFMessageComposeViewController canSendText] && _poster[@"phoneNumber"]){
            MFMessageComposeViewController *textMessageViewController = [[MFMessageComposeViewController alloc] init];
            textMessageViewController.messageComposeDelegate = self;
            NSString *phoneNumber = (NSString *)_poster[@"phoneNumber"];
            [textMessageViewController setRecipients:@[phoneNumber]];
            textMessageViewController.navigationBar.tintColor = [UIColor whiteColor];
            [self presentViewController:textMessageViewController animated:YES completion:nil];
        } else {
            UIAlertView *cannotSendMessageAlert = [[UIAlertView alloc] initWithTitle:@"Unable to send message" message:@"Sorry, your phone is not set up to send SMS or the seller did not provide adequate contact information" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [cannotSendMessageAlert show];
        }
    }]
     ];
    
    [contactMethod addAction:[UIAlertAction actionWithTitle:@"Email" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] init];
            [composeViewController setMailComposeDelegate:self];
            [composeViewController setToRecipients:@[_poster[@"email"]]];
            [composeViewController setSubject:[NSString stringWithFormat:@"Post on Spree: %@", _detailPost.title]];
            [composeViewController setMessageBody:[NSString stringWithFormat:@"Hi %@,\n\n I'm interested in your '%@' on Spree.",  [[_poster[@"name"] componentsSeparatedByString:@" "] objectAtIndex:0], _detailPost.title]isHTML:NO];
            composeViewController.navigationBar.tintColor = [UIColor whiteColor];
            [self presentViewController:composeViewController animated:YES completion:nil];
        } else {
            NSString *message = [NSString stringWithFormat:@"You have not set up Mail on iPhone. User's email is %@", _poster[@"email"]];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Phone cannot send email" message:message  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Copy email to clipboard", nil];
            alert.tag = 1;
            [alert show];
        }
    }]
     ];
    [contactMethod addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]
     ];

    [self presentViewController:contactMethod animated:YES completion:nil];
}

- (IBAction)repostButton:(id)sender {
    UIAlertView *repostAlert = [[UIAlertView alloc] initWithTitle:@"Repost?" message:@"Are you sure you want to repost this?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    repostAlert.tag = 2;
    [repostAlert show];
}

- (IBAction)soldButtonPressed:(id)sender {
    UIAlertView *soldAlert = [[UIAlertView alloc] initWithTitle:@"Confirm Sale" message:@"Did you sell this item? Selecting 'Yes' will permanently remove this post." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    soldAlert.tag = 3;
    [soldAlert show];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1){
        if (buttonIndex == 1) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = _poster[@"email"];
            [alertView dismissWithClickedButtonIndex:1 animated:YES];
        }
        
    } else if (alertView.tag == 2){
        if (buttonIndex == 1) {
            _detailPost.expired = NO;
            [_detailPost saveInBackground];
            [self disableRepostFeature];
        }
    } else if (alertView.tag == 3){
        if (buttonIndex == 1) {
            _detailPost.sold = YES;
            [_detailPost saveInBackground];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

-(void)enableRespostFeature {
    self.repostButton.enabled = YES;
}


-(void)disableRepostFeature {
    self.repostButton.enabled = NO;
}

-(void)enableSoldFeature {
    self.soldButton.enabled = YES;
}


-(void)disableSoldFeature {
    self.soldButton.enabled = NO;
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}



-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    if (error){
        NSString *errorTitle = @"Mail Error";
        NSString *errorDescription = [error localizedDescription];
        UIAlertView *errorView = [[UIAlertView alloc]initWithTitle:errorTitle message:errorDescription delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        errorView.tag = 2;
        [errorView show];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
