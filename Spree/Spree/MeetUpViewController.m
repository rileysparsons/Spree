//
//  MeetUpViewController.m
//  
//
//  Created by Maxwell on 5/14/15.
//
//

#import "ChatView.h"
#import "MeetUpViewController.h"


@interface MeetUpViewController () {
    NSArray *_pickerData;
    NSString *_locationSelection;
    NSString *_timeSelection;
}

@property (nonatomic, weak) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, weak) IBOutlet UIPickerView *placePicker;
@property (retain, nonatomic) UIBarButtonItem *postButton;
@property (retain, nonatomic) UIBarButtonItem *cancelButton;
@property (retain, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation MeetUpViewController


-(UIBarButtonItem *)postButton {
    if (!_postButton) {
        _postButton = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStylePlain target:self action:@selector(postMessage)];
        [_postButton setTintColor:[UIColor whiteColor]];
    }
    return _postButton;
}

-(UIBarButtonItem *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismissView)];
        [_cancelButton setTintColor:[UIColor whiteColor]];
    }
    return _cancelButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Meet Up";
    // Do any additional setup after loading the view.
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterFullStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    _pickerData = @[@"Benson", @"The Library Entrance", @"The Library Lobby", @"Mission Church", @"Cellar", @"Sobrato Fountain"];
    _locationSelection = _pickerData[0];
    _timeSelection= [self.dateFormatter stringFromDate:[NSDate date]];
 
    self.placePicker.dataSource = self;
    self.placePicker.delegate = self;
    
    //set the action method that will listen for changes to picker value
    [self.datePicker addTarget:self action:@selector(datePickerDateChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.navigationItem.rightBarButtonItem = self.postButton;
    self.navigationItem.leftBarButtonItem = self.cancelButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//listen to changes in the date picker and just log them
- (void) datePickerDateChanged:(UIDatePicker *)paramDatePicker{
        NSString *date = [self.dateFormatter stringFromDate: paramDatePicker.date];
        _timeSelection = date;
        NSLog(@"Selected date = %@", date);
}

// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _pickerData.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _pickerData[row];
}

// Catpure the picker view selection
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _locationSelection = _pickerData[row];
    NSLog(@"Selection: %@",_pickerData[row]);
}

- (void)dismissView {
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)postMessage{
    ChatView *chat = [[ChatView alloc] initWith:self.groupId post:self.post title:[[PFUser currentUser] objectForKey:@"username"]];
    NSString *output;
    output = @"Let's meet up on ";
    output = [output stringByAppendingString:_timeSelection];
    output = [output stringByAppendingString:@" at "];
    output = [output stringByAppendingString:_locationSelection];
    [chat sendMessage:output Video:nil Picture:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MeetUp" object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
