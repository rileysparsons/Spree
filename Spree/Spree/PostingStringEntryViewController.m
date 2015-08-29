//
//  PostFieldViewController.m
//  
//
//  Created by Riley Steele Parsons on 6/28/15.
//
//

#import "PostingStringEntryViewController.h"
#import "YHRoundBorderedButton.h"


@interface PostingStringEntryViewController (){
    NSNumber* maxCharacter;
    NSNumber* remainingCharacters;
}

@end

@implementation PostingStringEntryViewController

-(void)initWithField:(NSDictionary *)field post:(SpreePost *)post{
    [super initWithField:field post:post];
    
    if (field[@"characterLimit"]){
        maxCharacter = field[@"characterLimit"];
        remainingCharacters = maxCharacter;
        self.accessoryView = [[PostingInputAccessoryView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        self.fieldTextView.inputAccessoryView = self.accessoryView;
        [self formatRemainingCharacterLabel];
    }
}

-(void)initWithField:(NSDictionary *)field postingWorkflow:(PostingWorkflow *)postingWorkflow{
    [super initWithField:field postingWorkflow:postingWorkflow];
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
    [self.nextButton setEnabled: [self fieldIsFilled]];
    [self setupTextField];

    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:NO];
    [self.fieldTextView performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.1f];
}

#pragma mark - Custom UI Formatting

-(void)setupTextField {
    
    self.fieldTextView.font = [UIFont systemFontOfSize:25.0f];
    
    UIFont *placeholderFont = [UIFont fontWithName:@"Lato-Regular" size:25.0f];
    
    NSDictionary *attributedPlaceholderDictionary = @{NSFontAttributeName : placeholderFont, NSForegroundColorAttributeName : [[UIColor spreeOffBlack] colorWithAlphaComponent:0.5f]};
    
    if (self.postingWorkflow.post[self.fieldTitle]){
        if ([self.fieldTitle isEqualToString:PF_POST_PRICE]){
           self.fieldTextView.text = [NSString stringWithFormat:@"$%@", ((NSNumber *)self.postingWorkflow.post[self.fieldTitle]).stringValue];
             NSLog(@"%@", ((NSNumber *)self.postingWorkflow.post[self.fieldTitle]).stringValue);
        } else {
            NSLog(@"%@", self.postingWorkflow);
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

#pragma mark - Data Validation

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

#pragma mark - TextView Delegate Methods

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    [[self.navigationItem.rightBarButtonItems objectAtIndex:0] setEnabled: [self fieldIsFilled]];
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView{
    [self formatRemainingCharacterLabel];
    [[self.navigationItem.rightBarButtonItems objectAtIndex:0] setEnabled: [self fieldIsFilled]];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self nextBarButtonItemTouched:nil];
    return YES;
}


- (void)nextBarButtonItemTouched:(id)sender {
    self.postingWorkflow.post[self.fieldTitle] = self.fieldTextView.text;
    if (self.presentedWithinWorkflow){
        [self.postingWorkflow.post[@"completedFields"] addObject:self.fieldDictionary];
        self.postingWorkflow.step++;
        UIViewController *nextViewController =[self.postingWorkflow nextViewController];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}

-(void)cancelWorkflow{
    [super cancelWorkflow];
    [self.fieldTextView resignFirstResponder];
}

@end
