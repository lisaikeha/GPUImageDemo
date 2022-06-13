//
//  AN.h
//  GPUImageDemo
//
//  Created by lisaike on 2022/6/8.
//  Copyright © 2022 JackerooChu. All rights reserved.
//

#import "GPUImageFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface AN : GPUImageFilter
{
    GLint gl_img_width;
    GLint gl_img_height;
    GLint gl_time;
    GLint gl_frame;
    GLint gl_intensity;
    GLint gl_strength;
    GLint gl_type;
    GLint gl_speed;
    GLint gl_vertical;
}

@property(readwrite, nonatomic) int type;
@property(readwrite, nonatomic) float intensity;
@property(readwrite, nonatomic) float strength;
@property(readwrite, nonatomic) float speed;
@property(readwrite, nonatomic) float img_height;
@property(readwrite, nonatomic) float img_width;
@property(readwrite, nonatomic) bool use_timer;
@property(readwrite, nonatomic) int i_rand;
@property(readwrite, nonatomic) double startTime;
@property(readwrite, nonatomic) double tempStartTime;
@property(readwrite, nonatomic) double time_counter;
@property(readwrite, nonatomic) float originalSpeed;
@property(readwrite, nonatomic) NSMutableArray *animations;
@property(readwrite, nonatomic) NSTimer *e_time;
@property(readwrite, nonatomic) int frame_counter;

@end

NS_ASSUME_NONNULL_END
