"""Import the owner's licensed CraftPix Warrior archive. Vendor assets stay private."""
from pathlib import Path
import sys,math,json,re,subprocess,shutil,tempfile
import xml.etree.ElementTree as E
from concurrent.futures import ThreadPoolExecutor
import fitz
SRC=Path(sys.argv[1]);OUT=Path(__file__).resolve().parents[1]/'data/graphics/hero/craftpix'
DIRS=['Front','Back','Left_Side','Right_Side'];OUT.mkdir(parents=True,exist_ok=True)
def raster(s,p):
 d=fitz.open(stream=s.encode(),filetype='svg');q=fitz.open('pdf',d.convert_to_pdf());q[0].get_pixmap(alpha=True).save(str(p))
def curve(k,t):
 t=max(0,min(1,t));kind=k.get('curve_type','linear');c=[float(k.get('c'+str(i),0)) for i in range(1,5)]
 if kind=='instant':return 0
 if kind=='linear':return t
 if kind=='bezier':
  lo,hi=0.,1.
  for _ in range(25):
   u=(lo+hi)/2;x=3*(1-u)**2*u*c[0]+3*(1-u)*u*u*c[2]+u**3
   if x<t:lo=u
   else:hi=u
  return 3*(1-u)**2*u*c[1]+3*(1-u)*u*u*c[3]+u**3
 v=[0]+c[:{'quadratic':1,'cubic':2,'quartic':3,'quintic':4}[kind]]+[1]
 while len(v)>1:v=[a+(b-a)*t for a,b in zip(v,v[1:])]
 return v[0]
def compose(p,q):
 x,y,a,sx,sy,alpha=p;X,Y,A,SX,SY,AL=q;r=math.radians(a);X*=sx;Y*=sy
 return [x+X*math.cos(r)-Y*math.sin(r),y+X*math.sin(r)+Y*math.cos(r),a+A*(1 if sx*sy>=0 else -1),sx*SX,sy*SY,alpha*AL]
def value(o):return [float(o.get(n,d)) for n,d in [('x',0),('y',0),('angle',0),('scale_x',1),('scale_y',1),('a',1)]]
def sample(a,t):
 length=float(a.get('length'));mains=a.find('mainline').findall('key');m=max((k for k in mains if float(k.get('time',0))<=t),key=lambda k:float(k.get('time',0)))
 mi=mains.index(m);mt=float(m.get('time',0));nt=float(mains[mi+1].get('time',0)) if mi+1<len(mains) else length;tt=mt+curve(m,(t-mt)/(nt-mt))*(nt-mt) if nt>mt else mt;timelines={x.get('id'):x for x in a.findall('timeline')}
 def local(ref):
  tl=timelines[ref.get('timeline')];keys=tl.findall('key');idx=int(ref.get('key'));k=keys[idx];nk=keys[(idx+1)%len(keys)];st=float(k.get('time',0));et=float(nk.get('time',0))
  if et<st:et+=length
  o=k.find('bone');o=o if o is not None else k.find('object');no=nk.find(o.tag);v=value(o);v2=value(no);u=curve(k,(tt-st)/(et-st)) if et>st and len(keys)>1 else 0;spin=int(k.get('spin',1));diff=v2[2]-v[2]
  if spin==0:diff=0
  elif spin>0 and diff<0:diff+=360
  elif spin<0 and diff>0:diff-=360
  vv=[x+(y-x)*u for x,y in zip(v,v2)];vv[2]=v[2]+diff*u
  return vv,o,tl.get('name')
 bones={}
 for b in m.findall('bone_ref'):
  v,_,_=local(b);bones[b.get('id')]=compose(bones[b.get('parent')],v) if b.get('parent') is not None else v
 result=[]
 for ref in m.findall('object_ref'):
  v,o,name=local(ref);v=compose(bones[ref.get('parent')],v) if ref.get('parent') is not None else v
  result.append(dict(folder=o.get('folder'),file=o.get('file'),v=v,z=float(ref.get('z_index',0)),px=o.get('pivot_x'),py=o.get('pivot_y'),name=name))
 return result

def vector(job):
 d,name,eps=job;dest=OUT/d/(name+'.svg');dest.parent.mkdir(exist_ok=True)
 with tempfile.TemporaryDirectory() as tmp:
  pdf=Path(tmp)/'part.pdf';subprocess.run(['gs','-q','-dNOPAUSE','-dBATCH','-dEPSCrop','-sDEVICE=pdfwrite','-sOutputFile='+str(pdf),str(eps)],check=True,stdout=subprocess.DEVNULL);doc=fitz.open(pdf);s=doc[0].get_svg_image()
 def color(m):
  h=m[1];r,g,b=[int(h[i:i+2],16) for i in (0,2,4)];l=(r+g+b)/765
  if max(r,g,b)<34:return 'fill="#192432"'
  if name=='HairMustacheBeard':rgb=(13+l*43,23+l*50,34+l*62)
  elif 'Shoes' in name:rgb=(19+l*30,45+l*64,69+l*75)
  elif r>b*1.13 and r>g*1.03:rgb=(88+l*156,64+l*140,30+l*95)
  elif 'Body' in name:rgb=(120+l*129,160+l*92,184+l*69)
  else:rgb=(27+l*65,72+l*108,110+l*123)
  return 'fill="#%02x%02x%02x"'%tuple(min(255,int(x)) for x in rgb)
 s=re.sub(r'fill="#([0-9a-fA-F]{6})"',color,s)
 if name=='HairMustacheBeard':
  cx={'Front':250,'Back':250,'Left_Side':284,'Right_Side':216}[d]
  bun=f'<g stroke="#192432" stroke-width="10" stroke-linejoin="round"><path fill="#203348" d="M {cx-39},67 C {cx-70},15 {cx-33},-8 {cx},7 C {cx+43},-4 {cx+62},28 {cx+36},69 Z"/><path fill="none" stroke="#3c5269" stroke-width="7" d="M {cx-21},55 Q {cx-39},21 {cx-6},16 M {cx+9},16 Q {cx+35},32 {cx+22},54"/><path fill="#d9b461" d="M {cx-43},55 Q {cx},42 {cx+44},55 L {cx+39},75 Q {cx},64 {cx-37},77 Z"/></g>'
  s=s.replace('</svg>',bun+'</svg>')
 dest.write_text(s);raster(s,dest.with_suffix('.png'))
jobs=[]
for d in DIRS:
 names=[p.stem for p in (SRC/'Warrior_clothes_1/PNG'/d).glob('*.png')]
 for eps in (SRC/'Warrior_clothes_1/EPS'/d).glob('*.eps'):
  for name in sorted(names,key=len,reverse=True):
   key='Hair-Mustache-Beard' if name=='HairMustacheBeard' else ('Body' if name=='Body_clothes' else name)
   if eps.stem.lower().endswith('_'+key.lower()) or eps.stem.lower().endswith('_'+name.lower()):
    if name not in ['Hat','Shiled','Ghost','Sword']:jobs.append((d,name,eps))
    break
with ThreadPoolExecutor(max_workers=4) as pool:list(pool.map(vector,jobs))
sword='''<svg xmlns="http://www.w3.org/2000/svg" width="400" height="128" viewBox="0 0 400 128"><g stroke="#192432" stroke-width="7" stroke-linejoin="round"><path fill="#d5b363" d="M22 53 L42 48 L48 64 L42 80 L22 75Z"/><path fill="#264d6b" d="M42 54H106V74H42Z"/><path fill="#edfaff" d="M113 51 L342 55 L382 64 L342 73 L113 77Z"/><path fill="#89b7d1" stroke="none" d="M121 64H370L339 70L121 73Z"/><path fill="#dfbd6b" d="M105 35 Q123 43 129 64 Q123 85 105 93 L99 83 Q111 64 99 45Z"/></g><path d="M56 56V72M70 56V72M84 56V72" stroke="#d3b265" stroke-width="4"/></svg>'''
for d in DIRS:(OUT/d/'Sword.svg').write_text(sword);raster(sword,OUT/d/'Sword.png')
data={'fps':30,'directions':{}}
for d in DIRS:
 r=E.parse(SRC/'Warrior_animations'/d/'Vector Parts/Animations.scml').getroot();files={};textures=[]
 for folder in r.findall('folder'):
  for f in folder.findall('file'):
   name=Path(f.get('name')).stem
   if name in ['Hat','Shiled','Ghost']:continue
   dest=OUT/d/(name+'.png')
   if folder.get('id')=='0':shutil.copy2(SRC/'Warrior_animations'/d/'Vector Parts'/f.get('name'),dest)
   assert dest.exists(),dest
   files[(folder.get('id'),f.get('id'))]=(len(textures),f,name);textures.append({'path':d+'/'+name+'.png','w':int(f.get('width')),'h':int(f.get('height')),'name':name})
 animations={}
 for a in r.findall('.//animation'):
  duration=int(a.get('length'))/1000;count=round(duration*30);frames=[]
  for i in range(count+(1 if a.get('name') in ['Died','Hurt','Attack_1','Attack_2'] else 0)):
   frame=[];parts=sample(a,min(i/30*1000,duration*1000));has_sword=False;hands=[]
   for p in parts:
    key=(p['folder'],p['file'])
    if key not in files:continue
    index,f,name=files[key];x,y,angle,sx,sy,alpha=p['v'];px=float(p['px'] if p['px'] is not None else f.get('pivot_x',0));py=float(p['py'] if p['py'] is not None else f.get('pivot_y',1));frame.append([index,x,-y,-math.radians(angle),sx,sy,alpha,px,py,p['z']])
    if name=='Sword':has_sword=True
    if name in ['Right_Hand','Left_Hand']:hands.append((name,p))
   if not has_sword and hands and a.get('name')!='Died':
    hand=next((p for n,p in hands if n==('Left_Hand' if d=='Back' else 'Right_Hand')),hands[-1][1]);x,y,ha,sx,sy,alpha=hand['v'];rad=math.radians({'Front':145,'Back':35,'Left_Side':155,'Right_Side':25}[d]);idx=next(j for j,f in enumerate(textures) if f['name']=='Sword');frame.append([idx,x-64*math.cos(rad),-y-64*math.sin(rad),rad,1,1,alpha,0,0.5,hand['z']-.1])
   frame.sort(key=lambda p:p[9]);frames.append([[round(v,6) if isinstance(v,float) else v for v in p] for p in frame])
  animations[a.get('name')]={'duration':duration,'frames':frames}
 data['directions'][d]={'textures':textures,'animations':animations}
(OUT/'rig.json').write_text(json.dumps(data,separators=(',',':')))
print('CraftPix: 4 directions, 9 authored clips each, vector head/color/jian edits complete')
