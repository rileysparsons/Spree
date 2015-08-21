//
//  PostPriceEntryViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 8/19/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "PostPriceEntryViewController.h"

@interface PostPriceEntryViewController (){
    NSNumber *maxCharacter;
}

@end

@implementation PostPriceEntryViewController

-(void)initWithField:(NSDictionary *)field{
    self.fieldTitle = field[@"field"];
    if ([field[@"field"] isEqualToString:PF_POST_PRICE]){
        self.symbolLabel.text = @"$";
        if (field[@"maxCharacter"]) {
            maxCharacter = field[@"maxCharacter"];
        } else {
            maxCharacter = [NSNumber numberWithInt:4];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self formatPriceEntryView];
    self.priceTextField.delegate = self;
    
}

-(void)formatPriceEntryView{
    self.priceEntryView.layer.borderWidth = 0.5f;
    self.priceEntryView.layer.borderColor = [[UIColor spreeOffBlack] CGColor];
    self.priceEntryView.layer.cornerRadius = 5.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)validatePrice:(NSString *)price{
    if (maxCharacter){
        if (price && price.length != 0){
            return YES;
        } else {
            return NO;
        }
    } else {
        if (price && price.length > 0){
            return YES;
        }
    }
    return NO;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    [[self.navigationItem.rightBarButtonItems objectAtIndex:0] setEnabled:[self validatePrice:string]];
    return YES;
}

- (void)nextBarButtonItemTouched:(id)sender {
    if ([self.fieldTitle isEqualToString: PF_POST_PRICE])
        self.postingWorkflow.post[self.fieldTitle] = [self getPriceFromString:self.priceTextField.text];
    else
        self.postingWorkflow.post[self.fieldTitle] = self.priceTextField.text;
    
    self.postingWorkflow.step++;
    UIViewController *nextViewController =[self.postingWorkflow nextViewController];
    [self.navigationController pushViewController:nextViewController animated:YES];
}

- (NSNumber *)getPriceFromString:(NSString *)price{
    if ([price length] == 0) {
        return 0;
    }
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterNoStyle;
    NSNumber *priceNumber = [formatter numberFromString:price];
    return priceNumber;
}

@end
