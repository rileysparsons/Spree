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
    self.fieldName = [self fieldTitleForField:self.fieldName];
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


-(void)setupTextField{
    self.fieldTextView.font = [UIFont systemFontOfSize:20.0f];
    self.fieldTextView.placeholder =NSLocalizedString(self.fieldName, @" ");
    self.fieldTextView.placeholderTextColor = [UIColor darkGrayColor];
    self.fieldTextView.floatingLabelFont = [UIFont boldSystemFontOfSize:15.0f];
    self.fieldTextView.floatingLabelTextColor = [UIColor spreeDarkBlue];
    self.fieldTextView.floatingLabel.backgroundColor = [UIColor clearColor];
    self.fieldTextView.floatingLabelYPadding = -20.0f;
    self.fieldTextView.tintColor = [UIColor spreeDarkBlue];
    self.fieldTextView.floatingLabelShouldLockToTop = NO;
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
    [self.navigationController popToRootViewControllerAnimated:YES];
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

-(void)textViewDidBeginEditing:(UITextView *)textView{
    [[self.navigationItem.rightBarButtonItems objectAtIndex:0] setEnabled: [self fieldIsFilled]];
}

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

- (void)nextBarButtonItemTouched:(id)sender {
    UIViewController *nextViewController =[self.postingWorkflow nextViewController];
    [self.navigationController pushViewController:nextViewController animated:YES];
}
@end
