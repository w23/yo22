uniform float _t,_p;
uniform sampler2D _N,_T;
varying vec2 V;
vec4 n4(vec2 v){return texture2D(_N,(v+vec2(.5))/256.,-20.);}
float n(vec2 v){return n4(v).w;}
float vn(vec2 v,vec2 m) {
  vec2 e=vec2(1.,0.),V=floor(v);v=fract(v);v*=v*(3.-2.*v);
  return mix(mix(n(mod(v+e.yy,m)),n(mod(v+e.xy,m)),v.x),mix(n(mod(v+e.yx,m)),n(mod(v+e.xx,m)),v.x),v.y);
}
float fbm(vec2 v,float s) {
  float r=0.,k=.5;
  for(int i=0;i<12;++i,k*=.5,s*=2.)r+=k*vn(v*s,vec2(s));
  return r;
}
float
Kr = 0.27,
Ke = 0.005,
Ks = 0.8;
vec2 uv=floor(gl_FragCoord.xy);
float transfer(float H,float w,vec2 ofs){
  vec4 c=texture2D(_T,(uv+ofs+vec2(.5))/4096.,-20.);
  float h=c.w+c.z,d=H-h;
  if(d>0.)return -min(w,d);
  else return min(c.w,-d);
}
void main(){
  vec4 c=texture2D(_T,(uv+vec2(.5))/4096.,-20.);
  //gl_FragColor=c;return;
  // 1. transfer
  vec4 c0=c;
  float h=c.w+c.z,dw=0.;
  vec2 e=vec2(1.,0.);
  dw+=transfer(h,c.w,e.xy);
  dw+=transfer(h,c.w,e.yx);
  dw+=transfer(h,c.w,-e.xy);
  dw+=transfer(h,c.w,-e.yx);
#if 0
  float kk=1./(4.*sqrt(2.));
  dw+=transfer(h,c.w,vec2(1.,1.))*kk;
  dw+=transfer(h,c.w,vec2(1.,-1.))*kk;
  dw+=transfer(h,c.w,vec2(-1.,1.))*kk;
  dw+=transfer(h,c.w,-vec2(1.,1.))*kk;
  c.w+=dw/4.;
#else
  c.w+=dw/4.;
#endif
  // 2. evaporate
  //dw=min(c.w,Ke);
  dw=c.w*Ke;
  c.z+=dw*Ks;
  c.w-=dw;
  // 3. rain
  float sa=sin(_t*373.4111),ca=cos(_t*373.4111);
  mat2 m=mat2(sa,ca,ca,-sa);
  dw=Kr*n4((uv+vec2(_t*123.24,317.1141*_t))*m).x*(0==mod(floor(_t/3.),12.)?.1:.0);
  //dw=Kr*n4((uv+vec2(_t*123.24,317.1141*_t))*m)*(0==mod(floor(_t/3.),12.)?1.:0.);
  c.z-=dw*Ks;
  c.w+=dw;
  // 4. PROFIT
  gl_FragColor=vec4(
    1000.*(c.w-c0.w),
    -1000.*(c.z-c0.z),
    c.z,
    c.w);
}
