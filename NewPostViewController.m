//
//  NewPostViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/14/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import "NewPostViewController.h"
#import <MSCellAccessory/MSCellAccessory.h>
#import "ChosenTypeTableViewCell.h"
#import "UIColor+SpreeColor.h"
#import "NewFreePostView.h"
#import "NewBooksPostView.h"
#import "NewDefaultPostView.h"
#import "NewTicketsPostView.h"
#import <QuartzCore/QuartzCore.h>

#import <Parse/Parse.h>

@interface NewPostViewController ()

@property NSString *selectedType;
@property NSDictionary *selectedLocation;

@end

@implementation NewPostViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"New Post";
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                initWithTitle:@"Back"
                                style:UIBarButtonItemStyleBordered
                                target:self
                                action:nil];
    self.navigationController.navigationBar.topItem.backBarButtonItem=btnBack;
    
    //Background
    
    CALayer *red = [CALayer layer];
    red.frame = self.view.bounds;
    red.backgroundColor = [[UIColor redColor] CGColor];
    red.opacity = 1.0f;
    [self.view.layer insertSublayer:red atIndex:0];
    
    CALayer *white = [CALayer layer];
    white.frame = self.view.bounds;
    white.backgroundColor = [[UIColor whiteColor] CGColor];
    white.opacity = 0.4f;
    [self.view.layer insertSublayer:white atIndex:1];
    
    //TableView Formatting
    _typeTableView.dataSource = self;
    _typeTableView.delegate = self;
   
    _locationTableView.dataSource = self;
    _locationTableView.delegate = self;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self displayNewTypeView];

    
    // Table View Formatting
    _locationTableView.layer.cornerRadius = 15.0;
    _locationTableView.layer.masksToBounds=YES;
    _locationTableView.layer.borderColor=[[UIColor clearColor]CGColor];
    _locationTableView.layer.borderWidth= 1.0f;

    _typeTableView.layer.cornerRadius = 15.0;
    _typeTableView.layer.masksToBounds=YES;
    _typeTableView.layer.borderColor=[[UIColor clearColor]CGColor];
    _typeTableView.layer.borderWidth= 1.0f;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    
    ChosenTypeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nibFiles = [[NSBundle mainBundle] loadNibNamed:@"ChosenTypeTableViewCell" owner:self options:nil];
        for(id currentObject in nibFiles){
            if ([currentObject isKindOfClass:[UITableViewCell class]]){
                cell = (ChosenTypeTableViewCell*)currentObject;
                break;
            }
        }
    }

    if (tableView == _typeTableView){
        
        if (_selectedType == nil){
            cell.typeLabel.text = @"Choose post type";
        } else {
            cell.typeLabel.text = _selectedType;
            if ([_selectedType isEqualToString:@"Tickets"]){
                cell.typeImage.image = [UIImage imageNamed:@"ticketGraphic"];
            } else if ([_selectedType isEqualToString:@"Books"]){
                cell.typeImage.image = [UIImage imageNamed:@"booksGraphic"];
            } else if ([_selectedType isEqualToString:@"Electronics"]){
                cell.typeImage.image = [UIImage imageNamed:@"electronicsGraphic"];
            } else if ([_selectedType isEqualToString:@"Free"]){
                cell.typeImage.image = [UIImage imageNamed:@"freeGraphic"];
            }
        }
        cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_DISCLOSURE_INDICATOR color:[UIColor blackColor] highlightedColor:[UIColor grayColor]];
    }
    
    if (tableView == _locationTableView) {
        if (_selectedLocation == nil){
            cell.typeLabel.text = @"Choose location";
            cell.typeImage.image = [UIImage imageNamed:@"locationButton"];
        } else {
            cell.typeLabel.text = [_selectedLocation objectForKey:@"name"];
            if ([cell.typeLabel.text isEqualToString: @"Current Location"]){
                cell.typeLabel.textColor = [UIColor spreeBabyBlue];
            }
            cell.typeImage.image = [UIImage imageNamed:@"locationSelected"];
        }
        cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_DISCLOSURE_INDICATOR color:[UIColor blackColor] highlightedColor:[UIColor grayColor]];
    }
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    return footer;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == _typeTableView){
        ChooseTypeTableViewController *choose = [self.storyboard instantiateViewControllerWithIdentifier:@"ChooseTypeTableViewController"];
        choose.delegate = self;
        if (_selectedType != nil){
            choose.typeFormerlySelected = _selectedType;
        }
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:choose];
        [self presentViewController:navigationController animated:YES completion:nil];
        NSLog(@"Tapped");
    } else if (tableView == _locationTableView){
        PostLocationViewController *locationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PostLocationViewController"];
        locationViewController.postLocationDelegate = self;
        if (_selectedLocation != nil){
            locationViewController.locationFormerlySelected = [_selectedLocation objectForKey:@"name"];
        }
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:locationViewController];
        [self presentViewController:navigationController animated:YES completion:nil];
    }
}

- (IBAction)postButtonPressed:(id)sender {
    PFObject *post = [PFObject objectWithClassName:@"Post"];
    if ([_selectedType isEqualToString:@"Free"]){
        if (self.freePostView.descriptionField.text == nil || [self.freePostView.descriptionField.text isEqualToString:@"Add description..."] || [self.freePostView.descriptionField.text isEqualToString:@""]){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Post lacks description" message:@"Please describe your item before posting!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        } else if (self.freePostView.titleField.text == nil || [self.freePostView.titleField.text isEqualToString:@"Add title..."] || [self.freePostView.titleField.text isEqualToString:@""] ) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Post lacks title" message:@"Please title your post before submitting!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        } else if (_selectedType == nil || [_selectedType isEqualToString: @"Choose post type"]){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No type listed" message:@"Include the type of your item before posting!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        } else {
            
            saveHUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:saveHUD];
            
            // Set determinate mode
            saveHUD.mode = MBProgressHUDModeDeterminate;
            saveHUD.delegate = self;
            saveHUD.labelText = @"Uploading";
            [saveHUD show:YES];
            
            [post setObject:self.freePostView.descriptionField.text forKey:@"userDescription"];
            [post setObject:self.freePostView.titleField.text forKey:@"title"];
            [post setObject:_selectedType forKey:@"type"];
            [post setObject:[PFUser currentUser] forKey:@"user"];
            [post setObject:[NSNumber numberWithBool:NO] forKey:@"expired"];
            [post setObject:[NSNumber numberWithBool:NO] forKey:@"sold"];
            
            if (_selectedLocation != nil){
                PFGeoPoint *selectedGeopoint = [PFGeoPoint geoPointWithLocation:(CLLocation *)[_selectedLocation objectForKey:@"coordinate"]];
                [post setObject:selectedGeopoint forKey:@"location"];
               
            }
            if (_postImageData != nil){
                PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:_postImageData];
                [post setObject:imageFile forKey:@"imageFile"];
            }
            
            PFACL *readOnlyUserWriteACL = [PFACL ACL];
            [readOnlyUserWriteACL setPublicReadAccess:YES];
            [readOnlyUserWriteACL setWriteAccess:YES forUser:[PFUser currentUser]];
            post.ACL = readOnlyUserWriteACL;
            
            [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error){
                    [saveHUD hide:YES];
                }
            }];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    } else if ([_selectedType isEqualToString:@"Books"]){
        if (self.booksPostView.descriptionField.text == nil || [self.booksPostView.descriptionField.text isEqualToString:@"Add description..."] || [self.booksPostView.descriptionField.text isEqualToString:@""]){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Post lacks description" message:@"Please describe your item before posting!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        } else if (self.booksPostView.titleField.text == nil || [self.booksPostView.titleField.text isEqualToString:@"Add title..."] || [self.booksPostView.titleField.text isEqualToString:@""] ) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Post lacks title" message:@"Please title your post before submitting!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        } else if (_selectedType == nil || [_selectedType isEqualToString: @"Choose post type"]){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No type listed" message:@"Include the type of your item before posting!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        } else if (self.booksPostView.classField.text == nil || [self.booksPostView.classField.text isEqualToString:@"Add title..."] || [self.booksPostView.classField.text isEqualToString:@""] ) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Post lacks title" message:@"Please add a class for your book." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        } else {
            
            saveHUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:saveHUD];
            
            // Set determinate mode
            saveHUD.mode = MBProgressHUDModeDeterminate;
            saveHUD.delegate = self;
            saveHUD.labelText = @"Uploading";
            [saveHUD show:YES];
            
            [post setObject:self.booksPostView.classField.text forKey:@"class"];
            [post setObject:self.booksPostView.descriptionField.text forKey:@"userDescription"];
            [post setObject:self.booksPostView.titleField.text forKey:@"title"];
            [post setObject:_selectedType forKey:@"type"];
            [post setObject:[PFUser currentUser] forKey:@"user"];
            [post setObject:[NSNumber numberWithBool:NO] forKey:@"expired"];
            [post setObject:[NSNumber numberWithBool:NO] forKey:@"sold"];
            
            if (_selectedLocation != nil){
                PFGeoPoint *selectedGeopoint = [PFGeoPoint geoPointWithLocation:(CLLocation *)[_selectedLocation objectForKey:@"coordinate"]];
                [post setObject:selectedGeopoint forKey:@"location"];
                
            }
            if (_postImageData != nil){
                PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:_postImageData];
                [post setObject:imageFile forKey:@"imageFile"];
            }
            
            PFACL *readOnlyUserWriteACL = [PFACL ACL];
            [readOnlyUserWriteACL setPublicReadAccess:YES];
            [readOnlyUserWriteACL setWriteAccess:YES forUser:[PFUser currentUser]];
            post.ACL = readOnlyUserWriteACL;
            
            [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error){
                    [saveHUD hide:YES];
                }
            }];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }

    } else if ([_selectedType isEqualToString:@"Electronics"]){
        if (self.defaultPostView.descriptionField.text == nil || [self.defaultPostView.descriptionField.text isEqualToString:@"Add description..."] || [self.defaultPostView.descriptionField.text isEqualToString:@""]){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Post lacks description" message:@"Please describe your item before posting!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        } else if (self.defaultPostView.titleField.text == nil || [self.defaultPostView.titleField.text isEqualToString:@"Add title..."] || [self.defaultPostView.titleField.text isEqualToString:@""] ) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Post lacks title" message:@"Please title your post before submitting!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        } else if (_selectedType == nil || [_selectedType isEqualToString: @"Choose post type"]){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No type listed" message:@"Include the type of your item before posting!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        } else if (self.defaultPostView.priceField.text == nil || [self.defaultPostView.priceField.text isEqualToString:@"$" ] || [self.defaultPostView.priceField.text isEqualToString:@""]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No price listed" message:@"Include the asking price of your item before posting!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        } else {
            
            saveHUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:saveHUD];
            
            // Set determinate mode
            saveHUD.mode = MBProgressHUDModeDeterminate;
            saveHUD.delegate = self;
            saveHUD.labelText = @"Uploading";
            [saveHUD show:YES];
            
            [post setObject:self.defaultPostView.descriptionField.text forKey:@"userDescription"];
            [post setObject:self.defaultPostView.titleField.text forKey:@"title"];
            [post setObject:_selectedType forKey:@"type"];
            [post setObject:[PFUser currentUser] forKey:@"user"];
            [post setObject:[NSNumber numberWithBool:NO] forKey:@"expired"];
            [post setObject:[NSNumber numberWithBool:NO] forKey:@"sold"];
            NSArray *brokenString = [self.defaultPostView.priceField.text componentsSeparatedByString:@"$"];
            NSString *priceNoSymbol = [brokenString objectAtIndex:1];
            [post setObject:priceNoSymbol forKey:@"price"];
            
            if (_selectedLocation != nil){
                PFGeoPoint *selectedGeopoint = [PFGeoPoint geoPointWithLocation:(CLLocation *)[_selectedLocation objectForKey:@"coordinate"]];
                [post setObject:selectedGeopoint forKey:@"location"];
                
            }
            if (_postImageData != nil){
                PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:_postImageData];
                [post setObject:imageFile forKey:@"imageFile"];
            }
            
            PFACL *readOnlyUserWriteACL = [PFACL ACL];
            [readOnlyUserWriteACL setPublicReadAccess:YES];
            [readOnlyUserWriteACL setWriteAccess:YES forUser:[PFUser currentUser]];
            post.ACL = readOnlyUserWriteACL;
            
            [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error){
                    [saveHUD hide:YES];
                }
            }];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }

    } else if ([_selectedType isEqualToString:@"Tickets"]){
        if (self.ticketsPostView.descriptionField.text == nil || [self.ticketsPostView.descriptionField.text isEqualToString:@"Add description..."] || [self.ticketsPostView.descriptionField.text isEqualToString:@""]){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Post lacks description" message:@"Please describe your item before posting!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        } else if (self.ticketsPostView.titleField.text == nil || [self.ticketsPostView.titleField.text isEqualToString:@"Add title..."] || [self.ticketsPostView.titleField.text isEqualToString:@""] ) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Post lacks title" message:@"Please title your post before submitting!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        } else if (_selectedType == nil || [_selectedType isEqualToString: @"Choose post type"]){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No type listed" message:@"Include the type of your item before posting!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        } else if (self.ticketsPostView.priceField.text == nil || [self.ticketsPostView.priceField.text isEqualToString:@"$" ] || [self.ticketsPostView.priceField.text isEqualToString:@""]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No price listed" message:@"Include the asking price of your item before posting!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        } else {
            
            saveHUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:saveHUD];
            
            // Set determinate mode
            saveHUD.mode = MBProgressHUDModeDeterminate;
            saveHUD.delegate = self;
            saveHUD.labelText = @"Uploading";
            [saveHUD show:YES];
            
            [post setObject:self.ticketsPostView.descriptionField.text forKey:@"userDescription"];
            [post setObject:self.ticketsPostView.titleField.text forKey:@"title"];
            [post setObject:_selectedType forKey:@"type"];
            [post setObject:[PFUser currentUser] forKey:@"user"];
            [post setObject:[NSNumber numberWithBool:NO] forKey:@"expired"];
            [post setObject:[NSNumber numberWithBool:NO] forKey:@"sold"];
            NSArray *brokenString = [self.ticketsPostView.priceField.text componentsSeparatedByString:@"$"];
            NSString *priceNoSymbol = [brokenString objectAtIndex:1];
            [post setObject:priceNoSymbol forKey:@"price"];
            
            if (_selectedLocation != nil){
                PFGeoPoint *selectedGeopoint = [PFGeoPoint geoPointWithLocation:(CLLocation *)[_selectedLocation objectForKey:@"coordinate"]];
                [post setObject:selectedGeopoint forKey:@"location"];
                
            }
            if (_postImageData != nil){
                PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:_postImageData];
                [post setObject:imageFile forKey:@"imageFile"];
            }
            
            PFACL *readOnlyUserWriteACL = [PFACL ACL];
            [readOnlyUserWriteACL setPublicReadAccess:YES];
            [readOnlyUserWriteACL setWriteAccess:YES forUser:[PFUser currentUser]];
            post.ACL = readOnlyUserWriteACL;
            
            [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error){
                    [saveHUD hide:YES];
                }
            }];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }

    }
    
}

- (IBAction)photoButtonPressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Delete Picture"
                                                    otherButtonTitles:@"Take a Picture",@"Choose from Library", nil];
    [actionSheet showInView:self.view];
}

- (IBAction)locationButtonPressed:(id)sender {
    PostLocationViewController *locationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PostLocationViewController"];
    locationViewController.postLocationDelegate = self;
    if (_selectedLocation != nil){
        locationViewController.locationFormerlySelected = [_selectedLocation objectForKey:@"name"];
    }
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:locationViewController];
    [self presentViewController:navigationController animated:YES completion:nil];

}

#pragma mark PostLocationViewControllerDelegate

-(void)postLocationViewController:(PostLocationViewController *)controller didFinishSelecting:(NSDictionary *)location{
    _selectedLocation = location;
//    [
//    _locationButton setBackgroundImage:[UIImage imageNamed:@"locationSelected"] forState:UIControlStateNormal];
    [_locationTableView reloadData];
}

#pragma mark ChooseTypeTableViewControllerDelegate

- (void)chooseTypeTableViewController:(ChooseTypeTableViewController *)controller didFinishSelecting:(NSString *)type{
    _selectedType = type;
    [_typeTableView reloadData];
    [self displayNewTypeView];
    
}

# pragma mark UITextView

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

# pragma mark UIActionSheetDelegate & UIImagePickerController

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
        _postImageData = nil;
        UIImage *cameraImage = [UIImage imageNamed:@"cameraButton"];
        if ([_selectedType isEqualToString: @"Free"]){
            [self.freePostView.cameraButton setImage:cameraImage forState:UIControlStateNormal];
            self.freePostView.cameraButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
        } else if ([_selectedType isEqualToString: @"Books"]){
            [self.booksPostView.cameraButton setImage:cameraImage forState:UIControlStateNormal];
            self.booksPostView.cameraButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
        } else if ([_selectedType isEqualToString: @"Electronics"]){
            [self.defaultPostView.cameraButton setImage:cameraImage forState:UIControlStateNormal];
            self.defaultPostView.cameraButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
        } else if ([_selectedType isEqualToString: @"Tickets"]){
            [self.ticketsPostView.cameraButton setImage:cameraImage forState:UIControlStateNormal];
            self.ticketsPostView.cameraButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
        }
        [actionSheet dismissWithClickedButtonIndex:2 animated:YES];
    }
    
}

- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    if ([_selectedType isEqualToString: @"Free"]){
            [self.freePostView.cameraButton setImage:image forState:UIControlStateNormal];
            self.freePostView.cameraButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    } else if ([_selectedType isEqualToString: @"Books"]){
            [self.booksPostView.cameraButton setImage:image forState:UIControlStateNormal];
            self.booksPostView.cameraButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    } else if ([_selectedType isEqualToString: @"Electronics"]){
            [self.defaultPostView.cameraButton setImage:image forState:UIControlStateNormal];
            self.defaultPostView.cameraButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    } else if ([_selectedType isEqualToString: @"Tickets"]){
            [self.ticketsPostView.cameraButton setImage:image forState:UIControlStateNormal];
            self.ticketsPostView.cameraButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    // Resize image
    UIGraphicsBeginImageContext(CGSizeMake(640, 960));
    [image drawInRect: CGRectMake(0, 0, 640, 960)];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Upload image
    NSData *imageData = UIImageJPEGRepresentation(image, 0.05f);
    _postImageData = imageData;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([_selectedType isEqualToString: @"Free"]){

    } else if ([_selectedType isEqualToString: @"Books"]){
        if (textField == self.booksPostView.priceField){
            if (textField.text.length  == 0)
            {
                textField.text = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
            }
        }

    } else if ([_selectedType isEqualToString: @"Electronics"]){
        if (textField == self.defaultPostView.priceField){
            if (textField.text.length  == 0)
            {
                textField.text = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
            }
        }

    } else if ([_selectedType isEqualToString: @"Tickets"]){
        if (textField == self.ticketsPostView.priceField){
            if (textField.text.length  == 0)
            {
                textField.text = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
            }
        }

    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([_selectedType isEqualToString: @"Free"]){
        
    } else if ([_selectedType isEqualToString: @"Books"]){
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
        
    } else if ([_selectedType isEqualToString: @"Electronics"]){
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
        
    } else if ([_selectedType isEqualToString: @"Tickets"]){
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
    return NO;
}

# pragma mark - View setup based on type

-(void)displayNewTypeView{
    ChosenTypeTableViewCell *typeCell = (ChosenTypeTableViewCell*)[self.typeTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSString* typeSelected = typeCell.typeLabel.text;
    NSLog(@"%@", typeSelected);
    self.booksPostView.hidden = YES;
    self.freePostView.hidden = YES;
    self.defaultPostView.hidden = YES;
    self.ticketsPostView.hidden = YES;
    if ([typeSelected isEqualToString: @"Free"]){
        [self.freePostView setHidden:NO];
        [self setupFreePostView];
    } else if ([typeSelected isEqualToString: @"Books"]){
        [self.booksPostView setHidden:NO];
        [self setupBooksPostView];
    } else if ([typeSelected isEqualToString: @"Electronics"]){
        [self.defaultPostView setHidden:NO];
        [self setupElectronicsPostView];
    } else if ([typeSelected isEqualToString: @"Tickets"]){
        [self.ticketsPostView setHidden:NO];
        [self setupTicketsPostView];
    }
}

-(void) setupFreePostView{
    self.freePostView.layer.cornerRadius = 15.0;
    self.freePostView.layer.masksToBounds=YES;
    self.freePostView.layer.borderColor=[[UIColor clearColor]CGColor];
    self.freePostView.layer.borderWidth= 1.0f;
    self.freePostView.descriptionField.delegate = self;
    self.freePostView.descriptionField.text = @"Add description...";
    self.freePostView.descriptionField.textColor = [UIColor lightGrayColor];
    [self.booksPostView.cameraButton addTarget:self action:@selector(photoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

-(void) setupBooksPostView{
    self.booksPostView.layer.cornerRadius = 15.0;
    self.booksPostView.layer.masksToBounds=YES;
    self.booksPostView.layer.borderColor=[[UIColor clearColor]CGColor];
    self.booksPostView.layer.borderWidth= 1.0f;
    self.booksPostView.descriptionField.delegate = self;
    self.booksPostView.descriptionField.text = @"Add description...";
    self.booksPostView.descriptionField.textColor = [UIColor lightGrayColor];
    self.booksPostView.priceField.delegate = self;
    [self.booksPostView.cameraButton addTarget:self action:@selector(photoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

-(void) setupElectronicsPostView{
    self.defaultPostView.layer.cornerRadius = 15.0;
    self.defaultPostView.layer.masksToBounds=YES;
    self.defaultPostView.layer.borderColor=[[UIColor clearColor]CGColor];
    self.defaultPostView.layer.borderWidth= 1.0f;
    self.defaultPostView.descriptionField.delegate = self;
    self.defaultPostView.descriptionField.text = @"Add description...";
    self.defaultPostView.priceField.delegate = self;
    self.defaultPostView.descriptionField.textColor = [UIColor lightGrayColor];
    [self.defaultPostView.cameraButton addTarget:self action:@selector(photoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

-(void) setupTicketsPostView{
    self.ticketsPostView.layer.cornerRadius = 15.0;
    self.ticketsPostView.layer.masksToBounds=YES;
    self.ticketsPostView.layer.borderColor=[[UIColor clearColor]CGColor];
    self.ticketsPostView.layer.borderWidth= 1.0f;
    self.ticketsPostView.descriptionField.delegate = self;
    self.ticketsPostView.descriptionField.text = @"Add description...";
    self.ticketsPostView.priceField.delegate = self;
    self.ticketsPostView.descriptionField.textColor = [UIColor lightGrayColor];
    [self.ticketsPostView.cameraButton addTarget:self action:@selector(photoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

@end
