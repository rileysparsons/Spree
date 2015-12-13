//
//  SpreeViewModelServices.h
//  Spree
//
//  Created by Riley Steele Parsons on 12/12/15.
//  Copyright © 2015 Riley Steele Parsons. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpreeParseConnection.h"

@protocol SpreeViewModelServices <NSObject>

-(id<SpreeParseConnection>)getParseConnection;

@end
