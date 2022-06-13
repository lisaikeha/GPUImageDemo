//
//  CS1.h
//  GPUImageDemo
//
//  Created by lisaike on 2022/6/8.
//  Copyright © 2022 JackerooChu. All rights reserved.
//

#import "GPUImageFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface CS1 : GPUImageFilter
{
    GLint gl_img_width;
    GLint gl_img_height;
    GLint gl_intensity;
    GLint gl_offset_x;
    GLint gl_type;
}

@property(readwrite, nonatomic) double startTime;
@property(readwrite, nonatomic) int type;
@property(readwrite, nonatomic) float intensity;
@property(readwrite, nonatomic) float offset_x;
@property(readwrite, nonatomic) float img_height;
@property(readwrite, nonatomic) float img_width;
@property(readwrite, nonatomic) double time_counter;
@property(readwrite, nonatomic) NSMutableArray *animations;

@end

NS_ASSUME_NONNULL_END
