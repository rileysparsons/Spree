//
//  NewPostInfoViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 3/8/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "NewPostInfoViewController.h"
#import "NewBooksPostView.h"
#import "NewDefaultPostView.h"
#import "NewFreePostView.h"
#import "NewTicketsPostView.h"
#import "NewGenericPostView.h"

@interface NewPostInfoViewController () {
    NSInteger selectedPhotoButton;
    NSMutableDictionary *photoDictionary;
}

@end


@implementation NewPostInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[PFUser currentUser]fetchInBackground];
    // Do any additional setup after loading the view.
    self.firstAddPhotoButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.secondAddPhotoButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.thirdAddPhotoButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    // Set delegates for respective views
    self.booksPostView.descriptionField.delegate = self;
    self.defaultPostView.descriptionField.delegate = self;
    self.ticketsPostView.descriptionField.delegate = self;
    self.freePostView.descriptionField.delegate = self;
    self.genericPostView.descriptionField.delegate = self;

    [self.booksPostView.titleField addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    [self.ticketsPostView.titleField addTarget:self
                                      action:@selector(textFieldDidChange:)
                            forControlEvents:UIControlEventEditingChanged];
    [self.defaultPostView.titleField addTarget:self
                                      action:@selector(textFieldDidChange:)
                            forControlEvents:UIControlEventEditingChanged];
    [self.freePostView.titleField addTarget:self
                                      action:@selector(textFieldDidChange:)
                            forControlEvents:UIControlEventEditingChanged];
    [self.genericPostView.titleField addTarget:self
                                      action:@selector(textFieldDidChange:)
                            forControlEvents:UIControlEventEditingChanged];
    
    [self.booksPostView.priceField addTarget:self
                                      action:@selector(textFieldDidChange:)
                            forControlEvents:UIControlEventEditingChanged];
    [self.ticketsPostView.priceField addTarget:self
                                        action:@selector(textFieldDidChange:)
                              forControlEvents:UIControlEventEditingChanged];
    [self.defaultPostView.priceField addTarget:self
                                        action:@selector(textFieldDidChange:)
                              forControlEvents:UIControlEventEditingChanged];
    [self.genericPostView.priceField addTarget:self
                                        action:@selector(textFieldDidChange:)
                              forControlEvents:UIControlEventEditingChanged];
    
    [self.booksPostView.classField addTarget:self
                                      action:@selector(textFieldDidChange:)
                            forControlEvents:UIControlEventEditingChanged];
    [self.ticketsPostView.dateField addTarget:self
                                        action:@selector(textFieldDidChange:)
                              forControlEvents:UIControlEventEditingChanged];
    [self.genericPostView.subTitleField addTarget:self
                                        action:@selector(textFieldDidChange:)
                              forControlEvents:UIControlEventEditingChanged];
    
    
    self.booksPostView.titleField.delegate = self;
    self.ticketsPostView.titleField.delegate = self;
    self.defaultPostView.titleField.delegate = self;
    self.freePostView.titleField.delegate = self;
    self.genericPostView.titleField.delegate = self;
    
    self.booksPostView.priceField.delegate = self;
    self.ticketsPostView.priceField.delegate = self;
    self.defaultPostView.priceField.delegate = self;
    self.genericPostView.priceField.delegate = self;
    
    self.booksPostView.priceField.placeholder = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
    self.ticketsPostView.priceField.placeholder = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
    self.defaultPostView.priceField.placeholder = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
    self.genericPostView.priceField.placeholder = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];

    self.freePostView.descriptionField.text = POST_VIEW_DESCRIPTION;
    self.freePostView.descriptionField.textColor = [UIColor lightGrayColor];
    self.ticketsPostView.descriptionField.text = POST_VIEW_DESCRIPTION;
    self.ticketsPostView.descriptionField.textColor = [UIColor lightGrayColor];
    self.defaultPostView.descriptionField.text = POST_VIEW_DESCRIPTION;
    self.defaultPostView.descriptionField.textColor = [UIColor lightGrayColor];
    self.booksPostView.descriptionField.text = POST_VIEW_DESCRIPTION;
    self.booksPostView.descriptionField.textColor = [UIColor lightGrayColor];
    self.genericPostView.descriptionField.text = POST_VIEW_DESCRIPTION;
    self.genericPostView.descriptionField.textColor = [UIColor lightGrayColor];
    
    self.booksPostView.classField.delegate = self;
    self.ticketsPostView.dateField.delegate = self;
    self.genericPostView.subTitleField.delegate = self;

    // Set placeholder for generic
    //if ([self.post.type isEqualToString:@"Tasks"]) {
        self.genericPostView.titleField.placeholder = @"Task title...";
        self.genericPostView.subTitleField.placeholder = @"Location...";
    //}
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    photoDictionary = [[NSMutableDictionary alloc] initWithCapacity:3];
    
    self.postBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStyleDone target:self action:@selector(postBarButtonItemPressed)];
    self.navigationItem.rightBarButtonItem = self.postBarButtonItem;
    self.postBarButtonItem.enabled = NO;
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];

    DDLogVerbose(@"POST TYPE: %@", self.post.type);
}

-(void)dismissKeyboard{
    [self.ticketsPostView.descriptionField resignFirstResponder];
    [self.defaultPostView.descriptionField resignFirstResponder];
    [self.freePostView.descriptionField resignFirstResponder];
    [self.booksPostView.descriptionField resignFirstResponder];
    [self.genericPostView.descriptionField resignFirstResponder];

    [self.ticketsPostView.titleField resignFirstResponder];
    [self.defaultPostView.titleField resignFirstResponder];
    [self.freePostView.titleField resignFirstResponder];
    [self.booksPostView.titleField resignFirstResponder];
    [self.genericPostView.titleField resignFirstResponder];

    [self.ticketsPostView.priceField resignFirstResponder];
    [self.defaultPostView.priceField resignFirstResponder];
    [self.booksPostView.priceField resignFirstResponder];
    [self.genericPostView.priceField resignFirstResponder];

    [self.booksPostView.classField resignFirstResponder];
    [self.ticketsPostView.dateField resignFirstResponder];
    [self.genericPostView.subTitleField resignFirstResponder];
}

# pragma mark - Photo Upload Methods

- (IBAction)firstAddPhotoButtonPressed:(id)sender {
    selectedPhotoButton = 1;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Delete Picture"
                                                    otherButtonTitles:@"Take a Picture",@"Choose from Library", nil];
    [actionSheet showInView:self.view];
}

- (IBAction)secondAddPhotoButtonPressed:(id)sender {
    selectedPhotoButton = 2;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Delete Picture"
                                                    otherButtonTitles:@"Take a Picture",@"Choose from Library", nil];
    [actionSheet showInView:self.view];
}
- (IBAction)thirdAddPhotoButtonPressed:(id)sender {
    selectedPhotoButton = 3;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Delete Picture"
                                                    otherButtonTitles:@"Take a Picture",@"Choose from Library", nil];
    [actionSheet showInView:self.view];
}

- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    NSLog(@"%ld", (long)selectedPhotoButton);
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    switch (selectedPhotoButton) {
        case 1:
            [self.firstAddPhotoButton setImage:image forState:UIControlStateNormal];
            self.firstAddPhotoButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
            break;
        case 2:
            [self.secondAddPhotoButton setImage:image forState:UIControlStateNormal];
            self.secondAddPhotoButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
            break;
        case 3:
            [self.thirdAddPhotoButton setImage:image forState:UIControlStateNormal];
            self.thirdAddPhotoButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
            break;
        default:
            break;
    }
    
    // Resize image
    UIGraphicsBeginImageContext(CGSizeMake(640, 960));
    [image drawInRect: CGRectMake(0, 0, 640, 960)];
    UIGraphicsEndImageContext();
    
    // Upload image
    NSData *imageData = UIImageJPEGRepresentation(image, 0.05f);
    [photoDictionary setObject:imageData forKey:[NSNumber numberWithInteger:selectedPhotoButton]];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // Create a new image picker instance:
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    // Set the image picker source:
    switch (buttonIndex) {
        case 1:
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
        case 2:
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        default:
            break;
    }
    
    picker.delegate = self;
    
    // Show picker if Take a picture or Choose from Library is selected
    if ( buttonIndex == 1 || buttonIndex == 2){
        [self presentViewController:picker animated:YES completion:nil];
        
    }else if (buttonIndex == 0){
        // TO DO nil the photo data
        [photoDictionary removeObjectForKey:[NSNumber numberWithInteger:selectedPhotoButton]];
        switch (selectedPhotoButton) {
            case 1:
                [self.firstAddPhotoButton setTitle:@"Add Photo" forState:UIControlStateNormal];
                [self.firstAddPhotoButton setImage:nil forState:UIControlStateNormal];
                break;
            case 2:
                [self.secondAddPhotoButton setTitle:@"Add Photo" forState:UIControlStateNormal];
                [self.secondAddPhotoButton setImage:nil forState:UIControlStateNormal];
                break;
            case 3:
                [self.thirdAddPhotoButton setTitle:@"Add Photo" forState:UIControlStateNormal];
                [self.thirdAddPhotoButton setImage:nil forState:UIControlStateNormal];
                break;
            default:
                break;
        }
        [actionSheet dismissWithClickedButtonIndex:2 animated:YES];
    }
    NSLog(@"%@", photoDictionary);
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    DDLogVerbose(@"shouldchangecharactersinrange");

    NSString *newText;

    if ([self.post.type isEqualToString: @"Books"]){
        if (textField == self.booksPostView.priceField){
            newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        }
        
    } else if ([self.post.type isEqualToString:@"Electronics"] || [self.post.type isEqualToString:@"Furniture"] || [self.post.type isEqualToString:@"Clothing"]){
        if (textField == self.defaultPostView.priceField){
            newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        }
        
    } else if ([self.post.type isEqualToString: @"Tickets"]){
        if (textField == self.ticketsPostView.priceField){
            newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        }
    } else if ([self.post.type isEqualToString: @"Tasks"]){
        if (textField == self.genericPostView.priceField){
            newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        }
    }

    if ([newText length] == 0) {
        return YES;
    }

    if (![newText hasPrefix:[[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol]])
    {
        return NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"MEETS REQUIREMENTS: %d", [self checkForRequiredFields]);

    BOOL isPriceField;
    NSString *testString;
    if ([self.post.type isEqualToString: @"Books"]){
        testString = self.booksPostView.priceField.text;
        isPriceField = textField == self.booksPostView.priceField;
    } else if ([self.post.type isEqualToString:@"Electronics"] || [self.post.type isEqualToString:@"Furniture"] || [self.post.type isEqualToString:@"Clothing"]){
        testString = self.defaultPostView.priceField.text;
        isPriceField = textField == self.defaultPostView.priceField;
    } else if ([self.post.type isEqualToString: @"Tickets"]){
        testString = self.ticketsPostView.priceField.text;
        isPriceField = textField == self.ticketsPostView.priceField;
    }

    DDLogVerbose(@"TESTSTRING: %@", testString);
    if (isPriceField && [testString length] == 0) {
        textField.text = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
    }

    self.postBarButtonItem.enabled = [self checkForRequiredFields];
}

- (void)textFieldDidChange:(id)sender{
    self.postBarButtonItem.enabled = [self checkForRequiredFields];
}

# pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:POST_VIEW_DESCRIPTION]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = POST_VIEW_DESCRIPTION;
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        
        [textView resignFirstResponder];
        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    // For any other character return TRUE so that the text gets added to the view
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView{
    self.postBarButtonItem.enabled = [self checkForRequiredFields];
}

# pragma mark - Posting methods

-(void)postBarButtonItemPressed {
    [self postInfoToServer];
}

- (NSString *)getPostTitle {
    if ([self.post.type isEqualToString: @"Books"]) {
        return self.booksPostView.titleField.text;
    } else if ([self.post.type isEqualToString: @"Electronics"] || [self.post.type isEqualToString:@"Furniture"] || [self.post.type isEqualToString:@"Clothing"]) {
        return self.defaultPostView.titleField.text;
    } else if ([self.post.type isEqualToString: @"Tickets"]) {
        return self.ticketsPostView.titleField.text;
    } else if ([self.post.type isEqualToString: @"Tasks"]) {
        return self.genericPostView.titleField.text;
    }
    return @"";
}

- (NSString *)getUserDescription {
    if ([self.post.type isEqualToString: @"Books"]){
        return self.booksPostView.descriptionField.text;
    } else if ([self.post.type isEqualToString: @"Electronics"] || [self.post.type isEqualToString:@"Furniture"] || [self.post.type isEqualToString:@"Clothing"]){
        return self.defaultPostView.descriptionField.text;
    } else if ([self.post.type isEqualToString: @"Tickets"]){
        return self.ticketsPostView.descriptionField.text;
    } else if ([self.post.type isEqualToString: @"Tasks"]){
        return self.genericPostView.descriptionField.text;
    }
    return @"";
}

- (NSNumber *)getPostPrice {
    NSString *priceString;
    if ([self.post.type isEqualToString: @"Books"]){
        priceString = self.booksPostView.priceField.text;
    } else if ([self.post.type isEqualToString: @"Electronics"] || [self.post.type isEqualToString:@"Furniture"] || [self.post.type isEqualToString:@"Clothing"]){
        priceString = self.defaultPostView.priceField.text;
    } else if ([self.post.type isEqualToString: @"Tickets"]){
        priceString = self.ticketsPostView.priceField.text;
    } else if ([self.post.type isEqualToString: @"Tasks"]){
        priceString = self.genericPostView.priceField.text;
    }

    if ([priceString length] == 0) {
        return 0;
    }
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *priceNumber = [formatter numberFromString:[[priceString componentsSeparatedByString:@"$"] objectAtIndex:1]];
    return priceNumber;
}

-(void)postInfoToServer{
    if (![self checkForRequiredFields]){
        //Did not pass checks
        return;
    }

    self.post.expired = NO;
    self.post.sold = NO;
    self.post.title = [self getPostTitle];
    self.post.price = [self getPostPrice];
    self.post.userDescription = [self getUserDescription];
    self.post.user = [PFUser currentUser];
    self.post.network = [[PFUser currentUser] objectForKey:@"network"];

    NSMutableArray *fileArray = [[NSMutableArray alloc] initWithCapacity:3];
    for (id key in photoDictionary) {
        PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:[photoDictionary objectForKey:key]];
        [fileArray addObject:imageFile];
    }
    self.post.photoArray = fileArray;

    PFACL *readOnlyUserWriteACL = [PFACL ACL];
    [readOnlyUserWriteACL setPublicReadAccess:YES];
    [readOnlyUserWriteACL setWriteAccess:YES forUser:[PFUser currentUser]];
    self.post.ACL = readOnlyUserWriteACL;

    if ([self.post.type isEqualToString: @"Books"]){
        self.post.bookForClass = self.booksPostView.classField.text;
    }

    if ([self.post.type isEqualToString: @"Tickets"]){
        self.post.eventDate = self.ticketsPostView.dateField.text;
    }
    
    if ([self.post.type isEqualToString: @"Tasks"]){
        self.post.subtitle = self.genericPostView.subTitleField.text;
    }

    [self.post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error){
            if (succeeded == YES) {
                NSLog(@"Save in background successful");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PostMade" object:nil];
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }
        } else {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [errorAlert show];
        }
    }];
}

-(BOOL)checkForRequiredFields {

    NSLog(@"%@", [PFUser currentUser]);
//    if ([[currentUser objectForKey:@"emailVerified"] boolValue]){
    if (1) {

        if ([[self getUserDescription] length] == 0 || [[self getUserDescription] isEqualToString:POST_VIEW_DESCRIPTION]){
            return NO;
        }

        if ([[self getPostTitle] length] == 0 || [[self getPostTitle] isEqualToString:POST_VIEW_TITLE]){
            return NO;
        }
//
//        BOOL hasPrice = [self.post.type isEqualToString:@"Free"] ? NO : YES;

//        if (([self getPostPrice] == [NSNull null])){
//            return NO;
//        }

        if ([self.post.type isEqualToString: @"Tickets"]){
            if ([self.ticketsPostView.dateField.text length] == 0){
                return NO;
            }
        } else if ([self.post.type isEqualToString: @"Tasks"]){
            if ([self.genericPostView.subTitleField.text length] == 0){
                return NO;
            }
        }

        return YES;

    } else {
        UIAlertView *notVerifiedAlert = [[UIAlertView alloc] initWithTitle:@"Please verify email"
                                                                   message:@"You are not verified as a Santa Clara University student. Please check your @scu.edu inbox for a verification email" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [notVerifiedAlert show];
        return NO;
    }
}

@end