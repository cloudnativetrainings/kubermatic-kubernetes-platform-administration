# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A hands-on training course teaching administration of Kubermatic Kubernetes Platform (KKP, **Enterprise Edition**) on top of a KubeOne-provisioned cluster on GCP. It is **not** an application codebase — it is a set of numbered lab directories (`00_prerequisites` … `11_upgrade-kkp`, plus `99_teardown`) whose `README.md` files are the training material. Each README is a sequence of `bash`/`kubectl`/`yq`/`gcloud`/`kubeone`/`kubermatic-installer` commands that the trainee copy-pastes in order.

The shared YAML templates and Terraform variables that the labs mutate live in:

- `k1/` — KubeOne cluster config (`kubeone.yaml`), Terraform variables (`terraform.tfvars`), and the makefile that drives provisioning of the master/seed cluster
- `kkp/` — KKP manifests committed here (`seed.yaml`, `clusterissuer.yaml`, `gcp-preset.yaml`, `training-application.yaml`). `kubermatic.yaml`, `values.yaml` and `charts/` are **not** committed — lab 03 copies them out of the extracted KKP EE release tarball.

The top-level `makefile` only defines a `verify` target that asserts the trainee's environment is set up (binaries present, env vars exported, secret files in place). `k1/makefile` wraps the `terraform` + `kubeone apply` flow used in lab 01; lab 99 tears the cluster down directly via `kubeone reset` + `terraform destroy` rather than through that makefile.

## Execution environment — important

Lab commands assume an exact runtime that does not exist on a developer's host machine:

- **Devcontainer image**: `quay.io/kubermatic-labs/training-ghcs-kubermatic-kubernetes-platform-administration-trainee-environment:1.0.0` (see `.devcontainer/devcontainer.json`). Designed for GitHub Codespaces; `remoteUser` is `root`.
- **Workspace mount**: the repo is bind-mounted at `/training/` inside the container. Every absolute path in the labs (`/training/k1/...`, `/training/kkp/...`, `/training/.secrets/...`, `/training/kubermatic-ee-$KKP_INSTALLER_VERSION/...`) refers to that mount, **not** to the host path. Do not rewrite these paths to host paths — they are part of the trainee's literal copy-paste experience.
- **Trainer-provided files** dropped into `/training/.secrets/` (gitignored) at the start of lab 00: `environment.sh`, `README.md`, `gcloud-service-account.json`. Running `environment.sh` is what writes `/root/.trainingrc`; the SSH keypair `gcp` / `gcp.pub` is *generated* later in lab 00, not provided.
- **Env vars** live in `/root/.trainingrc`, appended to across several labs and re-`source`d each time. From `environment.sh`: `GCP_PROJECT`, `TRAINEE_NAME`, `DOMAIN`, `DNS_ZONE_NAME`, `K8S_VERSION`, `TF_VERSION`. Added by later labs: `GOOGLE_CREDENTIALS` (lab 00), `K1_VERSION` (lab 00), `KKP_INSTALLER_VERSION` (labs 02 and 11), `PULL_CREDENTIALS` (lab 03), `APP_IP` (lab 08). `make verify` enforces only the lab-00 subset.
- **EE pull credentials**: `kubermatic.yaml` and `values.yaml` ship with a `<your-auth-token>` placeholder that lab 03 `sed`s to the trainer-supplied `$PULL_CREDENTIALS`. Without it the EE images from `quay.io/kubermatic/*-ee` will not pull.

The `.claude/settings.json` denies `Read`/`Glob` of `.secrets/**` — respect that, do not try to read service-account JSON, SSH keys, or `environment.sh`.

## Lab flow at a glance

The numeric prefix is the order; later labs assume earlier labs' state:

1. `00_prerequisites` — run `.secrets/environment.sh` to write `/root/.trainingrc`, generate the SSH key, activate the GCP service account, install `kubeone`, run `make verify`.
2. `01_create-k1-cluster` — `make -C /training/k1/ create-cluster` (terraform apply → `kubeone apply`); copy resulting kubeconfig to `/root/.kube/config`; raise the cluster-autoscaler max node count via `k1/md.yaml`.
3. `02_install-kkp-installer` — download the `kubermatic-ee` release tarball and put `kubermatic-installer` on `$PATH`. Deliberately *not* the newest version, so lab 11 has something to upgrade.
4. `03_prepare-kkp-master-configuration` — copy `charts/` + the example yamls out of the release into `/training/kkp/`, mutate them with `yq`/`sed` (domain, dex/auth secrets, htpasswd hash, telemetry uuid, EE pull token).
5. `04_setup-kkp-master` — `kubermatic-installer deploy` master, create GCP DNS A records for `$DOMAIN` and `*.$DOMAIN`, switch from staging to prod LetsEncrypt and re-run the installer.
6. `05_setup-kkp-seed` — create the `seed-kubeconfig` secret, apply `kkp/seed.yaml`, add `*.kubermatic.$DOMAIN` DNS pointing at the nodeport-proxy LB, configure minio, run `kubermatic-installer deploy kubermatic-seed`.
7. `06_create-user-cluster` — UI-driven user-cluster creation; verify the control plane self-heals on `etcd-0` deletion; scale via `MachineDeployment`.
8. `07_add-system-applications` / `08_add-applications` — enable the cluster-autoscaler system app via UI; apply `kkp/training-application.yaml` (ApplicationDefinition pulling a helm OCI chart from `quay.io/kubermatic-labs/helm-charts`) and start the curl availability loop.
9. `09_upgrade-user-cluster` — upgrade via UI, then pin the available versions in `kubermatic.yaml` via `yq`, then upgrade cluster + machinedeployment from bash while the curl loop proves no downtime.
10. `10_templating` — apply `kkp/gcp-preset.yaml` (with base64 SA injected), create a ClusterTemplate via UI.
11. `11_upgrade-kkp` — remove the pinned `spec.versions` block from `kubermatic.yaml` (`yq del`), bump `KKP_INSTALLER_VERSION`, re-copy `charts/`, re-run the installer for master and seed.
12. `99_teardown` — `kubectl delete clusters --all`, `kubeone reset` (with `--remove-lb-services --remove-volumes --remove-binaries`), delete DNS records, `terraform destroy`, delete the leftover minio PVC disk.

## Pinned versions and where they live

There is no central version file — every version is inline. When bumping, touch all of these:

| Thing | Current | Location |
| --- | --- | --- |
| KubeOne | `1.13.5` | `00_prerequisites/README.md` (`K1_VERSION=`) |
| KKP installer (initial) | `2.30.4` | `02_install-kkp-installer/README.md` |
| KKP installer (upgrade target) | `2.30.5` | `11_upgrade-kkp/README.md` |
| Kubernetes for the k1 master/seed cluster | `1.35.4` | `k1/kubeone.yaml` — hardcoded, **not** taken from `$K8S_VERSION` |
| Kubernetes offered to user clusters | `1.35.1`–`1.35.4`, default `1.35.3` | `09_upgrade-user-cluster/README.md` (`yq` block **and** the prose upgrade target) |
| training-application chart | `1.0.1` | `kkp/training-application.yaml` (`chartVersion` and `version`, both must match) |
| Trainee container image | `1.0.0` | `.devcontainer/devcontainer.json` |

`K8S_VERSION` and `TF_VERSION` come from the trainer's `environment.sh` and are only asserted by `make verify`; they are not consumed by any lab command.

## The k1 provisioning flow (read before touching `k1/`)

`k1/makefile` `prepare-tf-config` does something non-obvious: `kubeone init` scaffolds `/training/k1/tf_infra/`, then the makefile copies the committed `terraform.tfvars` over the generated one, `sed`s in `$GCP_PROJECT` and `${TRAINEE_NAME}-k1-cluster`, and **deletes the generated `tf_infra/kubeone.yaml`** so that the committed `k1/kubeone.yaml` (with the cluster-autoscaler addon and the pinned k8s version) is the one `kubeone apply` picks up.

Two consequences worth knowing:

- The `--cluster-name` passed to `kubeone init` (`${TRAINEE_NAME}-cluster`) is discarded; `cluster_name` from `terraform.tfvars` (`${TRAINEE_NAME}-k1-cluster`) is what actually names the infrastructure, which is why lab 01 reads `/training/k1/$TRAINEE_NAME-k1-cluster-kubeconfig`.
- `.gitignore` still lists `kubeone/tf_infra/**`, but the directory is actually generated at `k1/tf_infra/`. Terraform state, `.tf` files and the kubeconfig produced by lab 01 are therefore **not** ignored. Never `git add -A` from a run-through; commit named paths.

## When editing labs — conventions to preserve

- **Mutations are done with `yq -i` or `sed -i`** against the files in `kkp/` and `k1/`. The committed YAML files contain TODO placeholders (e.g. `serviceAccount: TODO` in `gcp-preset.yaml`, `email: TODO-STUDENT-EMAIL@cloud-native.training` in `clusterissuer.yaml`, `<FILL-IN-YOUR-GCP-PROJECT-ID>` in `terraform.tfvars`); the lab's `yq`/`sed` step is what fills them in. Don't "fix" placeholders by hardcoding values — the placeholder + mutation pattern is intentional so trainees see what they're customising.
- **Inline `<FILL-IN-...>` and `XXXXX` placeholders** (e.g. `cluster-XXXXX`, `kubeconfig-admin-XXXXX`, `pvc-XXXXX`, `<FILL-IN-YOUR-MAIL-ADDRESS>`) are deliberate — the trainee substitutes the real value. Keep them.
- **Don't reorder commands within a lab** — order encodes a teaching narrative (e.g. lab 04 intentionally deploys with staging certs first, shows `kubermatic-api` failing without DNS, then switches to prod to demonstrate the `certificateIssuer` switchover).
- **Verification idiom**: most sections end with a `watch -n 1 kubectl ... get pods` or similar. Preserve it; trainees rely on it to know when to proceed. So are the `>**NOTE:**` / `>**IMPORTANT:**` blockquote callouts that set expectations about timing.
- The `kubermatic.yaml` flow uses `kubermatic-installer deploy` for master/seed setup and `kubectl apply -f kubermatic.yaml` for incremental config tweaks afterwards (labs 09 and 11). Both forms appear deliberately.
- **Secrets in commands**: per commit `a713771`, do not echo passwords or secret values into `bash -c` invocations or other forms that would expose them in the process list. Use file redirection / env-var-with-stdin forms instead (see the `htpasswd` line in lab 03).

## Author-only directories

Not part of the trainee path — the leading dot hides them from the VS Code file tree via `files.exclude` in `.devcontainer/devcontainer.json`:

- `.99_todos/` — stub READMEs for unfinished labs (oauth, master/seed/MLA split) plus `todos.md`.
- `.99_stuff/gotchas.md`, `.99_attendees/` — untracked, local to the maintainer. `.99_attendees/` holds per-workshop attendee credentials; treat it like `.secrets/` and do not read or commit it.

`.claude/skills/lab-linter/` is a prose-only spellcheck skill for the lab READMEs (invoked with "lab check" / "lint lab"); its constraints mirror the conventions above.

## Out of scope

There is no build, no test suite, no linter. Don't run `make verify` from a host shell — it expects to be inside the trainee container. Don't try to spin up the actual KKP stack from this repo unless you genuinely have GCP credentials, an EE pull token, a DNS zone, and intend to incur cloud costs.
