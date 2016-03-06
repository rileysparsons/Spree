//
//  PostCollectionViewCell.h
//  Spree
//
//  Created by Riley Steele Parsons on 3/6/16.
//  Copyright © 2016 Riley Steele Parsons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CEReactiveView.h"

@interface PostCollectionViewCell : UICollectionViewCell <CEReactiveView>

-(void)bindViewModel:(id)viewModel;

@end
