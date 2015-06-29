//
//  UIColor+SpreeColor.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/23/14.
//  Copyright (c) 2014 Riley Steele Parsons. All rights reserved.
//

#import "UIColor+SpreeColor.h"

@implementation UIColor (SpreeColor)

+(UIColor *)spreeRed{
    return [UIColor colorWithRed:0.969 green:0.188 blue:0.169 alpha:1];
}
+(UIColor *)spreeLightYellow{
    return [UIColor colorWithRed:0.855 green:0.863 blue:0.137 alpha:1];
}
+(UIColor *)spreeDarkBlue{
    return [UIColor colorWithRed:0 green:0.376 blue:0.655 alpha:1];
}
+(UIColor *)spreeBabyBlue{
    return [UIColor colorWithRed:0.071 green:0.576 blue:0.957 alpha:1];
}
+(UIColor *)spreeDarkYellow{
    return [UIColor colorWithRed:0.749 green:0.757 blue:0 alpha:1];
}
+(UIColor *)spreeOffBlack{
    return [UIColor colorWithRed:0.22 green:0.243 blue:0.259 alpha:1]; /*#383e42*/
}
+(UIColor *)spreeOffWhite{
    return [UIColor colorWithRed:0.973 green:0.976 blue:0.976 alpha:1]; /*#f8f9f9*/
}


@end
