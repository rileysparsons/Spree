//
//  PostFieldViewController.m
//  
//
//  Created by Riley Steele Parsons on 6/28/15.
//
//

#import "PostFieldViewController.h"
#import "YHRoundBorderedButton.h"


@interface PostFieldViewController (){
    NSNumber* maxCharacter;
    NSNumber* remainingCharacters;
}

@end

@implementation PostFieldViewController

-(void)initializeViewControllerWithField:(NSDictionary *)field{
    self.prompt = field[@"prompt"];
    self.fieldTitle = field[@"field"];
    if (field[@"characterLimit"]){
        maxCharacter = field[@"characterLimit"];
        remainingCharacters = maxCharacter;
        self.accessoryView = [[PostingInputAccessoryView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        self.fieldTextView.inputAccessoryView = self.accessoryView;
        [self formatRemainingCharacterLabel];
    }
    self.navigationItem.title = self.prompt;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self navigationBarButtons];
    [self setupTextField];
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:NO];
    [self.fieldTextView performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.1f];
}

-(void)navigationBarButtons{
    UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 40)];
    cancel.backgroundColor = [UIColor clearColor];
    [cancel setImage:[UIImage imageNamed:@"backNormal_Dark"] forState:UIControlStateNormal];
    [cancel setImage:[UIImage imageNamed:@"backHighlight_Dark"] forState:UIControlStateHighlighted];
    cancel.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cancel addTarget:self action:@selector(cancelWorkflow) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancel];
    
    UIButton *nextButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 40)];
    nextButton.backgroundColor = [UIColor clearColor];
    [nextButton setImage:[UIImage imageNamed:@"forwardNormal_Dark"] forState:UIControlStateNormal];
    [nextButton setImage:[UIImage imageNamed:@"forwardHighlight_Dark"] forState:UIControlStateHighlighted];
    nextButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [nextButton addTarget:self action:@selector(nextBarButtonItemTouched:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *nextBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:nextButton];
    
    [self.navigationItem setRightBarButtonItems:@[nextBarButtonItem] animated:YES];
    [[self.navigationItem.rightBarButtonItems objectAtIndex:0] setEnabled: [self fieldIsFilled]];
}

-(void)setupTextField {
    if (self.postingWorkflow.post[self.fieldTitle]){
        if ([self.fieldTitle isEqualToString:PF_POST_PRICE]){
           self.fieldTextView.text = [NSString stringWithFormat:@"$%@", ((NSNumber *)self.postingWorkflow.post[self.fieldTitle]).stringValue];
             NSLog(@"%@", ((NSNumber *)self.postingWorkflow.post[self.fieldTitle]).stringValue);
        } else {
           self.fieldTextView.text = self.postingWorkflow.post[self.fieldTitle];
        }
    } else {
        if ([self.fieldTitle isEqualToString: PF_POST_PRICE] && self.fieldTextView.text){
            [self.fieldTextView setKeyboardType:UIKeyboardTypeDecimalPad];
            self.fieldTextView.text = @"0";
            [self textView:self.fieldTextView shouldChangeTextInRange:NSMakeRange(0, 0) replacementText:@"0"];
        }
    }
    
//    [self.fieldTextView addRightButtonOnKeyboardWithText:@"Next" target:self action:@selector(nextBarButtonItemTouched:) shouldShowPlaceholder:YES];
    self.fieldTextView.font = [UIFont systemFontOfSize:25.0f];
//    self.fieldTextView.placeholder =NSLocalizedString(self.fieldDisplayName, @" ");
//    self.fieldTextView.placeholderTextColor = [UIColor darkGrayColor];
//    self.fieldTextView.floatingLabelFont = [UIFont boldSystemFontOfSize:15.0f];
//    self.fieldTextView.floatingLabelTextColor = [UIColor spreeDarkBlue];
//    self.fieldTextView.floatingLabel.backgroundColor = [UIColor clearColor];
//    self.fieldTextView.floatingLabelYPadding = -20.0f;
    self.fieldTextView.tintColor = [UIColor spreeDarkBlue];
//    self.fieldTextView.floatingLabelShouldLockToTop = NO;
    self.fieldTextView.backgroundColor = [UIColor clearColor];
    self.fieldTextView.delegate = self;
}


-(void)cancelWorkflow{
    self.postingWorkflow.step--;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)formatRemainingCharacterLabel {
    if (maxCharacter != nil){
        if (self.fieldTextView.text.length <= [maxCharacter integerValue]){
            self.accessoryView.remainingCharacterLabel.textColor = [UIColor spreeOffBlack];
        } else {
            self.accessoryView.remainingCharacterLabel.textColor = [UIColor spreeRed];
        }
        remainingCharacters = [NSNumber numberWithInt:(int)([maxCharacter integerValue] - (int)self.fieldTextView.text.length)];
        self.accessoryView.remainingCharacterLabel.text = [NSString stringWithFormat:@"%@ characters remaining", [remainingCharacters stringValue]];
    }
}

-(void)textViewDidChange:(UITextView *)textView{
    [self formatRemainingCharacterLabel];
    [[self.navigationItem.rightBarButtonItems objectAtIndex:0] setEnabled: [self fieldIsFilled]];
}

-(BOOL)fieldIsFilled{
    NSLog(@"%@", maxCharacter);
    if (maxCharacter){
        if ([remainingCharacters integerValue] >= 0 && [remainingCharacters integerValue]< [maxCharacter integerValue]){
            return YES;
        } else {
            return NO;
        }
    } else {
        if (self.fieldTextView.text && self.fieldTextView.text.length > 0){
            return YES;
        }
    }
    return NO;
}

- (void)nextBarButtonItemTouched:(id)sender {
    NSLog(@"%@", self.fieldTextView.text);
    
    
    self.postingWorkflow.post[self.fieldTitle] = self.fieldTextView.text;
    
    
    self.postingWorkflow.step++;
    UIViewController *nextViewController =[self.postingWorkflow nextViewController];
    [self.navigationController pushViewController:nextViewController animated:YES];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    [[self.navigationItem.rightBarButtonItems objectAtIndex:0] setEnabled: [self fieldIsFilled]];
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self nextBarButtonItemTouched:nil];
    return YES;
}



@end
