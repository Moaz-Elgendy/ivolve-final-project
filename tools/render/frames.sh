#!/usr/bin/env bash
# usage: frames.sh  -- builds the 11 framed screenshots in docs/images/ from docs/images/raw/
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"; root="$(cd "$here/../.." && pwd)"
raw="$root/docs/images/raw"; out="$root/docs/images"
tmp="${TMPDIR:-/tmp}/frames.$$"; mkdir -p "$tmp"; trap 'rm -rf "$tmp"' EXIT
W="${W:-1600}"

# name | label | crop "x,y,w,h" (raw pixels, browser chrome removed)
BR='6,52,1890,904'
single() { # name label crop
  python3 - "$here/frame.html" "$tmp/$1.html" "$raw/$1.png" "$2" "$3" "$W" <<'PY'
import sys
tpl,dst,img,label,crop,W=sys.argv[1:]; W=int(W)
x,y,w,h=map(int,crop.split(',')); cw=W-96; s=min(1,cw/w); ch=round(h*s)
import struct
d=open(img,'rb').read(32); rw,rh=struct.unpack('>II',d[16:24])
body=f'<div class="shot"><img src="file://{img}"></div>'
t=open(tpl).read()
for k,v in dict(W=W,H=96+18+20+ch+2,GAP=0,CW=cw,CH=ch,IW=round(rw*s),ML=-round(x*s),MT=-round(y*s),LABEL=label,BODY=body).items():
    t=t.replace(f'__{k}__',str(v))
open(dst,'w').write(t); print(W,96+18+20+ch+2)
PY
}
pair() { # name label before after crop
  python3 - "$here/frame.html" "$tmp/$1.html" "$raw/$3.png" "$raw/$4.png" "$2" "$5" "$W" <<'PY'
import sys,struct
tpl,dst,a,b,label,crop,W=sys.argv[1:]; W=int(W)
x,y,w,h=map(int,crop.split(',')); gap=24; cw=(W-96-gap)//2; s=cw/w; ch=round(h*s)
def wd(p): return struct.unpack('>II',open(p,'rb').read(32)[16:24])[0]
def col(p,c): return f'<div class="col"><div class="cap">{c}</div><div class="shot"><img src="file://{p}" style="width:{round(wd(p)*s)}px"></div></div>'
body='<div class="row">'+col(a,'before deploy')+col(b,'after deploy')+'</div>'
H=96+18+20+24+ch+2
t=open(tpl).read()
for k,v in dict(W=W,H=H,GAP=gap,CW=cw,CH=ch,IW=0,ML=-round(x*s),MT=-round(y*s),LABEL=label,BODY=body).items():
    t=t.replace(f'__{k}__',str(v))
# per-image margins live on the img rule; widths overridden inline
open(dst,'w').write(t); print(W,H)
PY
}
terminal() {
  python3 - "$here/frame.html" "$tmp/$1.html" "$raw/$1.png" "$2" "$W" <<'PY'
import sys,struct
tpl,dst,img,label,W=sys.argv[1:]; W=int(W)
rw,rh=struct.unpack('>II',open(img,'rb').read(32)[16:24]); W=rw+96  # canvas fits terminal
body=f'<div class="term"><div class="bar"><b></b><b></b><b></b><span>helm/vault/setup.sh</span></div><img src="file://{img}"></div>'
H=96+18+20+30+rh+2
t=open(tpl).read()
for k,v in dict(W=W,H=H,GAP=0,CW=rw,CH=0,IW=0,ML=0,MT=0,LABEL=label,BODY=body).items():
    t=t.replace(f'__{k}__',str(v))
open(dst,'w').write(t); print(W,H)
PY
}
go() { n="$1"; shift; read -r w h < <("$@"); "$here/render.sh" "$tmp/$n.html" "$out/$n.png" "$w" "$h"; }

go vault-setup-script       terminal vault-setup-script "FIG · TERMINAL · helm/vault/setup.sh"
go vault-ui-secrets-engines single vault-ui-secrets-engines "FIG · VAULT · secrets engines" "$BR"
go vault-ui-ivolve-secrets  single vault-ui-ivolve-secrets  "FIG · VAULT · secret/ivolve" '6,52,1890,882'
go jenkins-stage-view       single jenkins-stage-view "FIG · JENKINS · stage view, builds 1–5" '8,12,1890,906'
go argocd-dev-network       single argocd-dev-network "FIG · ARGO CD · ivolve-dev · network" "$BR"
go argocd-dev-tree          single argocd-dev-tree "FIG · ARGO CD · ivolve-dev · resource tree" "$BR"
go argocd-dev-pods-by-node  single argocd-dev-pods-by-node "FIG · ARGO CD · ivolve-dev · pods by node" "$BR"
go grafana-ns-dev-cpu       single grafana-ns-dev-cpu "FIG · GRAFANA · ivolve-dev · CPU" "$BR"
go grafana-ns-dev-memory    single grafana-ns-dev-memory "FIG · GRAFANA · ivolve-dev · memory" "$BR"
P='405,52,1500,900'
go grafana-node1-before-after pair grafana-node1-before-after "FIG · GRAFANA · node 1 · before / after deploy" grafana-node1-before grafana-node1-after "$P"
go grafana-node2-before-after pair grafana-node2-before-after "FIG · GRAFANA · node 2 · before / after deploy" grafana-node2-before grafana-node2-after "$P"
