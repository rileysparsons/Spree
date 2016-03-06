//
//  PostCollectionViewController.h
//  
//
//  Created by Riley Steele Parsons on 3/6/16.
//
//

#import <UIKit/UIKit.h>
#import <CHTCollectionViewWaterfallLayout/CHTCollectionViewWaterfallLayout.h>
#import "PostTableViewModel.h"

@interface PostCollectionViewController : UICollectionViewController <CHTCollectionViewDelegateWaterfallLayout>

@property PostTableViewModel *viewModel;


@end
