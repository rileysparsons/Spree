//
//  PostFieldViewController.h
//  
//
//  Created by Riley Steele Parsons on 6/28/15.
//
//

#import <UIKit/UIKit.h>
#import <JVFloatLabeledTextField/JVFloatLabeledTextField.h>
#import "PostingWorkflow.h"

@interface PostFieldViewController : UIViewController

@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *fieldTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextBarButtonItem;

@property NSString *fieldName;
@property NSArray *requiredFields;
@property PFObject *post;
@property PostingWorkflow *postingWorkflow;

- (IBAction)nextBarButtonItemTouched:(id)sender;

@end
