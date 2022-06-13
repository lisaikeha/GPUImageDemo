//
//  AN.m
//  GPUImageDemo
//
//  Created by lisaike on 2022/6/8.
//  Copyright © 2022 JackerooChu. All rights reserved.
//

#import "AN.h"

NSString *const kGPUImageANFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate; uniform sampler2D inputImageTexture; precision highp float; uniform highp float img_width; uniform highp float img_height; uniform highp float iTime; uniform highp int iFrame; uniform highp float intensity; uniform highp float strength; uniform highp float speed; uniform highp int i_type; uniform highp int colored; uniform highp int vertical; vec2 img_size = vec2(img_width,img_height); vec2 frag_pos = vec2(textureCoordinate.x*img_size.x, textureCoordinate.y*img_size.y); vec2 uv = frag_pos.xy / img_size.xy; float time_var = iTime*speed; vec3 draw(vec2 uv) { return vec3(texture2D(inputImageTexture,vec2(uv.x,uv.y)).rgb); } float terrain(float x) { float v = 0.; x *= 1.*(0.4 + strength*30.); const float l = 13.; for (float n = 0.; n < l; n++) { v += ((sin((x*sin(n/2.142))+(n/1.41)))/l)*(2. + 1.*intensity); } return pow(v,2.); } float rand(vec2 co) { float a = 12.9898; float b = 78.233; float c = 43758.5453; float dt= dot(co.xy ,vec2(a,b)); float sn= mod(dt,3.14); return fract(sin(sn) * c); } vec2 VHSRES = img_size; float v2random(vec2 p) { p = mod( p, vec2( 1.0 )); vec3 p3 = fract(vec3(p.xyx) * 2.5031); p3 += dot(p3, p3.yzx + 19.19); return fract((p3.x + p3.y) * p3.z); } mat2 rotate2D( float t ) { return mat2( cos( t ), sin( t ), -sin( t ), cos( t ) ); } vec3 rgb2yiq( vec3 rgb ) { return mat3( 0.299, 0.596, 0.211, 0.587, -0.274, -0.523, 0.114, -0.322, 0.312 ) * rgb; } vec3 yiq2rgb( vec3 yiq ) { return mat3( 1.000, 1.000, 1.000, 0.956, -0.272, -1.106, 0.621, -0.647, 1.703 ) * yiq; } int SAMPLES = 8 * int(1.0 + strength*20.0); vec3 vhsTex2D( vec2 uv, float rot ) { if ( (abs(uv.x-0.5)<0.5&&abs(uv.y-0.5)<0.5) ) { vec3 yiq = vec3( 0.0 ); for ( int i = 0; i < SAMPLES; i ++ ) { yiq += ( rgb2yiq( texture2D( inputImageTexture, uv - vec2( float( i ), 0.0 ) / VHSRES ).xyz ) * vec2( float( i ), float( SAMPLES - 1 - i ) ).yxx / float( SAMPLES - 1 ) ) / float( SAMPLES ) * 2.0; } if ( rot != 0.0 ) { yiq.yz = rotate2D( rot ) * yiq.yz; } return yiq2rgb( yiq ); } return vec3( 0.1, 0.1, 0.1 ); } float offset(float blocks, vec2 uv) { if (vertical == 0) return rand(vec2(floor(time_var*40.0), floor(uv.y * blocks))); else return rand(vec2(floor(time_var*40.0), floor(uv.x * blocks))); } float hash(vec2 p) { float h = dot(p,vec2(127.1,311.7)); return -1.0 + 2.0*fract(sin(h)*43758.5453123); } float noise(vec2 p) { vec2 i = floor(p); vec2 f = fract(p); vec2 u = f*f*(3.0-2.0*f); return mix(mix(hash( i + vec2(0.0,0.0) ), hash( i + vec2(1.0,0.0) ), u.x), mix( hash( i + vec2(0.0,1.0) ), hash( i + vec2(1.0,1.0) ), u.x), u.y); } float noise(vec2 p, int oct) { mat2 m = mat2( 1.6, 1.2, -1.2, 1.6 ); float f = 0.0; for(int i = 1; i < 3; i++){ float mul = 1.0/pow(2.0, float(i)); f += mul*noise(p); p = m*p; } return f; } vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; } vec2 mod289(vec2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; } vec3 permute(vec3 x) { return mod289(((x*34.0)+1.0)*x); } float snoise(vec2 v) { const vec4 C = vec4(0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439); vec2 i = floor(v + dot(v, C.yy) ); vec2 x0 = v - i + dot(i, C.xx); vec2 i1; i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0); vec4 x12 = x0.xyxy + C.xxzz; x12.xy -= i1; i = mod289(i); vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 )) + i.x + vec3(0.0, i1.x, 1.0 )); vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0); m = m*m ; m = m*m ; vec3 x = 2.0 * fract(p * C.www) - 1.0; vec3 h = abs(x) - 0.5; vec3 ox = floor(x + 0.5); vec3 a0 = x - ox; m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h ); vec3 g; g.x = a0.x * x0.x + h.x * x0.y; g.yz = a0.yz * x12.xz + h.yz * x12.yw; return 130.0 * dot(m, g); } float rand2(vec2 co) { return fract(sin(dot(co.xy,vec2(12.9898,78.233))) * 43758.5453); } float rand2(float n) { return fract(sin(n) * 43758.5453123); } float noise2(float p) { float fl = floor(p); float fc = fract(p); return mix(rand2(fl), rand2(fl + 1.0), fc); } float map(float val, float amin, float amax, float bmin, float bmax) { float n = (val - amin) / (amax-amin); float m = bmin + n * (bmax-bmin); return m; } float snoise(float p){ return map(noise2(p),0.0,1.0,-1.0,1.0); } float threshold(float val,float cut){ float v = clamp(abs(val)-cut,0.0,1.0); v = sign(val) * v; float scale = 1.0 / (1.0 - cut); return v * scale; } vec3 ghost2(vec2 uv){ float n1 = threshold(snoise(iTime*(2.0 + speed*8.0)),.85); float n2 = threshold(snoise(2000.0+iTime*(2.0 + speed*8.0)),.85); float n3 = threshold(snoise(3000.0+iTime*(2.0 + speed*8.0)),.85); vec2 or = vec2(0.,0.); vec2 og = vec2(0,0.); vec2 ob = vec2(0.,0); float os = .02 + intensity*0.02; or += vec2(n1*os,0.); og += vec2(n2*os,0.); ob += vec2(0.,n3*os); float r = texture2D(inputImageTexture,uv + or).r; float g = texture2D(inputImageTexture,uv + og).g; float b = texture2D(inputImageTexture,uv + ob).b; vec3 color = vec3(r,g,b); return color; } void main (void) { vec3 c = texture2D(inputImageTexture, textureCoordinate).xyz; vec2 uv = frag_pos.xy / img_size.xy; if (i_type == 0) { time_var *= 0.5; float time = time_var; float uv_axis = uv.y; if (vertical == 1) { uv_axis = uv.x; } vec3 dist_texture = vec3(draw(uv+(terrain((uv_axis*20.)+(time*30.))/(200.+200.*(1.0 - intensity)) )).r,draw(uv+(terrain((uv_axis*(20. + intensity*3.0))+(time*30.))/(201.+201.*(1.0 - intensity)))).g,draw(uv+(terrain((uv_axis*(20. - intensity*3.0))+(time*30.))/(202.+202.*(1.0 - intensity)))).b); gl_FragColor = vec4(dist_texture,1.0); } else if (i_type == 1) { vec2 r = vec2(offset(1000.0, uv) * (0.002 + strength/40.0) * (1.0 + intensity*2.0), 0.0); vec2 g = vec2(offset(1000.0, uv) * (0.01 + strength/40.0) * 0.16666666 * (1.0 + intensity*2.0), 0.0); vec2 b = vec2(offset(1000.0, uv) * (0.0015 + strength/40.0) * (1.0 + intensity*2.0), 0.0); if (vertical == 1) { r = vec2(r.y,r.x); g = vec2(g.y,g.x); b = vec2(b.y,b.x); } gl_FragColor.r = texture2D(inputImageTexture, uv + r).r; gl_FragColor.g = texture2D(inputImageTexture, uv + g).g; gl_FragColor.b = texture2D(inputImageTexture, uv + b).b; } else if (i_type == 2) { uv = frag_pos.xy / VHSRES; float time = iTime; vec2 uvn = uv; vec3 col = vec3( 0.0, 0.0, 0.0 ); if (vertical == 0) uvn.x += (( v2random( vec2( uvn.y / 10.0, time / 10.0 ) / 1.0 ) - 0.5 ) / VHSRES.x * 1.0); else uvn.y += (( v2random( vec2( uvn.y / 10.0, time / 10.0 ) / 1.0 ) - 0.5 ) / VHSRES.x * 1.0); float phase = uvn.y; if (vertical == 1) phase = uvn.x; float tcPhase = smoothstep( 0.9, 0.96, sin( phase * 8.0 - ( time + 0.14 * v2random( time * vec2( 0.67, 0.59 ) ) ) * 3.14159265 * 1.2 ) ); float tcNoise = smoothstep( 0.3, 1.0, v2random( vec2( phase * 4.77, time ) ) ); float tc = tcPhase * tcNoise; float snPhase = smoothstep( 10.0 / VHSRES.y, 0.0, uvn.y ); if (vertical == 1) snPhase = smoothstep( 10.0 / VHSRES.x, 0.0, uvn.x ); uvn.y += snPhase * 0.2; col = vhsTex2D( uvn, tcPhase * 0.15 + snPhase * 2.0 ); vec2 V = vec2(0.,1.); float cn = tcNoise * ( 1.2 + 0.7 * tcPhase ); if ( 0.29 < cn ) { vec2 uvt = ( uvn + V.yx * v2random( vec2( uvn.y, time ) ) ) * vec2( 0.1, 1.0 ); float n0 = v2random( uvt ); float n1 = v2random( uvt + V.yx / VHSRES.x ); if ( n1 < n0 ) { col = mix( col, 2.0 * V.yyy, pow( n0, 2.0 )*0.02 * (1.0 + intensity*4.0) ); } } col *= 1.0 + 0.012 * smoothstep( 0.4, 0.6, v2random( vec2( 0.0, 0.1 * ( uv.y + time * 0.4 ) ) / 10.0 ) ); gl_FragColor = vec4( col, 1.0 ); } else if (i_type == 4) { vec2 uv = textureCoordinate; time_var = iTime * (0.2 + speed*3.0); float glitch = pow(cos(time_var*2.5)+1.2, 1.2); float s1 = 0.5 + strength*4.0 ; vec2 hp = vec2(0.0, uv.y * s1 ) ; if (vertical == 1) hp = vec2(uv.x * s1, 0.0); float nh = noise(hp*7.0+time_var*3.0, 3) * (noise(hp+time_var*0.3)*0.8); nh += noise(hp*100.0+time_var*3.0, 3)*(0.01 + intensity/4.0); float rnd = 0.0; if(glitch > 0.0){ rnd = hash(vec2(time_var)); if(glitch < 1.0) { rnd *= glitch; } } nh *= glitch; nh *= 0.2 + intensity*0.6; vec2 r_v = vec2(nh, 0.08*hash(vec2(time_var*0.1578132)))*nh*sin(time_var*2.0); vec2 g_v = vec2(nh-0.07, 0.04*hash(vec2(time_var*0.57812)))*nh*sin(time_var*2.0); vec2 b_v = vec2(nh, 0.04*hash(vec2(time_var*0.1573812)))*nh*sin(time_var*2.0); if (vertical == 1) { r_v = vec2(r_v.y,r_v.x); g_v = vec2(g_v.y,g_v.x); b_v = vec2(b_v.y,b_v.x); } float r = texture2D(inputImageTexture, uv+r_v).r; float g = texture2D(inputImageTexture, uv+g_v).g; float b = texture2D(inputImageTexture, uv+b_v).b; vec3 col = vec3(r, g, b); gl_FragColor = vec4(col.rgb, 1.0); } else if (i_type == 5) { uv = gl_FragCoord.xy / img_size.xy; float time = iTime * (0.2 + 2.5*speed); float noise = max(0.0, snoise(vec2(time*0.4, uv.y * 1.0)) - 0.3) * (1.0 / 0.7); noise = noise + (snoise(vec2(time*10.0, uv.y * (4.4 + 20.4*strength) )) - 0.5) * 0.15; float xpos = noise * (0.05 + 0.3*intensity); vec2 r_v = vec2(xpos, 0.0)*(sin(time*0.4))*sin(time*2.0); vec2 g_v = vec2(xpos, 0.0)*(cos(time*0.8))*sin(time*2.0); vec2 b_v = vec2(xpos, 0.0)*(sin(time*1.6))*sin(time*2.0); float r = texture2D(inputImageTexture, uv+r_v).r; float g = texture2D(inputImageTexture, uv+g_v).g; float b = texture2D(inputImageTexture, uv+b_v).b; vec3 col = vec3(r, g, b); gl_FragColor = vec4(col.rgb, 1.0); } }
);

@implementation AN

#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageANFragmentShaderString]))
    {
        return nil;
    }
    gl_img_width = [filterProgram uniformIndex:@"img_width"];
    gl_img_height = [filterProgram uniformIndex:@"img_height"];
    gl_time = [filterProgram uniformIndex:@"iTime"];
    gl_frame = [filterProgram uniformIndex:@"iFrame"];
    gl_intensity = [filterProgram uniformIndex:@"intensity"];
    gl_strength = [filterProgram uniformIndex:@"strength"];
    gl_type = [filterProgram uniformIndex:@"i_type"];
    gl_speed = [filterProgram uniformIndex:@"speed"];
    gl_vertical = [filterProgram uniformIndex:@"vertical"];
    self.type = 0;
    self.intensity = 1;
    self.strength = 0.1;
    self.speed = 0.02;
    self.originalSpeed = 0.02;
    self.animations = [NSMutableArray array];
//    int vertical = 0; // media type 2
    int vertical = 0;   //media type 1 
    [self setInteger:vertical forUniform:gl_vertical program:filterProgram];
    self.use_timer = true;
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setType:(int)newValue;
{
    _type = newValue;
    [self setInteger:_type forUniform:gl_type program:filterProgram];
}

- (void)setIntensity:(float)newValue {
    _intensity = newValue;
    [self setFloat:_intensity forUniform:gl_intensity program:filterProgram];
}

- (void)setStrength:(float)newValue {
    _strength = newValue;
    [self setFloat:_strength forUniform:gl_strength program:filterProgram];
}

- (void)setSpeed:(float)newValue {
    _speed = newValue;
    float param = (0.22 - _speed) * 5.0;
    [self setFloat:param forUniform:gl_speed program:filterProgram];
}

- (void)setUse_timer:(bool)use_timer {
    _use_timer = use_timer;
    if(use_timer) {
        self.i_rand = arc4random_uniform(100);
        self.startTime = [NSDate timeIntervalSinceReferenceDate];
        self.tempStartTime = [NSDate timeIntervalSinceReferenceDate];
    }
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
    bool shouldAnimate = true;
    self.time_counter = [NSDate timeIntervalSinceReferenceDate] - self.startTime;
    float global_speed = 1.0;
    if(self.type == 2) {
        // todo
        double tmp = [NSDate timeIntervalSinceReferenceDate];
        if( (tmp - self.tempStartTime) < self.originalSpeed/ global_speed) {
            goto end;
        }
        self.tempStartTime = [NSDate timeIntervalSinceReferenceDate];
    }
    else {
        if(!shouldAnimate) {
            goto end;
        }
        float scale = fmax(global_speed, 0.02);
        self.time_counter *= scale;
    }
    self.time_counter += self.i_rand;
    [self setFloat:self.time_counter forUniform:gl_time program:filterProgram];
    if(self.animations && [self.animations count]) {
        // todo
    }

end:
    [super renderToTextureWithVertices:vertices textureCoordinates:textureCoordinates];
}

@end
