# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A hands-on training course teaching administration of Kubermatic Kubernetes Platform (KKP, **Enterprise Edition**) on top of a KubeOne-provisioned cluster on GCP. It is **not** an application codebase — it is a set of numbered lab directories (`00_prerequisites` … `11_upgrade-kkp`, plus `99_teardown`) whose `README.md` files are the training material. Each README is a sequence of `zsh`/`kubectl`/`yq`/`gcloud`/`kubeone`/`kubermatic-installer` commands the trainee copy-pastes in order.

Three things live alongside the labs:

- `container-image/` — the **trainee environment image is built from this repo** (dockerfile, `welcome.sh`, p10k/VS Code config). This is the only part with a real build.
- `k1/` — KubeOne cluster config (`kubeone.yaml`), Terraform variables (`terraform.tfvars`), and the makefile that provisions the master/seed cluster.
- `kkp/` — the KKP manifests that are committed (`seed.yaml`, `clusterissuer.yaml`, `gcp-preset.yaml`, `training-application.yaml`). `kubermatic.yaml`, `values.yaml` and `charts/` are **not** committed — lab 03 copies them out of the extracted KKP EE release tarball.

## Commands

There is no test suite and no linter for the lab content itself.

**On the host** (building/publishing the trainee image, from `container-image/`):

```bash
make -C container-image lint    # hadolint ./dockerfile
make -C container-image build   # buildx, linux/amd64 + linux/arm64; runs lint first
make -C container-image run     # build, then run the container with the repo mounted at /training
make -C container-image push
```

`make run` publishes code-server on <http://localhost:8080> — that IDE *is* the trainee environment.

**Inside the container** (everything in the labs assumes this):

```bash
make verify                                                   # asserts binaries + env vars + .secrets files
make -C /training/k1/ create-cluster                          # terraform apply -> kubeone apply (lab 01)
kubermatic-installer version --charts-directory /training/kkp/charts   # chart vs. installer version check
```

`kubermatic-installer version` without `--charts-directory` fails, because the flag defaults to `charts/` relative to the current directory. `--short` omits exactly the chart table you usually want.

**Linting the lab prose**: the repo ships a `lab-linter` skill (`.claude/skills/lab-linter/`), invoked with "lab check" / "lint lab". It checks prose only and must not touch versions, placeholders, or `.99_todos/`.

## Execution environment

- **Image**: built from `container-image/dockerfile` (`FROM ubuntu:26.04`), entrypoint `code-server`. Runs as **root**.
- **Shell is zsh**, not bash — oh-my-zsh + powerlevel10k. `/root/.zshrc` sources `/root/.trainingrc`, and every tool install appends its completion and version export to `.trainingrc`. The last line of `.trainingrc` runs `/root/welcome.sh`, which prints the installed tool versions.
- **Workspace mount**: the repo is bind-mounted at `/training/`. Every absolute path in the labs (`/training/k1/...`, `/training/kkp/...`, `/training/.secrets/...`, `/training/kubermatic-ee-$KKP_INSTALLER_VERSION/...`) refers to that mount, **not** to the host path. Do not rewrite these to host paths — they are part of the trainee's literal copy-paste experience.
- **Because the prompt runs as root, zsh's `PROMPT_EOL_MARK` renders as an inverse `#`** after any output lacking a trailing newline (`%#` expands to `#` for uid 0). It is not part of the output. Lab 06 appends `; echo` to the `base64 -w0` step for exactly this reason — a trainee who copies the `#` corrupts the service account.

### Where environment variables come from

| Source | Variables |
| --- | --- |
| `.secrets/environment.sh` (trainer-provided, gitignored) | `GCP_PROJECT`, `TRAINEE_NAME`, `DOMAIN`, `DNS_ZONE_NAME`, `TRAINEE_EMAIL` |
| The image, via `.trainingrc` | `K8S_VERSION`, `TF_VERSION`, `KUBEONE_VERSION`, `YQ_VERSION`, `HELM…`/`KREW…`/`VELERO…`/`GCLOUD…`/`CODE_SERVER_VERSION` |
| Appended by labs | `KKP_INSTALLER_VERSION` (02, then 11), `PULL_CREDENTIALS` (03), `APP_IP` (08) |

`make verify` covers the first group plus the tool binaries. `GOOGLE_CREDENTIALS` — which Terraform needs in lab 01 — is **not** exported by any lab any more and appears in the makefile only as a `# TODO`; it must come from `environment.sh`.

`.secrets/` holds trainer-provided credentials and the SSH keypair generated in lab 00. `.claude/settings.json` denies `Read`/`Glob` on `.secrets/**` — respect it.

### EE pull credentials

`kubermatic.yaml` and `values.yaml` ship with a `<your-auth-token>` placeholder that lab 03 `sed`s to the trainer-supplied `$PULL_CREDENTIALS`. Without it the EE images from `quay.io/kubermatic/*-ee` do not pull.

## Lab flow

The numeric prefix is the order; later labs assume earlier labs' state.

1. `00_prerequisites` — run `.secrets/environment.sh` to write `/root/.trainingrc`, generate the SSH key, activate the GCP service account, `make verify`. No tool installation any more — everything is in the image.
2. `01_create-k1-cluster` — `make -C /training/k1/ create-cluster`; copy the kubeconfig to `/root/.kube/config`; raise the cluster-autoscaler max node count via `k1/md.yaml`.
3. `02_install-kkp-installer` — download the `kubermatic-ee` tarball, put `kubermatic-installer` on `$PATH`. Deliberately *not* the newest version, so lab 11 has something to upgrade.
4. `03_prepare-kkp-master-configuration` — copy `charts/` + the example yamls out of the release into `/training/kkp/`, mutate with `yq`/`sed` (domain, dex/auth secrets, htpasswd hash, telemetry uuid, EE pull token).
5. `04_setup-kkp-master` — `kubermatic-installer deploy`, read the LB IP off the **Envoy Gateway** (`kubectl -n kubermatic get gateway kubermatic`), create GCP DNS A records for `$DOMAIN` and `*.$DOMAIN`, apply the prod LetsEncrypt ClusterIssuer, re-run the installer.
6. `05_setup-kkp-seed` — create the `seed-kubeconfig` secret, apply `kkp/seed.yaml`, add `*.kubermatic.$DOMAIN` DNS pointing at the nodeport-proxy LB, configure minio, `kubermatic-installer deploy kubermatic-seed`.
7. `06_create-user-cluster` — UI-driven user-cluster creation; verify the control plane self-heals on `etcd-0` deletion; scale via `MachineDeployment`.
8. `07_add-system-applications` / `08_add-applications` — enable the cluster-autoscaler system app via UI; apply `kkp/training-application.yaml` (ApplicationDefinition pulling a helm OCI chart from `quay.io/kubermatic-labs/helm-charts`) and start the curl availability loop.
9. `09_upgrade-user-cluster` — upgrade via UI, pin the available versions in `kubermatic.yaml` with `yq`, then upgrade cluster + machinedeployment from the shell while the curl loop proves no downtime.
10. `10_templating` — apply `kkp/gcp-preset.yaml` (base64 SA injected), create a ClusterTemplate via UI.
11. `11_upgrade-kkp` — `yq del(.spec.versions)`, bump `KKP_INSTALLER_VERSION`, re-copy `charts/`, verify with `kubermatic-installer version`, re-run the installer for master and seed.
12. `99_teardown` — `kubectl delete clusters --all`, `kubeone reset` (with `--remove-lb-services --remove-volumes --remove-binaries`), delete DNS records, `terraform destroy`, delete the leftover minio PVC disk.

## Pinned versions — two separate places

**Tooling** lives as `ARG`s in `container-image/dockerfile`: `KUBEONE_VERSION=1.14.3`, `K8S_VERSION=1.36.3` (kubectl), `HELM_VERSION=4.2.4`, `TF_VERSION=1.16.1-1`, `YQ_VERSION=4.53.6`, plus helmfile/krew/velero/gcloud/code-server. The image tag itself is `IMAGE_TAG` in `container-image/makefile`.

**Training content** is inline in the labs and manifests:

| Thing | Current | Location |
| --- | --- | --- |
| KKP installer (initial) | `2.31.0` | `02_install-kkp-installer/README.md` |
| KKP installer (upgrade target) | `2.31.1` | `11_upgrade-kkp/README.md` (+ the release-notes link) |
| Kubernetes for the k1 master/seed cluster | `1.35.4` | `k1/kubeone.yaml` — hardcoded, **not** taken from `$K8S_VERSION` |
| Kubernetes offered to user clusters | `1.35.1`–`1.35.8`, default `1.35.3` | `09_upgrade-user-cluster/README.md` (`yq` block **and** the prose upgrade targets) |
| training-application chart | `1.0.1` | `kkp/training-application.yaml` (`chartVersion` and `version`, both must match) |

The kubectl in the image (1.36.3) is deliberately **ahead** of the cluster (1.35.4) — see the comment at `container-image/dockerfile:60`: a non-latest Kubernetes is required so lab 09 has something to upgrade to.

## KKP 2.31 specifics

nginx-ingress is gone; **Gateway API (Envoy Gateway) is the enforced ingress path**. `kubermatic-installer deploy --help` confirms `--migrate-gateway-api` and `--migrate-upstream-nginx-ingress` are no-ops, and adds `--clean-nginx-lb` / `--skip-ingress-cleanup` for the 2.30→2.31 transition. Consequences already reflected in the labs: lab 04 reads the IP from the `Gateway` resource, and `kkp/clusterissuer.yaml` solves HTTP-01 via `gatewayHTTPRoute` instead of an nginx `ingress` class.

## The k1 provisioning flow (read before touching `k1/`)

`k1/makefile` `prepare-tf-config` does something non-obvious: `kubeone init` scaffolds `/training/k1/tf_infra/`, then the makefile copies the committed `terraform.tfvars` over the generated one, `sed`s in `$GCP_PROJECT` and `${TRAINEE_NAME}-k1-cluster`, and **deletes the generated `tf_infra/kubeone.yaml`** so that the committed `k1/kubeone.yaml` (with the cluster-autoscaler addon and the pinned Kubernetes version) is what `kubeone apply` picks up.

Side effect worth knowing: the `--cluster-name` passed to `kubeone init` (`${TRAINEE_NAME}-cluster`) is discarded; `cluster_name` from `terraform.tfvars` (`${TRAINEE_NAME}-k1-cluster`) names the infrastructure, which is why lab 01 reads `/training/k1/$TRAINEE_NAME-k1-cluster-kubeconfig`.

## Lab authoring conventions

- **One code block per step.** Every fenced block holds a single comment plus its command(s); blocks are split at blank lines so each gets its own copy button in the VS Code preview. Multi-line commands and units that must run together (the `gcloud dns record-sets transaction start … execute` sequence, the minio `yq` group) stay in one block.
- **Callouts are `>**NOTE:**` / `>**IMPORTANT:**` / `>**WARNING:**`**, not GitHub alerts (`> [!WARNING]`). VS Code's built-in markdown preview does not render alerts (microsoft/vscode#240885, closed as *extension-candidate*), and the trainees read the labs in that preview. Keep the `>`-prefix on every line of a callout — a lazy continuation line without it gets absorbed into the blockquote.
- **Mutations use `yq -i` or `sed -i`** against `kkp/` and `k1/`. The committed YAML keeps TODO placeholders (`serviceAccount: TODO`, `email: TODO-STUDENT-EMAIL@…`, `<FILL-IN-YOUR-GCP-PROJECT-ID>`); the lab's mutation step is what fills them in. Don't hardcode values — the placeholder + mutation pattern is what the trainee is meant to see.
- **`yq` must be mikefarah v4.** The labs use `strenv()` and in-place YAML editing. Debian/Ubuntu's `yq` package is kislyuk's Python jq-wrapper, which fails with `-i/--in-place can only be used with -y/-Y/-t/-x`, does not know `strenv()`, and destroys comments via a JSON round-trip. The dockerfile therefore installs the Go binary directly. Also note `strenv()` silently yields `""` when the variable is set but not **exported**.
- **Inline `<FILL-IN-…>` and `XXXXX` placeholders** are deliberate — the trainee substitutes the real value. Keep them.
- **Don't reorder commands within a lab** — order encodes a teaching narrative (lab 04 deploys before DNS exists so the trainee sees `kubermatic-api` fail, then fixes it).
- **Verification idiom**: sections end with `watch -n 1 kubectl … get pods` or a `dig +short`. Preserve it; trainees rely on it to know when to proceed.
- **Secrets in commands**: per commit `a713771`, never echo passwords or secret values into `bash -c` or anything else that exposes them in the process list. Use file redirection or stdin (see the `htpasswd` line in lab 03).

## Known inconsistencies

Verified in the current tree; fix deliberately rather than assuming one of them is authoritative.

- **`container-image/dockerfile` installs yq twice** — lines 39-44 and 110-115 are byte-identical blocks.
- **Three disagreeing image references**: `container-image/makefile:1` omits the `kubermatic-labs/` path segment; `README.md:25` has the registry prefix doubled *and* a space before `:2.0.0`; `.devcontainer/devcontainer.json:3` still pins `:1.0.0`.
- **`.devcontainer/` is stale** relative to the switch to a locally-run image — it also still sets `terminal.integrated.shell.linux: /bin/bash` although the image uses zsh.
- `container-image/dockerfile:118` — `curl -sfL https://get.kubeone.io | sh` ignores `ARG KUBEONE_VERSION`, so `$KUBEONE_VERSION` in `.trainingrc` can disagree with the installed binary. (`welcome.sh` queries the binary, not the variable, for this reason.)
- `container-image/dockerfile:34` — trailing whitespace after the line-continuation backslash.
- `.gitignore` lines 3-8 still reference `kubeone/tf_infra/`, which does not exist; `k1/tf_infra/` is covered separately on line 11.
- A tracked, empty `todos.md` sits at the repo root, separate from `.99_todos/todos.md`.

## Author-only / out of scope

`.99_todos/` holds stub READMEs for unfinished labs (oauth, master/seed/MLA split) plus `todos.md` and `gotchas.md`. Not part of the trainee path; hidden from the VS Code file tree via `files.exclude`. The `lab-linter` skill is explicitly forbidden from reading it.

Don't run `make verify` from a host shell — it expects to be inside the trainee container. Don't try to bring up the actual KKP stack from this repo unless you genuinely have GCP credentials, an EE pull token, a DNS zone, and intend to incur cloud costs.
