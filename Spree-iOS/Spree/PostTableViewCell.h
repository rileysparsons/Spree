//
//  PostTableViewCell.h
//  Spree
//
//  Created by Riley Steele Parsons on 12/19/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CEReactiveView.h"

@interface PostTableViewCell : UITableViewCell <CEReactiveView>

-(void)bindViewModel:(id)viewModel;

@end
