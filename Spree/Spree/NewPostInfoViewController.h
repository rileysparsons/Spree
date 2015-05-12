//
//  NewPostInfoViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 3/8/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "SpreePost.h"

@class NewBooksPostView, NewFreePostView, NewTicketsPostView, NewDefaultPostView, NewGenericPostView;

@interface NewPostInfoViewController : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *firstAddPhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *secondAddPhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *thirdAddPhotoButton;
@property (weak, nonatomic) IBOutlet NewTicketsPostView *ticketsPostView;
@property (weak, nonatomic) IBOutlet NewFreePostView *freePostView;
@property (weak, nonatomic) IBOutlet NewBooksPostView *booksPostView;
@property (weak, nonatomic) IBOutlet NewDefaultPostView *defaultPostView;
@property (weak, nonatomic) IBOutlet NewGenericPostView *genericPostView;
@property SpreePost *post;
@property UIBarButtonItem *postBarButtonItem;

- (IBAction)firstAddPhotoButtonPressed:(id)sender;
- (IBAction)secondAddPhotoButtonPressed:(id)sender;
- (IBAction)thirdAddPhotoButtonPressed:(id)sender;

@end
