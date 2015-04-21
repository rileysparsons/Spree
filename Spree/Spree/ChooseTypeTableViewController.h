//
//  ChooseTypeTableViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 12/15/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChooseTypeTableViewController;

@protocol ChooseTypeTableViewControllerDelegate <NSObject>

@optional

- (void)chooseTypeTableViewController:(ChooseTypeTableViewController *)controller didFinishSelecting:(NSString *)type;

@end


@interface ChooseTypeTableViewController : UITableViewController

@property NSArray *typeArray;
@property NSArray *imageArray;
@property NSString *typeFormerlySelected;
@property (nonatomic, weak) id <ChooseTypeTableViewControllerDelegate> delegate;
- (IBAction)cancelButton:(id)sender;

@end
