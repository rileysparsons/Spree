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

@property UIButton *countBarButton;

@end

@implementation PostFieldViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setMaxCharacterLimit];
    self.fieldDisplayName = [self fieldTitleForField:self.fieldName];
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

    self.countBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.countBarButton.frame = CGRectZero;
    self.countBarButton.titleLabel.font = [UIFont fontWithName:@"Lato-Bold" size:16];
    self.countBarButton.userInteractionEnabled = NO;
    [self.countBarButton setTitle:[NSString stringWithFormat:@"%@ characters remaining", [remainingCharacters stringValue]] forState:UIControlStateNormal];
    [self.countBarButton setTitleColor:[UIColor spreeDarkBlue] forState:UIControlStateNormal];
    [self.countBarButton sizeToFit];
    self.countBarButton.backgroundColor = [UIColor clearColor];
    
    UIButton *nextButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 40)];
    nextButton.backgroundColor = [UIColor clearColor];
    [nextButton setImage:[UIImage imageNamed:@"forwardNormal_Dark"] forState:UIControlStateNormal];
    [nextButton setImage:[UIImage imageNamed:@"forwardHighlight_Dark"] forState:UIControlStateHighlighted];
    nextButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [nextButton addTarget:self action:@selector(nextBarButtonItemTouched:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *nextBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:nextButton];
    
    UIBarButtonItem *countBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.countBarButton];
    [self.navigationItem setRightBarButtonItems:@[nextBarButtonItem, countBarButtonItem] animated:YES];
    [[self.navigationItem.rightBarButtonItems objectAtIndex:0] setEnabled: [self fieldIsFilled]];
}

-(void)setupTextField {
    if (self.postingWorkflow.post[self.fieldName]){
        if ([self.fieldName isEqualToString:PF_POST_PRICE]){
           self.fieldTextView.text = [NSString stringWithFormat:@"$%@", ((NSNumber *)self.postingWorkflow.post[self.fieldName]).stringValue];
             NSLog(@"%@", ((NSNumber *)self.postingWorkflow.post[self.fieldName]).stringValue);
        } else {
           self.fieldTextView.text = self.postingWorkflow.post[self.fieldName];
        }
    } else {
        if ([self.fieldName isEqualToString: PF_POST_PRICE] && self.fieldTextView.text){
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

-(void)setMaxCharacterLimit{
    int limit;
    if ([PF_POST_PRICE isEqualToString:self.fieldName]){
        limit = 10;
    } else if ([PF_POST_DESCRIPTION isEqualToString:self.fieldName]){
        limit = 140;
    } else if ([PF_POST_TITLE isEqualToString:self.fieldName]){
        limit = 60;
    } else if ([PF_POST_DATEFOREVENT isEqualToString:self.fieldName]){
        limit = 10;
    } else if ([PF_POST_EVENT isEqualToString:self.fieldName]){
        limit = 60;
    } else if ([PF_POST_BOOKFORCLASS  isEqualToString:self.fieldName]){
        limit = 10;
    }
    maxCharacter = [NSNumber numberWithInt:limit];
    remainingCharacters = maxCharacter;
}

-(NSString *)fieldTitleForField:(NSString *)field{
    if ([PF_POST_PRICE isEqualToString:field]){
        return @"Enter price.";
    } else if ([PF_POST_DESCRIPTION isEqualToString:field]){
        return @"Write a short description.";
    } else if ([PF_POST_TITLE isEqualToString:field]){
        return @"Title your post.";
    } else if ([PF_POST_DATEFOREVENT isEqualToString:field]){
        return @"When is the date of event?";
    } else if ([PF_POST_EVENT isEqualToString:field]){
        return @"What is the name of the event?";
    } else if ([PF_POST_BOOKFORCLASS isEqualToString:field]){
        return @"What class is this for?";
    }
    return field;
}

-(void)cancelWorkflow{
    self.postingWorkflow.step--;
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)textViewDidChange:(UITextView *)textView{
    if (self.fieldTextView.text.length <= [maxCharacter integerValue]){
        self.countBarButton.titleLabel.textColor = [UIColor spreeDarkBlue];
    } else {
        [self.countBarButton setTitleColor:[UIColor spreeRed] forState:UIControlStateNormal];
    }
    remainingCharacters = [NSNumber numberWithInt:(int)([maxCharacter integerValue] - (int)self.fieldTextView.text.length)];
    [self.countBarButton setTitle:[NSString stringWithFormat:@"%@ characters remaining", [remainingCharacters stringValue]] forState:UIControlStateNormal];
    [self.countBarButton sizeToFit];
    [self.countBarButton setNeedsDisplay];
    [[self.navigationItem.rightBarButtonItems objectAtIndex:0] setEnabled: [self fieldIsFilled]];
}

-(BOOL)fieldIsFilled{
    if ([remainingCharacters integerValue] >= 0 && [remainingCharacters integerValue]< [maxCharacter integerValue]){
        return YES;
    } else {
        return NO;
    }
}

- (NSNumber *)getPriceFromString:(NSString *)price{
    if ([price length] == 0) {
        return 0;
    }
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *priceNumber = [formatter numberFromString:[[price componentsSeparatedByString:@"$"] objectAtIndex:1]];
    return priceNumber;
}

- (void)nextBarButtonItemTouched:(id)sender {
     NSLog(@"%@", self.fieldTextView.text);
    if ([self.fieldName isEqualToString: PF_POST_PRICE])
        self.postingWorkflow.post[self.fieldName] = [self getPriceFromString:self.fieldTextView.text];
    else
        self.postingWorkflow.post[self.fieldName] = self.fieldTextView.text;
    
    self.postingWorkflow.step++;
    UIViewController *nextViewController =[self.postingWorkflow nextViewController];
    [self.navigationController pushViewController:nextViewController animated:YES];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([self.fieldName isEqualToString: PF_POST_PRICE]){
        NSString *textInView  = textView.text;
        NSString *decimalSeperator = @".";
        NSCharacterSet *charSet    = nil;
        NSString *numberChars      = @"0123456789";
        
        
        // the number formatter will only be instantiated once ...
        
        static NSNumberFormatter *numberFormatter;
        if (!numberFormatter)
        {
            numberFormatter = [[NSNumberFormatter alloc] init];
            numberFormatter.numberStyle           = NSNumberFormatterCurrencyStyle;
            numberFormatter.maximumFractionDigits = 10;
            numberFormatter.minimumFractionDigits = 0;
            numberFormatter.decimalSeparator      = decimalSeperator;
            numberFormatter.usesGroupingSeparator = NO;
        }
        
        
        // create a character set of valid chars (numbers and optionally a decimal sign) ...
        
        NSRange decimalRange = [textInView rangeOfString:decimalSeperator];
        BOOL isDecimalNumber = (decimalRange.location != NSNotFound);
        if (isDecimalNumber)
        {
            charSet = [NSCharacterSet characterSetWithCharactersInString:numberChars];
        }
        else
        {
            numberChars = [numberChars stringByAppendingString:decimalSeperator];
            charSet = [NSCharacterSet characterSetWithCharactersInString:numberChars];
        }
        
        
        // remove amy characters from the string that are not a number or decimal sign ...
        
        NSCharacterSet *invertedCharSet = [charSet invertedSet];
        NSString *trimmedString = [text stringByTrimmingCharactersInSet:invertedCharSet];
        textInView = [textInView stringByReplacingCharactersInRange:range withString:trimmedString];
        
        
        // whenever a decimalSeperator is entered, we'll just update the textField.
        // whenever other chars are entered, we'll calculate the new number and update the textField accordingly.
        
        if ([text isEqualToString:decimalSeperator] == YES)
        {
            textView.text = textInView;
        }
        else
        {
            NSNumber *number = [numberFormatter numberFromString:textInView];
            NSLog(@"number: %@", number);
            if (number == nil)
            {
                number = [NSNumber numberWithInt:0];
            }
            textView.text = isDecimalNumber ? textInView : [numberFormatter stringFromNumber:number];
        }
        remainingCharacters = [NSNumber numberWithInt:(int)([maxCharacter integerValue] - (int)self.fieldTextView.text.length)];
        [self.countBarButton setTitle:[NSString stringWithFormat:@"%@ characters remaining", [remainingCharacters stringValue]] forState:UIControlStateNormal];
        [[self.navigationItem.rightBarButtonItems objectAtIndex:0] setEnabled: [self fieldIsFilled]];
        return NO; // we return NO because we have manually edited the textField contents
    }
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self nextBarButtonItemTouched:nil];
    return YES;
}


@end
