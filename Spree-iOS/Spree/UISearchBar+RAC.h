//
//  UISearchBar+RAC.h
//  ReactiveCocoaExample
//
//  Created by Justin DeWind on 1/26/14.
//  Copyright (c) 2014 Justin DeWind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface UISearchBar (RAC)
- (RACSignal *)rac_textSignal;
- (RACSignal *)rac_searchButtonClickedSignal;
@end
