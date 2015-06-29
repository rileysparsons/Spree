//
//  PostFieldViewController.m
//  
//
//  Created by Riley Steele Parsons on 6/28/15.
//
//

#import "PostFieldViewController.h"

@interface PostFieldViewController ()

@end

@implementation PostFieldViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelWorkflow)];
    [self setupTextField];
}

-(void)setupTextField{
    self.fieldTextField.font = [UIFont systemFontOfSize:45.0f];
    self.fieldTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(self.fieldName, @" ")                                     attributes:@{NSForegroundColorAttributeName: [UIColor spreeOffBlack]}];
    self.fieldTextField.floatingLabelFont = [UIFont boldSystemFontOfSize:15.0f];
    self.fieldTextField.floatingLabelTextColor = [UIColor spreeDarkBlue];
    self.fieldTextField.tintColor = [UIColor spreeDarkBlue];
    self.fieldTextField.backgroundColor = [UIColor clearColor];
    self.fieldTextField.textAlignment = NSTextAlignmentCenter;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *)fieldTitleForField:(NSString *)field{
    if ([@"price" isEqualToString:field]){
        return @"Price";
    } else if ([@"description" isEqualToString:field]){
        return @"Description";
    } else if ([@"title" isEqualToString:field]){
        return @"Title";
    } else if ([@"dateForEvent" isEqualToString:field]){
        return @"Event Date";
    } else if ([@"event" isEqualToString:field]){
        return @"Event";
    }
    return field;
}

-(void)cancelWorkflow{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)nextBarButtonItemTouched:(id)sender {
    UIViewController *nextViewController =[self.postingWorkflow nextViewController];
    [self.navigationController pushViewController:nextViewController animated:YES];
}
@end
