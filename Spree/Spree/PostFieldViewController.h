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

@interface PostFieldViewController : UIViewController <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet SAMTextView *fieldTextView;
@property NSString *fieldTitle;
@property NSString *prompt;
@property NSArray *requiredFields;
@property SpreePost *post;
@property PostingWorkflow *postingWorkflow;
@property PostingInputAccessoryView *accessoryView;

-(void)initializeViewControllerWithField:(NSDictionary *)field;
-(void)setupTextField;
-(void)navigationBarButtons;
- (void)nextBarButtonItemTouched:(id)sender;

@end
