//
//  ChatViewController.h
//  Spree
//
//  Created by Riley Steele Parsons on 4/7/16.
//  Copyright © 2016 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SlackTextViewController/SLKTextViewController.h>
#import "ChatViewModel.h"

@interface ChatViewController : SLKTextViewController

@property ChatViewModel *chatViewModel;

@end
