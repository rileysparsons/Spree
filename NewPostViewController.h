//
//  NewPostViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 12/14/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChooseTypeTableViewController.h"
#import "PostLocationViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <TPKeyboardAvoiding/TPKeyboardAvoidingScrollView.h>

@class NewFreePostView;
@class NewBooksPostView;
@class NewDefaultPostView;
@class NewTicketsPostView;

@interface NewPostViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ChooseTypeTableViewControllerDelegate, PostLocationViewControllerDelegate, UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MBProgressHUDDelegate, UITextFieldDelegate> {
    
    MBProgressHUD *saveHUD;
}

@property (weak, nonatomic) IBOutlet UITableView *typeTableView;
@property (weak, nonatomic) IBOutlet UITableView *locationTableView;
@property (weak, nonatomic) IBOutlet NewTicketsPostView *ticketsPostView;
@property (weak, nonatomic) IBOutlet NewFreePostView *freePostView;
@property (weak, nonatomic) IBOutlet NewBooksPostView *booksPostView;
@property (weak, nonatomic) IBOutlet NewDefaultPostView *defaultPostView;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *avoidingScrollView;
@property NSData *postImageData;

-(void)chooseTypeTableViewController:(ChooseTypeTableViewController *)controller didFinishSelecting:(NSString *)type;
-(void)postLocationViewController:(PostLocationViewController *)controller didFinishSelecting:(NSDictionary *)location;
- (IBAction)postButtonPressed:(id)sender;
- (IBAction)photoButtonPressed:(id)sender;
- (IBAction)locationButtonPressed:(id)sender;

@end
