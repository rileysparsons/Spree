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
    UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    cancel.backgroundColor = [UIColor clearColor];
    [cancel setBackgroundImage:[UIImage imageNamed:@"cancelOffBlack"] forState:UIControlStateNormal];
    [cancel setBackgroundImage:[UIImage imageNamed:@"cancelHighlight"] forState:UIControlStateHighlighted];
    [cancel addTarget:self action:@selector(cancelWorkflow) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:cancel]];
    
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
    
    self.fieldTextView.font = [UIFont systemFontOfSize:25.0f];
    
    UIFont *placeholderFont = [UIFont fontWithName:@"Lato-Regular" size:25.0f];
    
    NSDictionary *attributedPlaceholderDictionary = @{NSFontAttributeName : placeholderFont, NSForegroundColorAttributeName : [[UIColor spreeOffBlack] colorWithAlphaComponent:0.5f]};
    
    if (self.postingWorkflow.post[self.fieldTitle]){
        if ([self.fieldTitle isEqualToString:PF_POST_PRICE]){
           self.fieldTextView.text = [NSString stringWithFormat:@"$%@", ((NSNumber *)self.postingWorkflow.post[self.fieldTitle]).stringValue];
             NSLog(@"%@", ((NSNumber *)self.postingWorkflow.post[self.fieldTitle]).stringValue);
        } else {
           self.fieldTextView.text = self.postingWorkflow.post[self.fieldTitle];
        }
    }
    if ([self.fieldTitle isEqualToString: PF_POST_PRICE]){
        NSAttributedString *placeholder = [[NSAttributedString alloc] initWithString:@"0.00" attributes:attributedPlaceholderDictionary];
        [self.fieldTextView setKeyboardType:UIKeyboardTypeNumberPad];
        self.fieldTextView.attributedPlaceholder = placeholder;
    } else {
        NSAttributedString *placeholder = [[NSAttributedString alloc] initWithString:self.prompt attributes:attributedPlaceholderDictionary];
        self.fieldTextView.attributedPlaceholder = placeholder;
    }
    self.fieldTextView.tintColor = [UIColor spreeDarkBlue];
    self.fieldTextView.backgroundColor = [UIColor clearColor];
    self.fieldTextView.delegate = self;
}


-(void)cancelWorkflow{
    [self.fieldTextView resignFirstResponder];
    self.postingWorkflow = nil;
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
