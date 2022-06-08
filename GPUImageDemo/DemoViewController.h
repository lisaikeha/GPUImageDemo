//
//  DemoViewController.h
//  GPUImageDemo
//
//  Created by lisaike on 2022/6/8.
//  Copyright © 2022 JackerooChu. All rights reserved.
//

#import "ViewController.h"
#import <GPUImageView.h>
#import <GPUImage/GPUImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface DemoViewController : UIViewController
@property (nonatomic, strong) GPUImageMovie *video;
@property (nonatomic, strong) GPUImagePicture *picture;

@end

NS_ASSUME_NONNULL_END
