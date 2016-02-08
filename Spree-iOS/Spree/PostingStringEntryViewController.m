//
//  PostFieldViewController.m
//  
//
//  Created by Riley Steele Parsons on 6/28/15.
//
//

#import "PostingStringEntryViewController.h"


@interface PostingStringEntryViewController (){
}

@property UIButton *cancelButton;
@property PostingInputAccessoryView *accessoryView;

@end

@implementation PostingStringEntryViewController

-(void)bindToViewModel {
    self.fieldTextView.text = self.viewModel.enteredString;
    RAC(self.viewModel, enteredString) = self.fieldTextView.rac_textSignal;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self bindToViewModel];
    
    [self setupTextField];

    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
    
    self.accessoryView = [[PostingInputAccessoryView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    self.fieldTextView.inputAccessoryView = self.accessoryView;
    
    [self formatRemainingCharacterLabel];
    [self navigationBarAppearance];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:NO];
    [self.fieldTextView performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.1f];
}

-(void)navigationBarAppearance{
    self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    self.cancelButton.backgroundColor = [UIColor clearColor];
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelOffBlack"] forState:UIControlStateNormal];
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelHighlight"] forState:UIControlStateHighlighted];
    [self.cancelButton addTarget:self action:@selector(cancelWorkflow) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:self.cancelButton]];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.cancelButton];
    
    self.nextButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 40)];
    self.nextButton.backgroundColor = [UIColor clearColor];
    [self.nextButton setImage:[UIImage imageNamed:@"forwardNormal_Dark"] forState:UIControlStateNormal];
    [self.nextButton setImage:[UIImage imageNamed:@"forwardHighlight_Dark"] forState:UIControlStateHighlighted];
    self.nextButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.nextButton.enabled = NO;
    self.nextButton.rac_command = self.viewModel.nextCommand;
    UIBarButtonItem *nextBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.nextButton];
    [self.navigationItem setRightBarButtonItems:@[nextBarButtonItem] animated:YES];
    
    UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 150, 40)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    // TODO: put client facing name into viewmodel
    /*
     titleLabel.text= [self.clientFacingName uppercaseString];
     */
    titleLabel.textColor=[UIColor spreeOffBlack];
    titleLabel.font = [UIFont fontWithName:@"Lato-Regular" size: 15];
    titleLabel.backgroundColor =[UIColor clearColor];
    titleLabel.adjustsFontSizeToFitWidth=YES;
    self.navigationItem.titleView=titleLabel;
}

-(void)cancelWorkflow{
    [[[UIAlertView alloc] initWithTitle:@"Cancel Post" message:@"Are you sure you want to cancel this post? You are able to edit the post prior to publishing." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Confirm", nil] show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex ==  0){
        [self.fieldTextView resignFirstResponder];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else if (buttonIndex == 1){
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    }
}

#pragma mark - Custom UI Formatting

-(void)setupTextField {
    
    self.fieldTextView.font = [UIFont systemFontOfSize:25.0f];
    
    UIFont *placeholderFont = [UIFont fontWithName:@"Lato-Regular" size:25.0f];
    
    NSDictionary *attributedPlaceholderDictionary = @{NSFontAttributeName : placeholderFont, NSForegroundColorAttributeName : [[UIColor spreeOffBlack] colorWithAlphaComponent:0.5f]};

    NSAttributedString *placeholder = [[NSAttributedString alloc] initWithString:self.viewModel.prompt attributes:attributedPlaceholderDictionary];
    self.fieldTextView.attributedPlaceholder = placeholder;

    self.fieldTextView.tintColor = [UIColor spreeDarkBlue];
    self.fieldTextView.backgroundColor = [UIColor clearColor];
    self.fieldTextView.delegate = self;
}

- (void)formatRemainingCharacterLabel {
    
    [[self.fieldTextView.rac_textSignal map:^id(id value) {
        if (0 <= self.viewModel.remainingCharacters){
            self.accessoryView.remainingCharacterLabel.textColor = [UIColor spreeOffBlack];
        } else {
            self.accessoryView.remainingCharacterLabel.textColor = [UIColor spreeRed];
        }
        return nil;
    }] subscribeNext:^(id x) {
        
    }];
    
    [RACObserve(self.viewModel, remainingCharacters) subscribeNext:^(NSNumber* number) {
        self.accessoryView.remainingCharacterLabel.text = [NSString stringWithFormat:@"%@ characters remaining", [number stringValue]];
    }];
}

@end
