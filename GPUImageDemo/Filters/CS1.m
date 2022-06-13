//
//  CS1.m
//  GPUImageDemo
//
//  Created by lisaike on 2022/6/8.
//  Copyright © 2022 JackerooChu. All rights reserved.
//

#import "CS1.h"
NSString *const kGPUImageCS1FragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate; uniform sampler2D inputImageTexture; precision highp float; uniform highp float img_width; uniform highp float img_height; uniform highp float intensity; uniform highp float offset_x; uniform highp int cs_type; vec2 img_size = vec2(img_width,img_height); vec2 frag_pos = vec2(textureCoordinate.x*img_size.x, textureCoordinate.y*img_size.y); vec2 uv = frag_pos.xy / img_size.xy; void main (void) { vec3 c = texture2D(inputImageTexture, textureCoordinate).xyz; vec2 p = frag_pos.xy / img_size.xy; vec3 chroma = c; if (cs_type == 0) { float offset = offset_x*1.0 + 0.99; float c1 = 1.015; float c2 = 1.03; vec3 refractiveIndex = vec3(1.0, c1 * offset, c2 * offset); vec2 normalizedTexCoord = vec2(2.0, 2.0) * uv - vec2(1.0, 1.0); vec3 texVec = vec3(normalizedTexCoord, 1.0); vec3 normalVec = vec3(0.0, 0.0, -1.0); vec3 redRefractionVec = refract(texVec, normalVec, refractiveIndex.r); vec3 greenRefractionVec = refract(texVec, normalVec, refractiveIndex.g); vec3 blueRefractionVec = refract(texVec, normalVec, refractiveIndex.b); vec2 redTexCoord = ((redRefractionVec / redRefractionVec.z).xy + vec2(1.0, 1.0)) / vec2(2.0, 2.0); vec2 greenTexCoord = ((greenRefractionVec / greenRefractionVec.z).xy + vec2(1.0, 1.0)) / vec2(2.0, 2.0); vec2 blueTexCoord = ((blueRefractionVec / blueRefractionVec.z).xy + vec2(1.0, 1.0)) / vec2(2.0, 2.0); chroma = vec3(texture2D(inputImageTexture, redTexCoord).r, texture2D(inputImageTexture, greenTexCoord).g, texture2D(inputImageTexture, blueTexCoord).b); c = chroma; } else if (cs_type == 1) { vec2 offset = vec2(offset_x*0.85*0.6,.0); chroma.r = texture2D(inputImageTexture, p+offset.xy).r; chroma.g = texture2D(inputImageTexture, p ).g; chroma.b = texture2D(inputImageTexture, p+offset.yx).b; } else if (cs_type == 2) { float ChromaticAberration = (offset_x*800.0) + 8.0; vec2 texel = 1.0 / img_size.xy; vec2 coords = (uv - 0.5) * 2.0; float coordDot = dot (coords, coords); vec2 precompute = ChromaticAberration * coordDot * coords; vec2 uvR = uv - texel.xy * precompute; vec2 uvB = uv + texel.xy * precompute; chroma.r = texture2D(inputImageTexture, uvR).r; chroma.g = texture2D(inputImageTexture, uv).g; chroma.b = texture2D(inputImageTexture, uvB).b; } else if (cs_type == 3) { chroma = vec3( texture2D(inputImageTexture,textureCoordinate-offset_x*0.8*0.6).x, texture2D(inputImageTexture,textureCoordinate ).y, texture2D(inputImageTexture,textureCoordinate+offset_x*0.8*0.6).z); } else if (cs_type == 4) { float intensity2 = offset_x * 180.0; intensity2 = pow((intensity2*0.22),3.0)*4.0; vec2 rOffset = vec2(-0.02,0)*intensity2; vec2 gOffset = vec2(0.0,0)*intensity2; vec2 bOffset = vec2(0.04,0)*intensity2; vec4 rValue = texture2D(inputImageTexture, uv - rOffset); vec4 gValue = texture2D(inputImageTexture, uv - gOffset); vec4 bValue = texture2D(inputImageTexture, uv - bOffset); chroma = vec3(rValue.r, gValue.g, bValue.b); } else if (cs_type == 5) { chroma.r = texture2D(inputImageTexture, vec2(p.x,p.y + 2.5 * offset_x/4.0)).r; chroma.g = texture2D(inputImageTexture, vec2(p.x,p.y + offset_x/4.0)).g; chroma.b = texture2D(inputImageTexture, vec2(p.x,p.y + 2.4 * offset_x/4.0)).b; } gl_FragColor = vec4(mix(c,chroma,intensity),1.0); }
);

@implementation CS1

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageCS1FragmentShaderString]))
    {
        return nil;
    }
    gl_img_width = [filterProgram uniformIndex:@"img_width"];
    gl_img_height = [filterProgram uniformIndex:@"img_height"];
    gl_intensity = [filterProgram uniformIndex:@"intensity"];
    gl_offset_x = [filterProgram uniformIndex:@"offset_x"];
    gl_type = [filterProgram uniformIndex:@"cs_type"];
    self.intensity = 1;
    self.type = 4;
    self.offset_x = 0.012;
    self.animations = [NSMutableArray array];
    self.startTime = [NSDate timeIntervalSinceReferenceDate];
    return self;
}

- (void)setType:(int)newValue;
{
    _type = newValue;
    [self setInteger:_type forUniform:gl_type program:filterProgram];
}

- (void)setIntensity:(float)newValue {
    _intensity = newValue;
    [self setFloat:_intensity forUniform:gl_intensity program:filterProgram];
}

- (void)setOffset_x:(float)offset_x {
    _offset_x = offset_x;
    [self setFloat:_offset_x forUniform:gl_offset_x program:filterProgram];
}

- (void)setImg_width:(float)img_width {
    _img_width = img_width;
    [self setFloat:_img_width forUniform:gl_img_width program:filterProgram];
}

- (void)setImg_height:(float)img_height {
    _img_height = img_height;
    [self setFloat:_img_height forUniform:gl_img_height program:filterProgram];
}

#pragma override

- (void)setupFilterForSize:(CGSize)filterFrameSize {
    self.img_width = filterFrameSize.width;
    self.img_height = filterFrameSize.height;
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates {
    self.time_counter = [NSDate timeIntervalSinceReferenceDate] - self.startTime;
    float global_speed = 1.0;
    float scale = fmax(global_speed, 0.02);
    self.time_counter *= scale;
    if(self.animations && [self.animations count]) {
        // todo
    }
end:
    [super renderToTextureWithVertices:vertices textureCoordinates:textureCoordinates];
}

@end
