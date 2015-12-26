//
//  UISearchDisplayController+RAC.m
//  ReactiveCocoaExample
//
//  Created by Justin DeWind on 1/26/14.
//  Copyright (c) 2014 Justin DeWind. All rights reserved.
//

#import "UISearchController+RAC.h"
#import <objc/objc-runtime.h>

@interface UISearchController()<UISearchControllerDelegate>

@end

@implementation UISearchController (RAC)
- (RACSignal *)rac_isActiveSignal {
    self.delegate = self;
    RACSignal *signal = objc_getAssociatedObject(self, _cmd);
    if (signal != nil) return signal;
    
    RACSignal *willPresentSearchController = [[self rac_signalForSelector:@selector(willPresentSearchController:) fromProtocol:@protocol(UISearchControllerDelegate)] mapReplace:@YES];
    RACSignal *didPresentSearchController = [[self rac_signalForSelector:@selector(didPresentSearchController:) fromProtocol:@protocol(UISearchControllerDelegate)] mapReplace:@NO];
    
    signal = [RACSignal merge:@[didPresentSearchController, willPresentSearchController]];
    objc_setAssociatedObject(self, _cmd, signal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return signal;
}

-(RACSignal *)rac_isInactiveSignal{
    self.delegate = self;
    RACSignal *signal = objc_getAssociatedObject(self, _cmd);
    
    if (signal != nil) return signal;
    RACSignal *willDismissSearchController = [[self rac_signalForSelector:@selector(willDismissSearchController:) fromProtocol:@protocol(UISearchControllerDelegate)] mapReplace:@NO];
    RACSignal *didDismissSearchController = [[self rac_signalForSelector:@selector(didDismissSearchController:) fromProtocol:@protocol(UISearchControllerDelegate)] mapReplace:@NO];
    
    signal = [RACSignal merge:@[didDismissSearchController, willDismissSearchController]];
    objc_setAssociatedObject(self, _cmd, signal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return signal;
}

@end
