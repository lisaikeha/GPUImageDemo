//
//  DemoViewController.m
//  GPUImageDemo
//
//  Created by lisaike on 2022/6/8.
//  Copyright © 2022 JackerooChu. All rights reserved.
//

#import "DemoViewController.h"
#import <GPUImageView.h>
#import <GPUImage/GPUImage.h>

@interface DemoViewController ()
@property (nonatomic, strong) GPUImageFilter *filter;
@property (nonatomic, strong) GPUImageFilter *filter2;
@property (nonatomic, strong) GPUImageView *imageView;

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIImage *inputImage = [UIImage imageNamed:@"lzl"];
    NSURL *videoUrl = [[NSBundle mainBundle] URLForResource:@"ebg"
                                         withExtension:@"mov"];
    self.video = [[GPUImageMovie alloc] initWithURL:videoUrl];
    self.video.playAtActualSpeed = YES;
    self.picture = [[GPUImagePicture alloc]initWithImage:inputImage];
//    self.filter = [[GPUImageGaussianBlurFilter alloc] init];
    self.filter = [[GPUImageAddBlendFilter alloc] init];
    [self.filter forceProcessingAtSize:inputImage.size];
//    [self.filter useNextFrameForImageCapture];
    self.imageView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    [self.picture addTarget:self.filter];
    [self.video addTarget:self.filter];
//    [stillImageSource addTarget:self.imageView];
//    [self.video addTarget:self.imageView];
    [self.filter addTarget:self.imageView];
    [self.picture processImage];
    [self.video startProcessing];
    [self.view addSubview:self.imageView];

    //    UIImage *newImage = [self.filter imageFromCurrentFramebuffer];
    //    UIImageView *v = [[UIImageView alloc] initWithFrame:self.view.bounds];
    //    v.image = newImage;
    //    [self.view addSubview:v];
}

@end
