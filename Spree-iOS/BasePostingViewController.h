//
//  BasePostingViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 1/20/16.
//  Copyright © 2016 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostingWorkflowViewModel.h"

@interface BasePostingViewController : UIViewController

-(instancetype) initWithViewModel:(PostingWorkflowViewModel *)viewModel;

@end
