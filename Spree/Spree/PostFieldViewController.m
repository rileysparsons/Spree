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
    self.navigationController.navigationItem.title = nil;
    self.fieldDisplayName = [self fieldTitleForField:self.fieldName];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelWorkflow)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor spreeRed];
    [self setupTextField];
    UIButton *nextButton = [[YHRoundBorderedButton alloc] init];
    [nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextBarButtonItemTouched:) forControlEvents:UIControlEventTouchUpInside];
    [nextButton sizeToFit];
    [nextButton setTintColor:[UIColor spreeDarkBlue]];
    [nextButton setTitleColor:[UIColor spreeOffWhite] forState:UIControlStateHighlighted];
    
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
    
    self.countBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.countBarButton.frame = CGRectZero;
    self.countBarButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.countBarButton setTitle:[remainingCharacters stringValue] forState:UIControlStateNormal];
    [self.countBarButton setTitleColor:[UIColor spreeDarkBlue] forState:UIControlStateNormal];
    [self.countBarButton sizeToFit];
    self.countBarButton.backgroundColor = [UIColor clearColor];
    
    UIBarButtonItem *countBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.countBarButton];
    [self.navigationItem setRightBarButtonItems:@[[[UIBarButtonItem alloc] initWithCustomView:nextButton], countBarButtonItem] animated:YES];
    [[self.navigationItem.rightBarButtonItems objectAtIndex:0] setEnabled: [self fieldIsFilled]];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:NO];
    if ([self.fieldName isEqualToString: PF_POST_PRICE] && [self.fieldTextView.text isEqualToString:@"0"])
        [self textView:self.fieldTextView shouldChangeTextInRange:NSMakeRange(0, 0) replacementText:@"0"];
}

-(void)setupTextField{
    self.fieldTextView.font = [UIFont systemFontOfSize:25.0f];
    self.fieldTextView.placeholder =NSLocalizedString(self.fieldDisplayName, @" ");
    self.fieldTextView.placeholderTextColor = [UIColor darkGrayColor];
    self.fieldTextView.floatingLabelFont = [UIFont boldSystemFontOfSize:15.0f];
    self.fieldTextView.floatingLabelTextColor = [UIColor spreeDarkBlue];
    self.fieldTextView.floatingLabel.backgroundColor = [UIColor clearColor];
    self.fieldTextView.floatingLabelYPadding = -20.0f;
    self.fieldTextView.tintColor = [UIColor spreeDarkBlue];
    self.fieldTextView.floatingLabelShouldLockToTop = NO;
    self.fieldTextView.backgroundColor = [UIColor clearColor];
    self.fieldTextView.delegate = self;
    if ([self.fieldName isEqualToString: PF_POST_PRICE] && self.fieldTextView.text == nil)
        self.fieldTextView.text = @"0";
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
    }
    maxCharacter = [NSNumber numberWithInt:limit];
    remainingCharacters = maxCharacter;
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    }
    return field;
}

-(void)cancelWorkflow{
    self.postingWorkflow.step--;
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)textViewDidChange:(UITextView *)textView{
    if (self.fieldTextView.text.length <= [maxCharacter integerValue]){
         self.countBarButton.tintColor = [UIColor spreeDarkBlue];
    } else {
        self.countBarButton.tintColor = [UIColor spreeRed];
    }
    remainingCharacters = [NSNumber numberWithInt:(int)([maxCharacter integerValue] - (int)self.fieldTextView.text.length)];
    self.countBarButton.titleLabel.text = [NSString stringWithFormat:@"%@", remainingCharacters];
    [[self.navigationItem.rightBarButtonItems objectAtIndex:0] setEnabled: [self fieldIsFilled]];
}

//-(void)textViewDidBeginEditing:(UITextView *)textView{
//    NSString *testString;
//    if ([self.fieldName isEqualToString: PF_POST_PRICE]){
//        testString = self.fieldTextView.text;
//        if (testString.length == 0){
//            self.fieldTextView.text = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
//        }
//    }
//    [[self.navigationItem.rightBarButtonItems objectAtIndex:0] setEnabled: [self fieldIsFilled]];
//}

-(BOOL)fieldIsFilled{
    if ([remainingCharacters integerValue] >= 0 && [remainingCharacters integerValue]< [maxCharacter integerValue]){
        return YES;
    } else {
        return NO;
    }
}


//-(void)setCharacterCountLabel{
//    if (self.fieldTextView.text.length <= [maxCharacter integerValue]){
//        self.characterCountLabel.textColor = [UIColor spreeDarkBlue];
//    } else {
//        self.characterCountLabel.textColor = [UIColor spreeRed];
//    }
//    self.characterCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.fieldTextView.text.length];
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
            if (number == nil)
            {
                number = [NSNumber numberWithInt:0];
            }
            textView.text = isDecimalNumber ? textInView : [numberFormatter stringFromNumber:number];
        }
        remainingCharacters = [NSNumber numberWithInt:(int)([maxCharacter integerValue] - (int)self.fieldTextView.text.length)];
        self.countBarButton.titleLabel.text = [NSString stringWithFormat:@"%@", remainingCharacters];
        [[self.navigationItem.rightBarButtonItems objectAtIndex:0] setEnabled: [self fieldIsFilled]];
        return NO; // we return NO because we have manually edited the textField contents
    }
    return YES;
}


@end
