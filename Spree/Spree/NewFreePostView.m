//
//  NewFreePostView.m
//  Spree
//
//  Created by Riley Steele Parsons on 2/18/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "NewFreePostView.h"
#import "UIColor+SpreeColor.h"

@implementation NewFreePostView

-(void)awakeFromNib {
    [[NSBundle mainBundle] loadNibNamed:@"NewFreePostView" owner:self options:nil];
    
    // The following is to make sure content view, extends out all the way to fill whatever our view size is even as our view's size is changed by autolayout
    [self.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview: self.contentView];
    
    [[self class] addEdgeConstraint:NSLayoutAttributeLeft superview:self subview:self.contentView];
    [[self class] addEdgeConstraint:NSLayoutAttributeRight superview:self subview:self.contentView];
    [[self class] addEdgeConstraint:NSLayoutAttributeTop superview:self subview:self.contentView];
    [[self class] addEdgeConstraint:NSLayoutAttributeBottom superview:self subview:self.contentView];
    [self setupAppearance];
    
}

-(void)setupAppearance{
    
    UIView *leftViewPostTitle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, _titleField.frame.size.height)];
    _titleField.leftView = leftViewPostTitle;
    _titleField.leftViewMode = UITextFieldViewModeAlways;
    _titleField.layer.cornerRadius = _titleField.frame.size.height/2;
    _titleField.layer.masksToBounds=YES;
    _titleField.layer.borderColor=[[UIColor spreeDarkBlue]CGColor];
    _titleField.layer.borderWidth= 1.0f;
    
    _descriptionField.layer.cornerRadius = 15.0;
    _descriptionField.layer.masksToBounds=YES;
    _descriptionField.layer.borderColor=[[UIColor spreeDarkBlue]CGColor];
    _descriptionField.layer.borderWidth= 1.0f;
    
    _contentView.layer.cornerRadius = 15.0;
    _contentView.layer.masksToBounds=YES;
    _contentView.layer.borderColor=[[UIColor clearColor]CGColor];
    _contentView.layer.borderWidth= 1.0f;
    _cameraLocationView.layer.cornerRadius = 15.0;
    _cameraLocationView.layer.masksToBounds=YES;
    _cameraLocationView.layer.borderColor=[[UIColor spreeDarkBlue]CGColor];
    _cameraLocationView.layer.borderWidth= 1.0f;

}

+(void)addEdgeConstraint:(NSLayoutAttribute)edge superview:(UIView *)superview subview:(UIView *)subview {
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:subview
                                                          attribute:edge
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:superview
                                                          attribute:edge
                                                         multiplier:1
                                                           constant:0]];
}

@end
