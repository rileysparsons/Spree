//
//  ConfirmLocationViewController.h
//  
//
//  Created by Riley Steele Parsons on 12/26/15.
//
//

#import <UIKit/UIKit.h>
#import "PostingWorkflowViewModel.h"
#import "PreviewPostViewModel.h"

@interface ConfirmLocationViewController : UIViewController

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (strong, nonatomic) PreviewPostViewModel *viewModel;

@end
