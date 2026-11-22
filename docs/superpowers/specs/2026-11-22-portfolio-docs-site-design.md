# Portfolio docs + GitHub Pages site — design

## Intent
Moaz's iVolve DevOps final project must serve two readers:
- **Instructor** grading the documentation: every component Moaz built must be documented, accurately.
- **Recruiter / portfolio visitor**: must grasp the project and its quality in under a minute.

Concise beats exhaustive. Accuracy beats impressiveness.

## Goals
1. Rename + frame the 13 screenshots in `docs/`, use them in README and site.
2. Architecture diagrams as PNG (not ASCII).
3. Rewrite `README.md`: portfolio-first opening, concise per-component documentation, short runbook.
4. Static site on GitHub Pages from `main` branch `/docs` folder.

## Non-goals
- No Terraform workspaces (repo has none; document the 4 modules + S3 state only).
- No changes to infra, app, pipeline, Helm or Argo code.
- No framework, bundler, or build step for the site.
- No live demo link (frontend LoadBalancer is `<pending>`; cluster is temporary).

## Anti-goals (failure even if it "works")
- Site looks AI-generated: purple/blue gradients, glassmorphism, emoji icons, bento grids of vague cards, "Unleash/Seamless/Revolutionize" copy, fake metrics.
- Docs claim something the code does not do (e.g. Trivy "fails the build").
- Screenshots leak personal browser chrome (avatar "MK", extensions, address bar).
- README so long the instructor or recruiter stops reading.

## Facts to state correctly
- Trivy is **report-only**: `--exit-code 0 --ignore-unfixed --severity HIGH,CRITICAL`, with `TMPDIR=$HOME/trivy-tmp` because the Java vuln DB overflowed the 2 GiB RAM-backed `/tmp` on the Jenkins host. Reason for report-only: unfixed base-image CVEs blocked every build. State as a deliberate trade-off.
- Jenkins stage view: builds #1–#2 failed at Build, #3–#4 at Test, #5 green end to end (~1 min). Cause of #1–#2: the `jenkins` user lacked Docker socket permission; fixed by adding it to the `docker` group (now in the Ansible `docker` role, which restarts Jenkins). Cause of #3–#4: Trivy tmpfs overflow + blocking exit code (above).
- Terraform: one stack, modules `network`, `ec2`, `ecr`, `eks`; S3 backend via git-ignored `backend.hcl`; ECR repos from `setproduct(services, environments)`.
- Environments: dev/stg/prod = git branch + Argo Application + namespace `ivolve-<env>` + values file. Dev/stg auto-sync, prod manual.
- Live cluster evidence (user-provided `kubectl get` output, 2026-11-22): EKS 2 nodes `v1.35.9-eks`, eu-west-1; namespaces argocd, ivolve-dev (auth 2/2, frontend 2/2 with Vault sidecar, mysql-0 2/2, roadmap 1/1), monitoring, vault, kube-system (aws-node, ebs-csi, pod-identity agent). Trim to the meaningful lines when shown.

## Approaches considered
| Approach | Trade-off | Verdict |
| --- | --- | --- |
| Plain HTML/CSS in `/docs` | Zero build, Pages serves directly, full design control | **Chosen** |
| Jekyll theme | Free styling, but themes look generic; fights the anti-slop goal | Rejected |
| Astro/Vite + Actions deploy | Nice DX, adds toolchain + workflow to maintain for one page | Rejected |
| Separate `<user>.github.io` repo | Good for a multi-project portfolio later | User chose this repo |

Diagrams: hand-authored SVG rendered to PNG via Playwright Chromium (already installed) — chosen over Mermaid (generic look, weak for network layouts).
Screenshot framing: HTML template per image rendered by Playwright — chosen over ImageMagick (not installed) and manual editing.

## Visual direction: "engineering field report"
- Paper background `#F4F1EA`, ink `#1A1A1A`, one accent signal orange `#E8590C`, muted rule lines `#D6D0C4`.
- Type: display/body a grotesk (e.g. "Inter Tight" or "IBM Plex Sans"), labels/code "IBM Plex Mono" or "JetBrains Mono" (Google Fonts).
- Numbered sections (`01 Infrastructure` …), figure captions (`FIG 03 · ARGO CD · ivolve-dev · tree`), thin rules, generous whitespace, left-aligned text.
- Dark mode via `prefers-color-scheme` (ink background, paper text, same accent).
- Responsive down to 360px, no horizontal scroll; images click-to-open full size.

## Deliverables

### 1. Screenshots → `docs/images/`
Originals moved (renamed) to `docs/images/raw/`; framed versions in `docs/images/`.

| Original | New name | Shows |
| --- | --- | --- |
| Screenshot 2026-11-22 114306.png | vault-setup-script | `setup.sh` output: k8s auth, policy, KV secrets |
| Screenshot 2026-11-22 114932.png | vault-ui-secrets-engines | Vault UI, KV v2 at `secret/` |
| Screenshot 2026-11-22 114946.png | vault-ui-ivolve-secrets | `secret/ivolve/{db,frontend}` |
| Screenshot 2026-11-22 125811.png | jenkins-stage-view | 5 builds, #5 green |
| Screenshot 2026-11-22 131246.png | argocd-dev-network | ivolve-dev network view, Synced |
| Screenshot 2026-11-22 131256.png | argocd-dev-tree | resource tree, deploy build 5 |
| Screenshot 2026-11-22 131305.png | argocd-dev-pods-by-node | pods across 2 nodes |
| namespace ivolve-dev 1.png | grafana-ns-dev-cpu | namespace pods CPU |
| namespace ivolve-dev 2.png | grafana-ns-dev-2 → rename after viewing content | |
| worker node one before/after application.png | grafana-node1-before-after (merged side by side) | |
| worker node two before/after application.png | grafana-node2-before-after (merged side by side) | |

Framing rules: crop browser chrome (address bar, extensions, avatar), keep the tool's own UI; frame = paper background, 1px ink border, soft shadow, mono label strip top with figure number + tool + view. Terminal shot gets a dark terminal frame. Output width ~1600px PNG, optimised (<500 KB each where possible).

### 2. Diagrams → `docs/images/`
- `architecture.png`: git push → Jenkins (build, Trivy scan, push ECR, bump imageTag) → GitHub env branch → Argo CD → EKS namespaces; Vault, monitoring, KMS, ECR shown. Same palette as site.
- `aws-network.png`: VPC 10.0.0.0/16, 2 AZs, public (Jenkins EC2, NAT, LB) / private (EKS nodes) subnets, IGW, regional services.
- SVG sources kept next to them (`*.svg`) for edits.

### 3. README.md (concise; target ≤ ~250 lines)
1. Title, one-line pitch, `architecture.png`, link to site.
2. Stack at a glance (one table).
3. How it flows (5–6 numbered lines: push → build → scan → push → bump tag → Argo sync).
4. Evidence (framed screenshots, 1 line each).
5. Components — one short block each, linking its folder: Terraform (4 modules + state), Ansible (3 roles + dynamic inventory), Jenkins (Jenkinsfile + shared library), Helm chart (workloads, NetworkPolicies, securityContext, limits), Argo CD (3 Applications, promotion model), Vault (KMS auto-unseal, k8s auth, agent injection, secret paths), Monitoring, Application (3 services + MySQL, APIs table).
6. Security & secrets (what stays out of git — compact table).
7. Decisions & lessons (Jenkins never touches cluster; branch-per-env; Trivy report-only trade-off + tmpfs fix).
8. Deploy runbook (compact numbered commands).
9. Repository layout (short tree).

### 4. Site → `docs/index.html` + `docs/site.css`
Sections: hero (pitch + architecture), 01 Infrastructure, 02 Pipeline, 03 GitOps, 04 Secrets, 05 Observability, 06 Running cluster (trimmed `kubectl` output as terminal block), 07 Decisions & what broke, footer (GitHub repo, GitHub profile, LinkedIn `linkedin.com/in/moaz-m-elgendy`). `docs/.nojekyll` so files serve as-is.

## Left to the builder
Exact crops per screenshot, font pairing within the stated direction, diagram layout details, copy wording (plain, specific, first person sparingly).

## User actions after build
Enable Pages: Settings → Pages → Source `main` / `/docs`. Commit + push (Claude does not push unless asked).
