//
//  NewPostTypeSelectionViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 3/8/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "NewPostTypeSelectionViewController.h"
#import "NewPostInfoViewController.h"

@interface NewPostTypeSelectionViewController (){
    NSArray *typeArray;
}

@end

@implementation NewPostTypeSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    typeArray = [[NSArray alloc] initWithObjects:@"Electronics", @"Free", @"Tickets", @"Books", nil];
    
    self.navigationItem.title = @"Choose post type";
    
    self.post = [[SpreePost alloc] init];
    self.typePickerView.delegate = self;
    self.typePickerView.dataSource = self;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return typeArray.count;
}

-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return typeArray[row];
}
- (IBAction)nextBarButtonItemPressed:(id)sender {
    NSString *selectedType = [typeArray objectAtIndex:[self.typePickerView selectedRowInComponent:0]];
    if ([selectedType isEqualToString:@"Free"]){
        [self performSegueWithIdentifier:@"showNewFreePostDetail" sender:self];
        [self.post setType:@"Free"];
    } else if ([selectedType isEqualToString:@"Books"]) {
        [self performSegueWithIdentifier:@"showNewBooksPostDetail" sender:self];
        [self.post setType:@"Books"];
    } else if ([selectedType isEqualToString:@"Electronics"]) {
        [self performSegueWithIdentifier:@"showNewElectronicsPostDetail" sender:self];
        [self.post setType:@"Electronics"];
    } else if ([selectedType isEqualToString:@"Tickets"]){
        [self performSegueWithIdentifier:@"showNewTicketsPostDetail" sender:self];
        [self.post setType:@"Tickets"];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NewPostInfoViewController *newPostInfoViewController = (NewPostInfoViewController *)[segue destinationViewController];
    [newPostInfoViewController setPost:self.post];
}

- (IBAction)cancelBarButtonItemPressed:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        nil;
    }];
}
@end
