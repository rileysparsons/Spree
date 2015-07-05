//
//  PostFieldViewController.h
//  
//
//  Created by Riley Steele Parsons on 6/28/15.
//
//

#import <UIKit/UIKit.h>
#import <JVFloatLabeledTextField/JVFloatLabeledTextView.h>
#import "PostingWorkflow.h"

@interface PostFieldViewController : UIViewController <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet JVFloatLabeledTextView *fieldTextView;
@property NSString *fieldName;
@property NSArray *requiredFields;
@property PFObject *post;
@property PostingWorkflow *postingWorkflow;

- (void)nextBarButtonItemTouched:(id)sender;

@end
