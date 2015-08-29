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
#import "PostingWorkflow.h"
#import "SpreePost.h"
#import "PostingInputAccessoryView.h"
#import "PostingDataEntryViewController.h"

@interface PostingStringEntryViewController : PostingDataEntryViewController <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet SAMTextView *fieldTextView;
@property NSArray *requiredFields;
@property PostingInputAccessoryView *accessoryView;

-(void)setupTextField;
- (void)nextBarButtonItemTouched:(id)sender;

@end
