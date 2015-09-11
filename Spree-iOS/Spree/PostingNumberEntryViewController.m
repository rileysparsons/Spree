//
//  PostPriceEntryViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 8/19/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "PostingNumberEntryViewController.h"

@interface PostingNumberEntryViewController (){
    NSNumber *maxCharacter;
}

@end

@implementation PostingNumberEntryViewController

-(void)initWithField:(NSDictionary *)field post:(SpreePost *)post{
    [super initWithField:field post:post];
    if ([field[@"field"] isEqualToString:PF_POST_PRICE]){
        self.symbolLabel.text = @"$";
        if (field[@"maxCharacter"]) {
            maxCharacter = field[@"maxCharacter"];
        } else {
            maxCharacter = [NSNumber numberWithInt:4];
        }
    }
}

-(void)initWithField:(NSDictionary *)field postingWorkflow:(PostingWorkflow *)postingWorkflow{
    [super initWithField:field postingWorkflow:postingWorkflow];
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
    // Add a "textFieldDidChange" notification method to the text field control.
    [self.priceTextField addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    [self formatPriceEntryView];
    self.priceTextField.delegate = self;
    self.promptLabel.text = self.prompt;
    [[self.navigationItem.rightBarButtonItems objectAtIndex:0] setEnabled:[self validatePrice:self.priceTextField.text]];
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
    
    NSLog(@"%lu", (unsigned long)price.length);
    if (price && price.length > 0 && price.length <= [maxCharacter intValue]){
        return YES;
    } else {
        return NO;
    }
}

- (void)nextBarButtonItemTouched:(id)sender {
    if ([self.fieldTitle isEqualToString: PF_POST_PRICE])
        self.postingWorkflow.post[self.fieldTitle] = [self getNumberFromString:self.priceTextField.text];
    else
        self.postingWorkflow.post[self.fieldTitle] = self.priceTextField.text;
    
    self.postingWorkflow.step++;
    [self.postingWorkflow.post[@"completedFields"] addObject:self.fieldDictionary];
    UIViewController *nextViewController =[self.postingWorkflow nextViewController];
    [self.navigationController pushViewController:nextViewController animated:YES];
}

- (NSNumber *)getNumberFromString:(NSString *)number{
    if ([number length] == 0) {
        return 0;
    }
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterNoStyle;
    NSNumber *formattedNumber = [formatter numberFromString:number];
    return formattedNumber;
}

-(void)cancelWorkflow{
    [super cancelWorkflow];
    [self.priceTextField resignFirstResponder];
}

-(void)textFieldDidChange: (id)sender{
    [[self.navigationItem.rightBarButtonItems objectAtIndex:0] setEnabled:[self validatePrice:self.priceTextField.text]];

}

@end
