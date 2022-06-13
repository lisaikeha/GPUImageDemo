//
//  DN.m
//  GPUImageDemo
//
//  Created by lisaike on 2022/6/8.
//  Copyright © 2022 JackerooChu. All rights reserved.
//

#import "DN.h"
NSString *const kGPUImageDNFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate; uniform sampler2D inputImageTexture; varying highp vec2 textureCoordinate2; uniform sampler2D inputImageTexture2; precision highp float; uniform highp float img_width; uniform highp float img_height; uniform highp float iTime; uniform highp float intensity; uniform highp float speed; uniform highp int i_type; uniform highp int vertical; uniform highp int channel_r; uniform highp int channel_g; uniform highp int channel_b; vec2 img_size = vec2(img_width,img_height); vec2 frag_pos = vec2(textureCoordinate.x*img_size.x, textureCoordinate.y*img_size.y); vec2 uv = frag_pos.xy / img_size.xy; float time = iTime; float rand(float n){return fract(sin(n) * 43758.5453123);} float rand3 () { return fract(sin(floor(iTime*(32.0)))*1e4); } float noise(float p){ float fl = floor(p); float fc = fract(p); return mix(rand(fl), rand(fl + 1.0), fc); } vec2 hash(vec2 p) { vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973)); p3 += dot(p3, p3.yzx+19.19); return fract((p3.xx+p3.yz)*p3.zy); } float hash11(float p) { vec3 p3 = fract(vec3(p) * .1031); p3 += dot(p3, p3.yzx + 19.19); return fract((p3.x + p3.y) * p3.z); } float noise2( in vec2 p ) { p *= 8.0; const float K1 = 0.366025404; const float K2 = 0.211324865; vec2 i = floor( p + (p.x+p.y)*K1 ); vec2 a = p - i + (i.x+i.y)*K2; vec2 o = step(a.yx,a.xy); vec2 b = a - o + K2; vec2 c = a - 1.0 + 2.0*K2; vec3 h = max( 0.5-vec3(dot(a,a), dot(b,b), dot(c,c) ), 0.0 ); vec3 n = h*h*h*h*vec3( dot(a,hash(i+0.0)), dot(b,hash(i+o)), dot(c,hash(i+1.0))); return dot( n, vec3(70.0) ); } float blockyNoise(vec2 uv, float threshold, float scale, float seed) { float time2 = time * 2.5; float scroll = floor(time2 + sin(11.0 * time2) + sin(time2) ) * 0.77; vec2 noiseUV = uv.yy / scale + scroll; float noise2 = noise2( noiseUV); float id = floor( noise2 * 20.0); id = noise(id + seed) - 0.5; if ( abs(id) > threshold ) id = 0.0; return id; } float blockyNoise2(vec2 uv, float scale, float seed) { float time = iTime; float scroll = (time + sin(11.0 * time) + sin(time) ) * 0.77; vec2 noiseUV = uv.yy / scale + scroll; float noise2 = noise2( noiseUV + hash(vec2(floor(iTime*5.0)))*0.2); float id = floor( noise2 * 15.71); id = noise(id + seed) ; if ( abs(id) > 0.8 ) id = 0.0; return id; } float scale = 0.03; float b_threshold = 0.4; float l_threshold = 0.5; float rgb_offset = 5.0 + 15.0* intensity; float bias = 0.3 + 0.5 * intensity; float opacity = 1.0; vec3 difference( vec3 s, vec3 d ) { return abs(d - s); } float rand2(vec2 co) { return fract(sin(dot(co.xy,vec2(12.9898,78.233))) * 43758.5453); } vec3 rand1(vec2 uv) { vec2 c = ((.01)*img_size .x)*vec2(1.,(img_size .y/img_size .x)); vec3 col = vec3(0.0); float r = rand2(vec2((2.) * floor(uv.x*c.x)/c.x, (2.) * floor(uv.y*c.y)/c.y )); float g = rand2(vec2((5.) * floor(uv.x*c.x)/c.x, (5.) * floor(uv.y*c.y)/c.y )); float b = rand2(vec2((9.) * floor(uv.x*c.x)/c.x, (9.) * floor(uv.y*c.y)/c.y )); col = vec3(r,g,b); return col; } vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; } vec2 mod289(vec2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; } vec3 permute(vec3 x) { return mod289(((x*34.0)+1.0)*x); } float snoise(vec2 v) { const vec4 C = vec4(0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439); vec2 i = floor(v + dot(v, C.yy) ); vec2 x0 = v - i + dot(i, C.xx); vec2 i1; i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0); vec4 x12 = x0.xyxy + C.xxzz; x12.xy -= i1; i = mod289(i); vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 )) + i.x + vec3(0.0, i1.x, 1.0 )); vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0); m = m*m ; m = m*m ; vec3 x = 2.0 * fract(p * C.www) - 1.0; vec3 h = abs(x) - 0.5; vec3 ox = floor(x + 0.5); vec3 a0 = x - ox; m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h ); vec3 g; g.x = a0.x * x0.x + h.x * x0.y; g.yz = a0.yz * x12.xz + h.yz * x12.yw; return 130.0 * dot(m, g); } float rng2(vec2 seed) { return fract(sin(dot(seed * floor(iTime * 12.), vec2(127.1,311.7))) * 43758.5453123); } float rng(float seed) { return rng2(vec2(seed, 1.0)); } vec3 blurSample(in vec2 uv, in vec2 xoff, in vec2 yoff) { vec3 v11 = texture2D(inputImageTexture, uv + xoff).rgb; vec3 v12 = texture2D(inputImageTexture, uv + yoff).rgb; vec3 v21 = texture2D(inputImageTexture, uv - xoff).rgb; vec3 v22 = texture2D(inputImageTexture, uv - yoff).rgb; return (v11 + v12 + v21 + v22 + 2.0 * texture2D(inputImageTexture, uv).rgb) * 0.166667; } vec3 edgeStrength(in vec2 uv) { const float spread = 0.5; vec2 offset = vec2(1.0) / img_size.xy; vec2 up = vec2(0.0, offset.y) * spread; vec2 right = vec2(offset.x, 0.0) * spread; const float frad = 3.0; vec3 v11 = blurSample(uv + up - right, right, up); vec3 v12 = blurSample(uv + up, right, up); vec3 v13 = blurSample(uv + up + right, right, up); vec3 v21 = blurSample(uv - right, right, up); vec3 v22 = blurSample(uv, right, up); vec3 v23 = blurSample(uv + right, right, up); vec3 v31 = blurSample(uv - up - right, right, up); vec3 v32 = blurSample(uv - up, right, up); vec3 v33 = blurSample(uv - up + right, right, up); vec3 laplacian_of_g = v11 * 0.0 + v12 * 1.0 + v13 * 0.0 + v21 * 1.0 + v22 * -4.0 + v23 * 1.0 + v31 * 0.0 + v32 * 1.0 + v33 * 0.0; laplacian_of_g = laplacian_of_g * 1.0; return laplacian_of_g.xyz; } float sat( float t ) { return clamp( t, 0.0, 1.0 ); } vec2 sat( vec2 t ) { return clamp( t, 0.0, 1.0 ); } float remap( float t, float a, float b ) { return sat( (t - a) / (b - a) ); } float linterp( float t ) { return sat( 1.0 - abs( 2.0*t - 1.0 ) ); } float rand4( vec2 n ) { return fract(sin(dot(n.xy, vec2(12.9898, 78.233)))* 43758.5453); } float srand( vec2 n ) { return rand4(n) * 2.0 - 1.0; } float mytrunc( float x, float num_levels ) { return floor(x*num_levels) / num_levels; } vec2 mytrunc( vec2 x, vec2 num_levels ) { return floor(x*num_levels) / num_levels; } vec3 rgb2yuv( vec3 rgb ) { vec3 yuv; yuv.x = dot( rgb, vec3(0.299,0.587,0.114) ); yuv.y = dot( rgb, vec3(-0.14713, -0.28886, 0.436) ); yuv.z = dot( rgb, vec3(0.615, -0.51499, -0.10001) ); return yuv; } vec3 yuv2rgb( vec3 yuv ) { vec3 rgb; rgb.r = yuv.x + yuv.z * 1.13983; rgb.g = yuv.x + dot( vec2(-0.39465, -0.58060), yuv.yz ); rgb.b = yuv.x + yuv.y * 2.03211; return rgb; } void main (void) { vec3 c = texture2D(inputImageTexture, textureCoordinate).xyz; vec2 uv = frag_pos.xy / img_size.xy; if (i_type == 0) { float rgbIntesnsity = 0.1 + 0.1 * sin(time* 3.7) + 0.05*intensity; float displaceIntesnsity = 0.2 * pow( sin(time * 1.2), 4.0) + 0.15*intensity; float displace = blockyNoise(uv + vec2(uv.y, 0.0), displaceIntesnsity, 25.0, 66.6); displace *= blockyNoise(uv.yx + vec2(0.0, uv.x), displaceIntesnsity, 150.0, 13.7); uv.x += displace ; vec2 offs = 0.1 * vec2(blockyNoise(uv.xy + vec2(uv.y, 0.0), rgbIntesnsity, 65.0, 341.0), 0.0); float colr = texture2D(inputImageTexture, uv-offs).r; float colg = texture2D(inputImageTexture, uv).g; float colb = texture2D(inputImageTexture, uv +offs).b; gl_FragColor = vec4(vec3(colr, colg, colb), 1.0); if (offs.x > 0.0) { gl_FragColor.rgb = gl_FragColor.rgb - edgeStrength(uv) * 5.0; } else if (displace > 0.0) { gl_FragColor.rgb = gl_FragColor.rgb - edgeStrength(uv) * 5.0; } if (channel_r == 1) c.r = gl_FragColor.r; if (channel_g == 1) c.g = gl_FragColor.g; if (channel_b == 1) c.b = gl_FragColor.b; gl_FragColor = vec4(c, 1.0); } else if (i_type == 1) { float n_scale = clamp(rand2(vec2((iTime), (iTime) * floor(2.0)))* 5.0, 0.0, scale); float n_g_noise = rand2(vec2((iTime), (5.+iTime) * floor(300.0))) * 3123.0; vec3 original = c; vec2 block = floor(frag_pos.xy / vec2(n_scale)); vec2 uv_noise = block / vec2(n_g_noise); uv_noise += floor(vec2(iTime) * vec2(1234.0, 3543.0)) / vec2(64); vec3 d_noise = rand1(uv_noise); float block_thresh = pow(fract(floor(iTime) * 1236.0453), b_threshold); float line_thresh = pow(fract(iTime * 2236.0453), l_threshold); vec2 uv_r = uv; vec2 uv_g = uv; vec2 uv_b = uv; float noise_axis = uv_noise.y; float frag_axis = frag_pos.y; if (vertical == 1) { noise_axis = uv_noise.x; frag_axis = frag_pos.x; } if (d_noise.r < block_thresh || rand1(vec2(noise_axis, 0.0)).g < line_thresh) { vec2 dist = (fract(vec2(iTime,iTime*1.13971 + 0.129831)) - 0.5) * 0.3; uv_r += dist * 0.01 * rgb_offset; uv_g += dist * 0.02 * rgb_offset; uv_b += dist * 0.0125 * rgb_offset; } if (hash11(floor(iTime*10.0)*0.93178021) > 0.9) { uv_r.x -= 0.1; uv_g.x -= 0.2; uv_b.x -= 0.1; } gl_FragColor.r = texture2D(inputImageTexture, uv_r).r; gl_FragColor.g = texture2D(inputImageTexture, uv_g).g; gl_FragColor.b = texture2D(inputImageTexture, uv_b).b; vec3 col = gl_FragColor.rgb; if (d_noise.g < block_thresh) col.rgb = col.ggg; if (rand1(vec2(noise_axis, 0.0)).b * 5.5 < line_thresh) { if (rand2(vec2(floor(iTime*2.0))) < 0.333 ) col.rgb *= vec3(0.0, 0.0 , dot(col.rgb, vec3(1.0)))/2.0; else if (rand2(vec2(floor(iTime*2.0))) < 0.6 ) col.rgb *= vec3(0.0, dot(col.rgb, vec3(1.0)) ,0.0 )/2.0; else col.rgb *= vec3(dot(col.rgb, vec3(1.0)), 0.0 ,dot(col.rgb, vec3(1.0)) )/2.0; } if (d_noise.g * 1.5 < block_thresh || rand1(vec2(noise_axis, 0.0)).g * 2.5 < line_thresh ) { float line = fract(frag_axis / 3.0); vec3 mask = vec3(3.0, 0.0, 0.0); if (line > 0.333) mask = vec3(0.0, 3.0, 0.0); if (line > 0.666) mask = vec3(0.0, 0.0, 3.0); col = col.rgb * mask; } float blend = snoise(vec2(iTime*100.0)); blend = clamp((blend-(1.0-bias))*999999.0, 0.0, opacity); col = mix(original, col, blend); gl_FragColor = vec4(col, 1.0); if (channel_r == 1) c.r = gl_FragColor.r; if (channel_g == 1) c.g = gl_FragColor.g; if (channel_b == 1) c.b = gl_FragColor.b; gl_FragColor = vec4(c, 1.0); } else if (i_type == 2) { vec2 blockS = floor(uv * vec2(24., 9.)); vec2 blockL = floor(uv * vec2(8., 4.)); float r = rng2(uv); float lineNoise = pow(rng2(blockS), 8.0) * pow(rng2(blockL), 3.0) - pow(rng(7.2341), 17.0) * 2.; vec4 col1 = texture2D(inputImageTexture, uv); vec4 col2 = texture2D(inputImageTexture, uv + vec2(lineNoise * 0.02 * (1.0 + intensity*10.0) * rng(5.0), 0)); vec4 col3 = texture2D(inputImageTexture, uv - vec2(lineNoise * 0.02 * (1.0 + intensity*10.0) * rng(31.0), 0)); gl_FragColor = vec4(vec3(col1.x, col2.y, col3.z) , 1.0); if (channel_r == 1) c.r = gl_FragColor.r; if (channel_g == 1) c.g = gl_FragColor.g; if (channel_b == 1) c.b = gl_FragColor.b; if ( (channel_r == 1) && ( (channel_g == 0) || (channel_b == 0)) ) c.r = texture2D(inputImageTexture, uv + vec2(lineNoise * 0.02 * (1.0 + intensity*10.0) * rng(7.0), 0)).r; gl_FragColor = vec4(c, 1.0); } else if (i_type == 3) { vec2 uvR = uv; vec2 uvB = uv; uvR.x = uv.x * 1.0 - rand3() * (0.01 + intensity*0.05) * 0.8 ; uvB.y = uv.y * 1.0 + rand3() * (0.01 + intensity*0.05) * 0.8; if(uv.y < rand3() && uv.y > rand3() - hash11(iTime*1.71347)*0.2 ) { uv.x = (uv + (0.01 + intensity*0.03) * rand3()).x; uv.y = (uv - (0.01 + intensity*0.03) * rand3()).y; } if(uv.x > (rand3()) && uv.x > (rand3() - hash11(iTime*1.71347)*0.1) ) { uv.x = (uv + (0.01 + intensity*0.03) * rand3()).x; } float s_width = 100.0 + hash11(iTime*0.713 + floor(frag_pos.y/(80.0) )*51.3 + floor(frag_pos.x/(80.0) )*73.57 )*100.0; if ( (mod(frag_pos.y,s_width) >= 0.0) && (mod(frag_pos.y,s_width) <= s_width/2.0) ) { uv.x += hash11( floor(frag_pos.y/(s_width/2.0))*(s_width/2.0)*17.5 + floor(frag_pos.x/(s_width/2.0))*(s_width/2.0)*17.5 +(iTime*1.51))*(0.005 + hash11(0.317*iTime)*(0.015 - (1.0 - intensity)*0.015 ) ); } else uv.x -= hash11( (iTime*2.51))*0.005*intensity; vec4 c2; if (rand3() > 0.2 ) c2.r = texture2D(inputImageTexture, uvR).r; else c2.r = texture2D(inputImageTexture, uv).r; if (rand3() > 0.4) c2.g = texture2D(inputImageTexture, uv).g; else c2.g = texture2D(inputImageTexture, uvB).g; if (rand3() > 0.6) c2.b = texture2D(inputImageTexture, uv).b; else c2.b = texture2D(inputImageTexture, uvB).g; gl_FragColor = vec4(c2.rgb,1.0); if (channel_r == 1) c.r = gl_FragColor.r; if (channel_g == 1) c.g = gl_FragColor.g; if (channel_b == 1) c.b = gl_FragColor.b; gl_FragColor = vec4(c, 1.0); } else if (i_type == 4) { float THRESHOLD = 0.2 + intensity*0.8; float time_s = mod( iTime, 32.0 ); float glitch_threshold = 1.0 - THRESHOLD; float max_ofs_siz = 0.1 + hash11(floor(iTime*2.0)*1.7931 + 7.15319)*0.3 ; const float yuv_threshold = 0.5; const float time_frq = 16.0; vec2 uv = frag_pos.xy / img_size.xy; vec2 uv_axis = uv.yy; float frag_axis = frag_pos.y; float frag_axis2 = frag_pos.x; if (vertical == 1) { uv_axis = uv.xx; frag_axis = frag_pos.x; frag_axis2 = frag_pos.y; } const float min_change_frq = 4.0; float ct = mytrunc( time_s, min_change_frq ); float change_rnd = rand4( mytrunc(uv_axis,vec2(16)) + 150.0 * ct ); float tf = time_frq*change_rnd; float t = 5.0 * mytrunc( time_s, tf ); float vt_rnd = 0.5*rand4( mytrunc(uv_axis + t, vec2(11)) ); vt_rnd += 0.5 * rand4(mytrunc(uv_axis+ t, vec2(7))); vt_rnd = vt_rnd*2.0 - 1.0; vt_rnd = sign(vt_rnd) * sat( ( abs(vt_rnd) - glitch_threshold) / (1.0-glitch_threshold) ); vec2 uv_nm = uv; uv_nm = sat( uv_nm + vec2(max_ofs_siz*vt_rnd, 0) ); float rnd = rand4( vec2( mytrunc( time_s, 8.0 )) ); float s_width = 70.0 + hash11(iTime*0.713 + floor(frag_pos.y/(80.0) )*51.3 )*70.0; if ( (mod(frag_axis,s_width) >= 0.0) && (mod(frag_axis,s_width) <= s_width/2.0) ) { uv_nm.x += hash11( floor(frag_axis/(s_width/2.0))*(s_width/2.0)*17.5 + floor(frag_axis2/(s_width/2.0))*(s_width/2.0)*17.5 +(iTime*1.51))*(0.005 + hash11(0.317*iTime)*(0.015 - (1.0 - intensity)*0.01 ) ); } else uv_nm.x -= hash11( (iTime*2.51))*0.01*intensity; vec4 smpl = texture2D( inputImageTexture, uv_nm); vec3 smpl_yuv = rgb2yuv( smpl.rgb ); if (hash11(iTime + 17.531) > 0.2 + (1.0 - intensity)*0.3) { smpl_yuv.y /= 1.0-3.0*abs(vt_rnd) * sat( yuv_threshold - vt_rnd ); smpl_yuv.z += 0.125 * vt_rnd * sat( vt_rnd - yuv_threshold ); } gl_FragColor = vec4( yuv2rgb(smpl_yuv), smpl.a ); if (channel_r == 1) c.r = gl_FragColor.r; if (channel_g == 1) c.g = gl_FragColor.g; if (channel_b == 1) c.b = gl_FragColor.b; gl_FragColor = vec4(c, 1.0); } else if (i_type == 5) { vec2 uv_orig = uv; float s_width = 70.0 + hash11(iTime*0.713 + floor(frag_pos.y/(50.0) )*51.3 + floor(frag_pos.x/(50.0) )*73.57 )*70.0; if ( (mod(frag_pos.y,s_width) >= 0.0) && (mod(frag_pos.y,s_width) <= s_width/2.0) ) { uv.x += hash11( floor(frag_pos.y/(s_width/2.0))*(s_width/2.0)*17.5 + floor(frag_pos.x/(s_width/2.0))*(s_width/2.0)*17.5 +(iTime*1.51))*(0.005 + hash11(0.317*iTime)*(0.015 - (1.0 - intensity)*0.007 ) ); } else uv.x -= hash11( (iTime*2.51))*0.001; if ( (mod(frag_pos.x,s_width) >= 0.0) && (mod(frag_pos.x,s_width) <= s_width/2.0) ) { uv.y -= hash11( floor(frag_pos.y/(s_width/2.0))*(s_width/2.0)*7.5 + floor(frag_pos.x/(s_width/2.0))*(s_width/2.0)*27.5 +(iTime*1.51))*(0.005 + hash11(0.1317*iTime)* (0.015 - (1.0 - intensity)*0.007 ) ); } else uv.y += hash11( (iTime*0.51) + 1.3)*0.001; vec4 texColor = texture2D(inputImageTexture,uv); vec4 texColor_o = texture2D(inputImageTexture,uv_orig); gl_FragColor = vec4(texColor.rgb,1.0); if ( (mod(frag_pos.y,s_width) >= 0.0) && (mod(frag_pos.y,s_width) <= s_width/2.0) ) { if (hash11(iTime + 17.531 + floor(frag_pos.y/(60.0) )*1.37 + floor(frag_pos.x/(60.0) )*2.37) > 0.97 + (1.0 - intensity)*0.029 ) { gl_FragColor = vec4(mix(texColor.rgb,texColor_o.rgb,-100.2) - edgeStrength(uv) * 50.0,1.0); } if (hash11(iTime + 17.531 + floor(frag_pos.y/(30.0) )*1.37 + floor(frag_pos.x/(30.0) )*2.37) > 0.96 + (1.0 - intensity)*0.035) { gl_FragColor = vec4(mix(texColor.rgb,texColor_o.rgb,-100.2) - edgeStrength(uv) * 50.0,1.0); } if (hash11(iTime + 17.531 + floor(frag_pos.y/(10.0) )*1.37 + floor(frag_pos.x/(10.0) )*2.37) > 0.95 + (1.0 - intensity)*0.044) { gl_FragColor = vec4(mix(texColor.rgb,texColor_o.rgb,-100.2) - edgeStrength(uv) * 50.0,1.0); } } if (channel_r == 1) c.r = gl_FragColor.r; if (channel_g == 1) c.g = gl_FragColor.g; if (channel_b == 1) c.b = gl_FragColor.b; gl_FragColor = vec4(c, 1.0); } }
);
@implementation DN

#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageDNFragmentShaderString]))
    {
        return nil;
    }
    gl_img_width = [filterProgram uniformIndex:@"img_width"];
    gl_img_height = [filterProgram uniformIndex:@"img_height"];
    gl_time = [filterProgram uniformIndex:@"iTime"];
    gl_intensity = [filterProgram uniformIndex:@"intensity"];
    gl_type = [filterProgram uniformIndex:@"i_type"];
    gl_speed = [filterProgram uniformIndex:@"speed"];
    gl_vertical = [filterProgram uniformIndex:@"vertical"];
    gl_channel_r  = [filterProgram uniformIndex:@"channel_r"];
    gl_channel_g  = [filterProgram uniformIndex:@"channel_g"];
    gl_channel_b  = [filterProgram uniformIndex:@"channel_b"];
    self.type = 2;
    self.intensity = 0.5;
    self.speed = 0.1;
    self.channel_r = 1;
    self.channel_g = 1;
    self.channel_b = 1;
    self.animations = [NSMutableArray array];
    int vertical = 0;   //media type 1
    [self setInteger:vertical forUniform:gl_vertical program:filterProgram];
    self.use_timer = true;
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setChannel_r:(int)newValue;
{
    _channel_r = newValue;
    [self setInteger:_channel_r forUniform:gl_channel_r program:filterProgram];
}

- (void)setChannel_g:(int)newValue;
{
    _channel_g = newValue;
    [self setInteger:_channel_g forUniform:gl_channel_g program:filterProgram];
}

- (void)setChannel_b:(int)newValue;
{
    _channel_b = newValue;
    [self setInteger:_channel_b forUniform:gl_channel_b program:filterProgram];
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

- (void)setSpeed:(float)newValue {
    _speed = newValue;
    [self setFloat:_speed forUniform:gl_speed program:filterProgram];
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
    self.time_counter = [NSDate timeIntervalSinceReferenceDate] - self.startTime;
    float global_speed = 1.0;
    
    if(([NSDate timeIntervalSinceReferenceDate] - self.tempStartTime) >= ((self.speed + 0.01)/fmax(global_speed, 0.02)))
       {
           self.tempStartTime = [NSDate timeIntervalSinceReferenceDate];
           self.time_counter += self.i_rand;
           [self setFloat:self.time_counter forUniform:gl_time program:filterProgram];
           if(self.animations && [self.animations count]) {
               // todo
           }
    }
end:
    [super renderToTextureWithVertices:vertices textureCoordinates:textureCoordinates];
}

@end
