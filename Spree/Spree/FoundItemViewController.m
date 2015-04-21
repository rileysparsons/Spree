//
//  FoundItemViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/26/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import "FoundItemViewController.h"
#import <Parse/Parse.h>

@interface FoundItemViewController ()

@property NSDictionary *selectedLocation;

@end

@implementation FoundItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)savePost{
    PFObject *post = [PFObject objectWithClassName:@"LostAndFound"];
    NSLog(@"%@", _selectedLocation);
    if (_selectedLocation != nil){
        PFGeoPoint *selectedGeopoint = [PFGeoPoint geoPointWithLocation:(CLLocation *)[_selectedLocation objectForKey:@"coordinate"]];
        [post setObject:selectedGeopoint forKey:@"location"];
    }
    [post setObject:_foundItem.text forKey:@"title"];
    [post setObject:[PFUser currentUser] forKey:@"user"];
    [post saveInBackground];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)whereButtonPressed:(id)sender {
    PostLocationViewController *postLocationViewController = [self.storyboard  instantiateViewControllerWithIdentifier:@"PostLocationViewController"];
    postLocationViewController.postLocationDelegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:postLocationViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
    
}

- (IBAction)postButtonPressed:(id)sender {
    [self savePost];
}

-(void)postLocationViewController:(PostLocationViewController *)controller didFinishSelecting:(NSDictionary *)location{
    
    _selectedLocation = location;
    NSLog(@"%@", location);
    
}

@end
