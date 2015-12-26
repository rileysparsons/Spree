//
//  HeaderSlideView.m
//  
//
//  Created by Riley Steele Parsons on 7/31/15.
//
//

#import "HeaderSlideView.h"

@implementation HeaderSlideView

// Metadata keys

#define kSlideTitle @"title"
#define kSlideSubtitle @"subtitle"
#define kSlideTitleColor @"titleColor"
#define kSlideSubtitleColor @"subtitleColor"
#define kSlideBackgroundColor @"backgroundColor"
#define kQueryParameters @"parameters"
#define kLinkType @"linkType"
#define kOrderNumber @"number"


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 1. Load the .xib file .xib file must match classname
        NSString *className = NSStringFromClass([self class]);
        _customView = [[[NSBundle mainBundle] loadNibNamed:className owner:self options:nil] firstObject];
        
        // 2. Set the bounds if not set by programmer (i.e. init called)
        if(CGRectIsEmpty(frame)) {
            self.bounds = _customView.bounds;
        }
        
        // 3. Add as a subview
        
        [self addSubview:_customView];
        [self stretchToSuperView:self.customView];
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        
        // 1. Load .xib file
        NSString *className = NSStringFromClass([self class]);
        _customView = [[[NSBundle mainBundle] loadNibNamed:className owner:self options:nil] firstObject];
        
        // 2. Add as a subview
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_customView];
        [self stretchToSuperView:self.customView];
        
    }
    return self;
}


- (void) stretchToSuperView:(UIView*) view {
    
    view.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *bindings = NSDictionaryOfVariableBindings(view);
    NSString *formatTemplate = @"%@:|[view]|";
    for (NSString * axis in @[@"H",@"V"]) {
        NSString * format = [NSString stringWithFormat:formatTemplate,axis];
        NSArray * constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:bindings];
        [view.superview addConstraints:constraints];
    }
    [self layoutIfNeeded];
}

-(void)setTitleWithString:(NSString *)title{
    self.slideTitle.text = title;
}

-(void)setBackgroundImageWithImage:(UIImage *)image{
    self.backgroundImage.image = image;
}

-(void)setupForMetadata:(NSDictionary *)metadata{
    if (metadata[kSlideTitle]){
        self.slideTitle.text = metadata[kSlideTitle];
    }
    
    if (metadata[kSlideSubtitle]){
        self.slideSubtitle.text = metadata[kSlideSubtitle];
    }
    
    self.slideTitle.textColor = [UIColor spreeOffWhite];
    
    // Color Setup
    if (metadata[kSlideBackgroundColor]){
        NSString *hexValue = metadata[kSlideBackgroundColor];
        self.backgroundImage.backgroundColor = [self colorFromHexString:hexValue];
    } else {
        self.backgroundImage.backgroundColor = [UIColor spreeOffBlack];
    }
    
    if (metadata[kSlideTitleColor]){
        NSString* hexValue = metadata[kSlideTitleColor];
        self.slideTitle.textColor = [self colorFromHexString:hexValue];
    } else {
        self.slideTitle.textColor = [UIColor spreeOffWhite];
    }
    
    if (metadata[kSlideSubtitleColor]){
        NSString* hexValue = metadata[kSlideSubtitleColor];
        self.slideSubtitle.textColor = [self colorFromHexString:hexValue];
    } else {
        self.slideSubtitle.textColor = [[UIColor spreeOffWhite] colorWithAlphaComponent:0.70f];
    }
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}


@end
