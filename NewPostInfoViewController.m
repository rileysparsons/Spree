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

@interface NewPostInfoViewController () {
    NSInteger selectedPhotoButton;
    NSMutableDictionary *photoDictionary;
}

@end


@implementation NewPostInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.firstAddPhotoButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.secondAddPhotoButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.thirdAddPhotoButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    // Set delegates for respective views
    self.booksPostView.descriptionField.delegate = self;
    self.defaultPostView.descriptionField.delegate = self;
    self.ticketsPostView.descriptionField.delegate = self;
    self.freePostView.descriptionField.delegate = self;

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
    
    [self.booksPostView.priceField addTarget:self
                                      action:@selector(textFieldDidChange:)
                            forControlEvents:UIControlEventEditingChanged];
    [self.ticketsPostView.priceField addTarget:self
                                        action:@selector(textFieldDidChange:)
                              forControlEvents:UIControlEventEditingChanged];
    [self.defaultPostView.priceField addTarget:self
                                        action:@selector(textFieldDidChange:)
                              forControlEvents:UIControlEventEditingChanged];
    
    [self.booksPostView.classField addTarget:self
                                      action:@selector(textFieldDidChange:)
                            forControlEvents:UIControlEventEditingChanged];
    [self.ticketsPostView.dateField addTarget:self
                                        action:@selector(textFieldDidChange:)
                              forControlEvents:UIControlEventEditingChanged];
    
    
    self.booksPostView.titleField.delegate = self;
    self.ticketsPostView.titleField.delegate = self;
    self.defaultPostView.titleField.delegate = self;
    self.freePostView.titleField.delegate = self;
    
    self.booksPostView.priceField.delegate = self;
    self.ticketsPostView.priceField.delegate = self;
    self.defaultPostView.priceField.delegate = self;
    
    self.booksPostView.priceField.placeholder = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
    self.ticketsPostView.priceField.placeholder = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
    self.defaultPostView.priceField.placeholder = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
    
    self.freePostView.descriptionField.text = @"Add description...";
    self.freePostView.descriptionField.textColor = [UIColor lightGrayColor];
    self.ticketsPostView.descriptionField.text = @"Add description...";
    self.ticketsPostView.descriptionField.textColor = [UIColor lightGrayColor];
    self.defaultPostView.descriptionField.text = @"Add description...";
    self.defaultPostView.descriptionField.textColor = [UIColor lightGrayColor];
    self.booksPostView.descriptionField.text = @"Add description...";
    self.booksPostView.descriptionField.textColor = [UIColor lightGrayColor];
    
    self.booksPostView.classField.delegate = self;
    
    self.ticketsPostView.dateField.delegate = self;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    photoDictionary = [[NSMutableDictionary alloc] initWithCapacity:3];
    
    self.postBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStyleDone target:self action:@selector(postBarButtonItemPressed)];
    self.navigationItem.rightBarButtonItem = self.postBarButtonItem;
    self.postBarButtonItem.enabled = NO;
    
    
    
    NSLog(@"%@", self.post);
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
    NSLog(@"%lu", selectedPhotoButton);
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
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
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
 
    if ([self.post.type isEqualToString: @"Free"]){
        
    } else if ([self.post.type isEqualToString: @"Books"]){
        if (textField == self.booksPostView.priceField){
            NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
            
            // Make sure that the currency symbol is always at the beginning of the string:
            if (![newText hasPrefix:[[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol]])
            {
                return NO;
            }
            
            // Default:
            return YES;
        }
        
    } else if ([self.post.type isEqualToString: @"Electronics"]){
        if (textField == self.defaultPostView.priceField){
            NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
            
            // Make sure that the currency symbol is always at the beginning of the string:
            if (![newText hasPrefix:[[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol]])
            {
                return NO;
            }
            
            // Default:
            return YES;
            
        }
        
    } else if ([self.post.type isEqualToString: @"Tickets"]){
        if (textField == self.ticketsPostView.priceField){
            NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
            
            // Make sure that the currency symbol is always at the beginning of the string:
            if (![newText hasPrefix:[[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol]])
            {
                return NO;
            }
            
            // Default:
            return YES;
            
        }
        
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([self.post.type isEqualToString: @"Free"]){
        
    } else if ([self.post.type isEqualToString: @"Books"]){
        if (textField == self.booksPostView.priceField){
            if (textField.text.length  == 0)
            {
                textField.text = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
            }
        }
        
    } else if ([self.post.type isEqualToString: @"Electronics"]){
        if (textField == self.defaultPostView.priceField){
            if (textField.text.length  == 0)
            {
                textField.text = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
            }
        }
        
    } else if ([self.post.type isEqualToString: @"Tickets"]){
        if (textField == self.ticketsPostView.priceField){
            if (textField.text.length  == 0)
            {
                textField.text = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
            }
        }
        
    }
    if ([self checkForRequiredFields]){
        [self.postBarButtonItem setEnabled:YES];
    } else {
        [self.postBarButtonItem setEnabled:NO];
    }
}

- (void)textFieldDidChange:(id)sender{
    if ([self checkForRequiredFields]){
        [self.postBarButtonItem setEnabled:YES];
    } else {
        [self.postBarButtonItem setEnabled:NO];
    }
}

# pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Add description..."]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Add description...";
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
    if ([self checkForRequiredFields]){
        self.postBarButtonItem.enabled = YES;
    } else {
        self.postBarButtonItem.enabled = NO;
    }
}

# pragma mark - Posting methods

-(void)postBarButtonItemPressed {
    [self postInfoToServer];
}

-(void)postInfoToServer{
    if (![self checkForRequiredFields]){
        //Did not pass checks
    } else {
        if ([self.post.type isEqualToString: @"Free"]){
            self.post.userDescription = self.freePostView.descriptionField.text;
            self.post.title = self.freePostView.titleField.text;
            self.post.user = [PFUser currentUser];
            self.post.expired = NO;
            self.post.sold = NO;
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
            
            [self.post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error){
                    
                } else {
                    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [errorAlert show];
                }
            }];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            
        } else if ([self.post.type isEqualToString: @"Books"]){
            self.post.bookForClass = self.booksPostView.classField.text;
            NSString *price = [[self.booksPostView.priceField.text componentsSeparatedByString:@"$"] objectAtIndex:1];
            self.post.price = price;
            self.post.userDescription = self.booksPostView.descriptionField.text;
            self.post.title = self.booksPostView.titleField.text;
            self.post.user = [PFUser currentUser];
            self.post.expired = NO;
            self.post.sold = NO;
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
            
            [self.post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error){
                    
                } else {
                    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [errorAlert show];
                }
            }];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            
        } else if ([self.post.type isEqualToString: @"Electronics"]){
            self.post.userDescription = self.defaultPostView.descriptionField.text;
            self.post.title = self.defaultPostView.titleField.text;
            NSString *price = [[self.defaultPostView.priceField.text componentsSeparatedByString:@"$"] objectAtIndex:1];
            self.post.price = price;
            self.post.user = [PFUser currentUser];
            self.post.expired = NO;
            self.post.sold = NO;
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
            
            [self.post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error){
                    
                } else {
                    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [errorAlert show];
                }
            }];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            
        } else if ([self.post.type isEqualToString: @"Tickets"]){
            self.post.eventDate = self.ticketsPostView.dateField.text;
            self.post.userDescription = self.ticketsPostView.descriptionField.text;
            self.post.title = self.ticketsPostView.titleField.text;
            NSString *price = [[self.ticketsPostView.priceField.text componentsSeparatedByString:@"$"] objectAtIndex:1];
            self.post.price = price;
            self.post.user = [PFUser currentUser];
            self.post.expired = NO;
            self.post.sold = NO;
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
}

-(BOOL)checkForRequiredFields{
    if ([self.post.type isEqualToString: @"Free"]){
        if (self.freePostView.descriptionField.text == nil || [self.freePostView.descriptionField.text isEqualToString:@"Add description..."] || [self.freePostView.descriptionField.text isEqualToString:@""]){
            return NO;
        } else if (self.freePostView.titleField.text == nil || [self.freePostView.titleField.text isEqualToString:@"Add title..."] || [self.freePostView.titleField.text isEqualToString:@""] ) {
            return NO;
        } else {
            return YES;
        }
    } else if ([self.post.type isEqualToString: @"Books"]){
        if (self.booksPostView.descriptionField.text == nil || [self.booksPostView.descriptionField.text isEqualToString:@"Add description..."] || [self.booksPostView.descriptionField.text isEqualToString:@""]){
            return NO;
        } else if (self.booksPostView.titleField.text == nil || [self.booksPostView.titleField.text isEqualToString:@"Add title..."] || [self.booksPostView.titleField.text isEqualToString:@""] ) {
            return NO;
        } else if (self.booksPostView.classField.text == nil || [self.booksPostView.classField.text isEqualToString:@"Add title..."] || [self.booksPostView.classField.text isEqualToString:@""] ) {
            return NO;
        } else if (self.booksPostView.priceField.text == nil || [self.booksPostView.priceField.text isEqualToString:@"$"] || [self.booksPostView.classField.text isEqualToString:@""] ) {
            return NO;
        } else {
            return YES;
        }
    } else if ([self.post.type isEqualToString: @"Electronics"]){
        if (self.defaultPostView.descriptionField.text == nil || [self.defaultPostView.descriptionField.text isEqualToString:@"Add description..."] || [self.defaultPostView.descriptionField.text isEqualToString:@""]){
            return NO;
        } else if (self.defaultPostView.titleField.text == nil || [self.defaultPostView.titleField.text isEqualToString:@"Add title..."] || [self.defaultPostView.titleField.text isEqualToString:@""] ) {
            return NO;
        } else if (self.defaultPostView.priceField.text == nil || [self.defaultPostView.priceField.text isEqualToString:@"$" ] || [self.defaultPostView.priceField.text isEqualToString:@""]){
            return NO;
        } else {
            return YES;
        }
    } else if ([self.post.type isEqualToString: @"Tickets"]){
        // Required for free: description, title, price, event date
        if (self.ticketsPostView.descriptionField.text == nil || [self.ticketsPostView.descriptionField.text isEqualToString:@"Add description..."] || [self.ticketsPostView.descriptionField.text isEqualToString:@""]){
            return NO;
        } else if (self.ticketsPostView.titleField.text == nil || [self.ticketsPostView.titleField.text isEqualToString:@"Add title..."] || [self.ticketsPostView.titleField.text isEqualToString:@""] ) {
            return NO;
        } else if (self.ticketsPostView.priceField.text == nil || [self.ticketsPostView.priceField.text isEqualToString:@"$" ] || [self.ticketsPostView.priceField.text isEqualToString:@""]){
            return NO;
        }else if (self.ticketsPostView.dateField.text == nil || [self.ticketsPostView.dateField.text isEqualToString:@"" ] || [self.ticketsPostView.dateField.text isEqualToString:@""]){
            return NO;
        } else {
            return YES;
        }
    }

    return NO;
}

@end
