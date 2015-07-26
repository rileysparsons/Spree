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
#import "SpreePost.h"

@interface PostFieldViewController : UIViewController <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet JVFloatLabeledTextView *fieldTextView;
@property NSString *fieldName;
@property NSString *fieldDisplayName;
@property NSArray *requiredFields;
@property SpreePost *post;
@property PostingWorkflow *postingWorkflow;

-(void)setupTextField;
-(void)navigationBarButtons;
- (void)nextBarButtonItemTouched:(id)sender;

@end
