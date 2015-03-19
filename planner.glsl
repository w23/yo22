void main(){
  vec2 p = fc*32.;
  float h=1e6,H=0.;
  for(int x=0;x<32;++x){
    for(int y=0;y<32;++y){
      vec2 P = p + vec2(float(x), float(y));
      vec4 s = TT(P);
      H=max(H,s.z);h=min(h,s.z);
    }
  }
  float d = H - h;
  vec4 r = n4(fc);
  float pop = pow(smoothstep(25.,0.,d)*smoothstep(230.,110.,H),14.);
  pop *= .2+.8*r.z;
  pop += step(0., pop) * .08;
  gl_FragColor=vec4(r.y,max(0.,pop*90.)+H,h,H);
}
