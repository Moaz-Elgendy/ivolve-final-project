# Portfolio Docs + Pages Site Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Framed, renamed screenshots + PNG architecture diagrams, a concise portfolio-and-instructor README, and a hand-written static site in `docs/` for GitHub Pages.

**Architecture:** Images are produced by rendering small HTML/SVG files with the already-installed headless Chromium (no npm install). README and site consume the same PNGs. Site = one `docs/index.html` + `docs/site.css`, served by Pages from `main:/docs`.

**Tech Stack:** HTML, CSS, SVG, bash, headless Chromium at `$HOME/.cache/ms-playwright/chromium-1254/chrome-linux64/chrome`.

**Spec:** `docs/superpowers/specs/2026-11-22-portfolio-docs-site-design.md` — read it first; its "Facts to state correctly", "Anti-goals" and "Visual direction" sections bind every task.

## Global Constraints

- Render command (only tool for PNGs): `"$CHROME" --headless=new --no-sandbox --hide-scrollbars --force-device-scale-factor=1 --window-size=W,H --screenshot=OUT.png file://ABS.html` with `CHROME=$HOME/.cache/ms-playwright/chromium-1254/chrome-linux64/chrome`.
- Palette: paper `#F4F1EA`, ink `#1A1A1A`, accent `#E8590C`, rule `#D6D0C4`. Fonts: IBM Plex Sans + IBM Plex Mono (Google Fonts in site; same families with `sans-serif`/`monospace` fallback in render templates).
- File names: lowercase, hyphens, no spaces (Pages is case-sensitive).
- Never claim Trivy fails the build; it is report-only (`--exit-code 0`). Never mention Terraform workspaces.
- Build failures: #1–#2 = `jenkins` user lacked Docker socket permission, fixed by adding it to `docker` group (Ansible `docker` role); #3–#4 = Trivy Java DB overflowed 2 GiB tmpfs `/tmp` + blocking exit code; #5 green.
- Links: repo `https://github.com/Moaz-Elgendy/ivolve-final-project`, profile `https://github.com/Moaz-Elgendy`, LinkedIn `https://www.linkedin.com/in/moaz-m-elgendy`.
- No emoji, no gradients, no glassmorphism, no marketing verbs (unleash, seamless, revolutionize, robust, cutting-edge).
- Do not commit or push; the user commits at the end.
- Render-tooling lives in `tools/render/` (outside `docs/`, so Pages does not publish it).

## Review Focus

1. **Broken image paths** — README uses `docs/images/x.png` (repo root relative), site uses `images/x.png` (docs relative). Checked by Task 6 path check.
2. **Personal browser chrome leaking** — address bar, "MK" avatar, extension icons visible in any framed PNG. Checked by Task 3 Step 3 visual review.
3. **Phone width (375px)** — site must not scroll horizontally; terminal block and tables scroll inside their own box. Checked by Task 5 Step 3.
4. **Dark mode** — site text and rules readable when `prefers-color-scheme: dark`; framed PNGs (paper frame) still look intentional on ink background. Checked by Task 5 Step 3.
5. **Image weight** — each PNG < 600 KB so README and site load fast. Checked by Task 6.

---

### Task 1: Rename and move raw screenshots (Haiku)

**Files:** move `docs/*.png` → `docs/images/raw/`

**Interfaces:** Produces these raw files consumed by Task 3:

| Original | `docs/images/raw/` name |
| --- | --- |
| `Screenshot 2026-11-22 114306.png` | `vault-setup-script.png` |
| `Screenshot 2026-11-22 114932.png` | `vault-ui-secrets-engines.png` |
| `Screenshot 2026-11-22 114946.png` | `vault-ui-ivolve-secrets.png` |
| `Screenshot 2026-11-22 125811.png` | `jenkins-stage-view.png` |
| `Screenshot 2026-11-22 131246.png` | `argocd-dev-network.png` |
| `Screenshot 2026-11-22 131256.png` | `argocd-dev-tree.png` |
| `Screenshot 2026-11-22 131305.png` | `argocd-dev-pods-by-node.png` |
| `namespace ivolve-dev 1.png` | `grafana-ns-dev-cpu.png` |
| `namespace ivolve-dev 2.png` | `grafana-ns-dev-memory.png` |
| `worker node one before application.png` | `grafana-node1-before.png` |
| `worker node one after application.png` | `grafana-node1-after.png` |
| `worker node two before application.png` | `grafana-node2-before.png` |
| `worker node two after application.png` | `grafana-node2-after.png` |

- [ ] **Step 1:** `mkdir -p docs/images/raw` and `mv` each file per the table (files are untracked, plain `mv`).
- [ ] **Step 2: Verify** `ls docs/*.png 2>/dev/null | wc -l` → `0`; `ls docs/images/raw | wc -l` → `13`.

---

### Task 2: Architecture + network diagrams (Sonnet)

**Files:**
- Create: `docs/images/architecture.svg`, `docs/images/architecture.png`
- Create: `docs/images/aws-network.svg`, `docs/images/aws-network.png`
- Create: `tools/render/render.sh` (shared by Task 3)

**Interfaces:**
- Produces `tools/render/render.sh IN.html|IN.svg OUT.png WIDTH HEIGHT` — wraps the Global render command; absolute-paths its input; exits non-zero if OUT missing.

Content (from spec + README sections 2–3, which hold the exact facts):
- `architecture.svg` (1600×1000): Developer → GitHub (branches main/dev/stg/prod) → Jenkins on EC2 [Build ×3 → Trivy scan (report-only) → Push] → ECR (9 repos `<service>-<env>`) ; Jenkins → commit `imageTag` to env branch → Argo CD polls → EKS cluster box with namespaces `ivolve-dev|stg|prod` (frontend → auth → mysql StatefulSet/EBS gp3; frontend → roadmap), `vault` (KMS auto-unseal, agent injector → sidecars), `monitoring` (Prometheus + Grafana), `argocd`. Browser → LoadBalancer → frontend. Numbered steps 1–8 on arrows in accent orange. Legend line: "dev/stg auto-sync · prod manual".
- `aws-network.svg` (1600×1000): VPC 10.0.0.0/16, AZ a / AZ b, public 10.0.0.0/24 + 10.0.1.0/24 (IGW route, Jenkins t3.small, NAT+EIP, LB ENIs), private 10.0.2.0/24 + 10.0.3.0/24 (EKS nodes m7i-flex.large), regional strip: EKS control plane 1.35, ECR, KMS, S3 state.
- Style: paper background, ink 1.5px strokes, rounded 6px boxes, mono labels for names/CIDRs, sans for titles, accent only for the flow path. Text ≥ 16px at 1600 width.

- [ ] **Step 1:** Write `tools/render/render.sh`; `chmod +x`.
- [ ] **Step 2:** Write both SVGs.
- [ ] **Step 3:** Render: `tools/render/render.sh docs/images/architecture.svg docs/images/architecture.png 1600 1000` (same for network).
- [ ] **Step 4: Verify** — open both PNGs with the Read tool: no clipped text, no overlapping boxes, arrows land on boxes, all facts above present. Fix and re-render until clean.

---

### Task 3: Framed screenshots (Sonnet)

**Files:**
- Create: `tools/render/frame.html` (template), `tools/render/frames.sh` (loops the list below)
- Create: `docs/images/<name>.png` for the 11 outputs below

**Interfaces:**
- Consumes: `tools/render/render.sh` (Task 2), raw files (Task 1).
- Produces (used by Tasks 4–5):

| Output | Source(s) | Label strip |
| --- | --- | --- |
| `vault-setup-script.png` | raw same name | `FIG · TERMINAL · helm/vault/setup.sh` (dark terminal frame) |
| `vault-ui-secrets-engines.png` | same | `FIG · VAULT · secrets engines` |
| `vault-ui-ivolve-secrets.png` | same | `FIG · VAULT · secret/ivolve` |
| `jenkins-stage-view.png` | same | `FIG · JENKINS · stage view, builds 1–5` |
| `argocd-dev-network.png` | same | `FIG · ARGO CD · ivolve-dev · network` |
| `argocd-dev-tree.png` | same | `FIG · ARGO CD · ivolve-dev · resource tree` |
| `argocd-dev-pods-by-node.png` | same | `FIG · ARGO CD · ivolve-dev · pods by node` |
| `grafana-ns-dev-cpu.png` | same | `FIG · GRAFANA · ivolve-dev · CPU` |
| `grafana-ns-dev-memory.png` | same | `FIG · GRAFANA · ivolve-dev · memory` |
| `grafana-node1-before-after.png` | node1-before + node1-after side by side, captions "before deploy" / "after deploy" | `FIG · GRAFANA · node 1 · before / after deploy` |
| `grafana-node2-before-after.png` | node2 pair | `FIG · GRAFANA · node 2 · before / after deploy` |

Approach: `frame.html` takes query params (`img`, `img2`, `label`, `crop` as CSS `object-position`/clip values, `theme=terminal`) and lays out: paper background, 48px padding, mono label strip (ink text, accent dot), screenshot in 1px ink border with soft shadow. Cropping via a fixed-size wrapper with `overflow:hidden` and negative offsets per image. Crop rule: remove the browser address bar row and everything right of the tool's own UI chrome that shows extensions/avatar; Argo/Vault/Grafana keep their own headers. Output width 1600px.

- [ ] **Step 1:** Write `frame.html` and `frames.sh` with per-image crop values.
- [ ] **Step 2:** Run `tools/render/frames.sh`; expect 11 PNGs in `docs/images/` (excluding `raw/`, diagrams).
- [ ] **Step 3: Verify** — Read every output PNG: no address bar, no "MK" avatar, no extension icons, no "Not secure" badge, label correct, nothing important cropped (Jenkins all 5 rows; Argo sync status visible; Grafana panel titles visible). Adjust crops and re-run until all 11 pass.

---

### Task 4: README rewrite (Sonnet)

**Files:** Modify: `README.md` (full rewrite, ≤ 250 lines)

**Interfaces:** Consumes image names from Tasks 2–3 as `docs/images/<name>.png`. Site URL: `https://moaz-elgendy.github.io/ivolve-final-project/`.

Structure and content: spec section "3. README.md". Source every fact from the current `README.md` and the code it links; keep the logos header. Keep these from the old README in condensed form: stack table, pipeline stages, promotion model, NetworkPolicy table, resources table, Vault secret paths, HTTP API table, "what stays out of git" table, deploy runbook (commands verbatim). Components section: one block per Terraform, Ansible, Jenkins, Helm, Argo CD, Vault, Monitoring, Application — 3–5 lines + folder link each. "Decisions & lessons" includes the build #1–#5 story from Global Constraints and the Trivy report-only trade-off.

- [ ] **Step 1:** Write the README.
- [ ] **Step 2: Verify** — `wc -l README.md` ≤ 250; `grep -niE 'workspace|fails the build|exit-code 1' README.md` → no output; `grep -o 'docs/images/[a-z0-9-]*\.png' README.md | sort -u | xargs ls` → no errors.

---

### Task 5: Static site (Sonnet)

**Files:** Create: `docs/index.html`, `docs/site.css`, `docs/.nojekyll` (empty)

**Interfaces:** Consumes `images/<name>.png` (relative to `docs/`).

Content: spec section "4. Site" and "Visual direction". Sections in order: header (name "Moaz Elgendy", GitHub + LinkedIn links), hero (one-sentence pitch, `architecture.png`), 01 Infrastructure (`aws-network.png`, 4 modules list, S3 state, what stays out of git), 02 Pipeline (`jenkins-stage-view.png`, stages, shared library), 03 GitOps (`argocd-dev-tree.png`, `argocd-dev-network.png`, promotion model table), 04 Secrets (`vault-setup-script.png`, `vault-ui-ivolve-secrets.png`, injection flow in 5 steps), 05 Observability (`grafana-node1-before-after.png`, `grafana-ns-dev-memory.png`), 06 Running cluster (terminal block: trimmed `kubectl get pods -A` showing argocd, ivolve-dev, monitoring, vault rows + 2 nodes `v1.35.9-eks`), 07 Decisions & what broke, footer (repo link, "Read the full documentation" → README on GitHub). Copy: plain, specific, numbers over adjectives. Images: `<a href="images/x.png"><img loading="lazy" alt="…" width height></a>`. Semantic HTML, visible focus states, `meta description`, Open Graph image = `images/architecture.png`.

- [ ] **Step 1:** Write the three files.
- [ ] **Step 2:** Render previews: `tools/render/render.sh docs/index.html /tmp-scratch/site-desktop.png 1440 4000` and at `375 5000` (use the session scratchpad dir for outputs).
- [ ] **Step 3: Verify** — Read both previews: layout intact at 375 (no element wider than viewport), sections in order, images load; then add `<html data-theme="dark">` temporarily or render with `--force-dark-mode` and check contrast; check against Anti-goals list. Fix and re-render until clean.

---

### Task 6: Final verification (Opus, main session)

- [ ] **Step 1:** Path check: every `src`/`href` to `images/` in `docs/index.html` and every `docs/images/` path in `README.md` exists.
- [ ] **Step 2:** `find docs/images -maxdepth 1 -name '*.png' -size +600k` → no output (else re-render at lower size or compress via chrome JPEG-free path: reduce width to 1400).
- [ ] **Step 3:** `git status` review: only expected files changed; `testImage.groovy` untouched by this work.
- [ ] **Step 4:** Report to user with Pages enable steps (Settings → Pages → Branch `main`, folder `/docs`) and suggested commit.
