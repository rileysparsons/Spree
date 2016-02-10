//
//  ConfirmLocationViewController.h
//  
//
//  Created by Riley Steele Parsons on 12/26/15.
//
//

#import <UIKit/UIKit.h>
#import "PostingWorkflowViewModel.h"

@interface ConfirmLocationViewController : UIViewController

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (strong, nonatomic) PostingWorkflowViewModel *postingWorkflow;

@end
