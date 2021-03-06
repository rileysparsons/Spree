//
//  SpreeViewModelServicesImpl.h
//  Spree
//
//  Created by Riley Steele Parsons on 12/12/15.
//  Copyright © 2015 Riley Steele Parsons. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpreeViewModelServices.h"


@interface SpreeViewModelServicesImpl : NSObject <SpreeViewModelServices>

-(instancetype)init;
-(instancetype)initWithNavigationController:(UINavigationController *)navigationController;

@end
