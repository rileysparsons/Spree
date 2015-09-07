//
//  PhotoSelectFooterView.m
//  Spree
//
//  Created by Riley Steele Parsons on 7/17/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "PhotoSelectFooterView.h"
#import <AVFoundation/AVFoundation.h>

@interface PhotoSelectFooterView ()

@property AVCaptureSession *liveFeedSession;

@end

@implementation PhotoSelectFooterView


-(void)setupLiveCameraForFrame:(CGRect)frame{
    self.liveFeedSession = [[AVCaptureSession alloc] init];
    self.liveFeedSession.sessionPreset = AVCaptureSessionPresetLow;
    NSError *error = nil;
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *device in videoDevices) {
        if (device.position == AVCaptureDevicePositionBack) {
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
            [self.liveFeedSession addInput:input];
        }
    }
    
    AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.liveFeedSession];
    newCaptureVideoPreviewLayer.frame = frame;
    newCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.takePhotoButton.layer addSublayer:newCaptureVideoPreviewLayer];
    [self.liveFeedSession startRunning];
    CALayer *overlay = [CALayer layer];
    [overlay setBounds:frame];
    overlay.backgroundColor = [[UIColor spreeDarkBlue] CGColor];
    overlay.opacity = 0.55f;
    overlay.masksToBounds = YES;
    [self.takePhotoButton.layer addSublayer:overlay];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
