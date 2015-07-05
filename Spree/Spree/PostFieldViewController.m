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
}

@property UIBarButtonItem *countBarButton;

@end

@implementation PostFieldViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationItem.title = nil;
    self.fieldName = [self fieldTitleForField:self.fieldName];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelWorkflow)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor spreeRed];
    [self setupTextField];
    [self setMaxCharacterLimit];
    UIButton *nextButton = [[YHRoundBorderedButton alloc] init];
    [nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextBarButtonItemTouched:) forControlEvents:UIControlEventTouchUpInside];
    [nextButton sizeToFit];
    [nextButton setTintColor:[UIColor spreeDarkBlue]];
    [nextButton setTitleColor:[UIColor spreeOffWhite] forState:UIControlStateHighlighted];
    
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
    
    self.countBarButton = [[UIBarButtonItem alloc] initWithTitle:[maxCharacter stringValue] style:UIBarButtonItemStylePlain target:self action:nil];
    self.countBarButton.tintColor = [UIColor spreeDarkBlue];
    [self.navigationItem setRightBarButtonItems:@[[[UIBarButtonItem alloc] initWithCustomView:nextButton], self.countBarButton] animated:YES];
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
    maxCharacter = [NSNumber numberWithInt:60];
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
    int remainingCharacters;
    remainingCharacters = (int)([maxCharacter integerValue] - (int)self.fieldTextView.text.length);
    self.countBarButton.title = [NSString stringWithFormat:@"%d", remainingCharacters];
    
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
