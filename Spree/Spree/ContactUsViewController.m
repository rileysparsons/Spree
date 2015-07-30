//
//  ContactUsViewController.m
//  Spree
//
//  Created by Hamilton Coke on 7/4/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "ContactUsViewController.h"

@interface ContactUsViewController ()
@end

@implementation ContactUsViewController

NSArray *pickerArray;
NSArray *textArray;
BOOL categorySelected;
BOOL edited;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    edited = false;
    categorySelected = false;
    
    //Makes the textview look like a text field
    [_descriptionTextView.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [_descriptionTextView.layer setBorderWidth:.5];
    _descriptionTextView.layer.cornerRadius = 5;
    _descriptionTextView.clipsToBounds = YES;
    _descriptionTextView.delegate = self;
    
    //List of categories the user can choose from when contacting us
    pickerArray = @[@"Problem 1", @"Problem 2", @"Problem 3", @"Problem 4"];
    
    //List of descriptions that match with the categories the user can choose
    textArray = @[@"Problem 1 description", @"Problem 2 description", @"Problem 3 description", @"Problem 4 description"];
    
    //Changes the input view for the category text field from a keyboard to a picker
    UIPickerView *pickerView = [[UIPickerView alloc] init];
    pickerView.dataSource = self;
    pickerView.delegate = self;
    self.categoryTextField.inputView = pickerView;
    
    //Adds a toolbar with a done button
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,320,44)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonWasPressed:)];
    UIBarButtonItem *flexibleSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    toolbar.items = @[flexibleSeparator, doneButton];
    self.categoryTextField.inputAccessoryView = toolbar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return pickerArray.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [pickerArray objectAtIndex:row];
}

//Tells what to do when a row is selected in the picker
- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //Sets the text of the text field equal to that of the selected category
    _categoryTextField.text = [pickerArray objectAtIndex:row];
    if (edited == false) {
        _descriptionTextView.text = [textArray objectAtIndex:row];
        _descriptionTextView.textColor = [UIColor grayColor];
    }
    _descriptionTextView.editable = true;
    _descriptionTextView.selectable = true;
    categorySelected = true;
}

//function for removing the picker view when the done button is pressed
-(void)doneButtonWasPressed:(id)sender {
    [_categoryTextField resignFirstResponder];
}

//function deletes the placeholder text when the user begins editing the textview
- (void)textViewDidBeginEditing:(UITextView *) textView {
    if (edited == false) {
        _descriptionTextView.text = @"";
        _descriptionTextView.textColor = [UIColor blackColor];
        edited = true;
    }
}

//shows the send button when there is text in the textView and removes the send button when there is no text in the textView.
- (void)textViewDidChange:(UITextView *)textView {
    //adds send button on the top
    if ([_descriptionTextView.text isEqualToString:@""]) {
        [self.navigationItem setRightBarButtonItem:nil animated:NO];
    }
    else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:self action:@selector(send:)];
    }
}

//function that is called when the send button is pressed
-(void)send:(id)sender {
    //I assume this is where the parse interaction will go
}


@end