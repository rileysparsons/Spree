//
//  PostingInputAccessoryView.h
//  Spree
//
//  Created by Riley Steele Parsons on 8/17/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PostingInputAccessoryViewDelegate;

@interface PostingInputAccessoryView : UIView

@property (weak, nonatomic) IBOutlet UILabel *remainingCharacterLabel;
@property (nonatomic, strong) PostingInputAccessoryView *customView;

@end

@protocol PostingInputAccessoryViewDelegate <NSObject>

@end

