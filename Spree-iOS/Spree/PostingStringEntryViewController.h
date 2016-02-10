//
//  PostFieldViewController.h
//  
//
//  Created by Riley Steele Parsons on 6/28/15.
//
//

#import <UIKit/UIKit.h>
#import <JVFloatLabeledTextField/JVFloatLabeledTextView.h>
#import <SAMTextView/SAMTextView.h>
#import "PostingWorkflowViewModel.h"
#import "SpreePost.h"
#import "PostingInputAccessoryView.h"
#import "PostingDataEntryViewController.h"
#import "PostingStringEntryViewModel.h"

@interface PostingStringEntryViewController : UIViewController <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet SAMTextView *fieldTextView;
@property PostingStringEntryViewModel *viewModel;
@property UIButton *nextButton;
@property UIButton *cancelButton;
-(void)setupTextField;

@end
