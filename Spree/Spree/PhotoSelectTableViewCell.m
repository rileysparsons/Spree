//
//  PhotoSelectTableViewCell.m
//  Spree
//
//  Created by Riley Steele Parsons on 7/12/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "PhotoSelectTableViewCell.h"
#import <AVFoundation/AVFoundation.h>

@interface PhotoSelectTableViewCell ()

@property AVCaptureSession *liveFeedSession;

@end

@implementation PhotoSelectTableViewCell


- (void)awakeFromNib {
    // Initialization code
    [self emptyCellMode];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)initWithImage:(UIImage *)image{
    
    if (image){
        [self filledCellMode];
        float aspect = image.size.width/image.size.height;
        float height = (self.frame.size.width-16)*(1/aspect);
        self.heightLayoutConstraint.constant = height;
        self.cellImageView.image = image;
    } else {
        [self emptyCellMode];
    }
}

-(void)filledCellMode{
    [self.liveFeedSession stopRunning];
    self.cellImageView.hidden = NO;
    self.deleteButton.hidden = NO;
    self.pickPhotoButton.hidden = YES;
    self.takePhotoButton.hidden = YES;
}

-(void)emptyCellMode{
    if (self.liveFeedSession)
        [self.liveFeedSession startRunning];
    else
        [self setupLiveCamera];
    self.deleteButton.hidden = YES;
    self.cellImageView.hidden = YES;
    self.pickPhotoButton.hidden = NO;
    self.takePhotoButton.hidden = NO;
}

-(void)setupLiveCamera{
    self.liveFeedSession = [[AVCaptureSession alloc] init];
    self.liveFeedSession.sessionPreset = AVCaptureSessionPresetLow;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    [self.liveFeedSession addInput:input];
    
    AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.liveFeedSession];
    newCaptureVideoPreviewLayer.frame = self.takePhotoButton.bounds;
    newCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.takePhotoButton.layer addSublayer:newCaptureVideoPreviewLayer];
    [self.liveFeedSession startRunning];
    CALayer *overlay = [CALayer layer];
    overlay.frame = self.takePhotoButton.bounds;
    overlay.backgroundColor = [[UIColor spreeDarkBlue] CGColor];
    overlay.opacity = 0.55f;
    [self.takePhotoButton.layer addSublayer:overlay];
    
}



@end
