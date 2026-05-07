# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A hands-on training course teaching administration of Kubermatic Kubernetes Platform (KKP) on top of a KubeOne-provisioned cluster on GCE. It is **not** an application codebase — it is a set of numbered lab directories (`00_prerequisites` … `11_upgrade-kkp`, plus `99_teardown`) whose `README.md` files are the training material. Each README is a sequence of `bash`/`kubectl`/`yq`/`gcloud`/`kubeone`/`kubermatic-installer` commands that the trainee copy-pastes in order.

The shared YAML templates and Terraform variables that the labs mutate live in:
- `k1/` — KubeOne cluster config + Terraform infra (the master/seed cluster)
- `kkp/` — KKP manifests (`kubermatic.yaml`, `values.yaml`, `seed.yaml`, `clusterissuer.yaml`, `gce-preset.yaml`, `training-application.yaml`)

The top-level `makefile` only defines a `verify` target that asserts the trainee's environment is set up (binaries present, env vars exported, secret files in place). `k1/makefile` wraps the `terraform` + `kubeone apply` flow used in lab 01.

## Execution environment — important

Lab commands assume an exact runtime that does not exist on a developer's host machine:

- **Devcontainer image**: `quay.io/kubermatic-labs/training-ghcs-kubermatic-kubernetes-platform-administration-trainee-environment:1.0.0` (see `.devcontainer/devcontainer.json`). Designed for GitHub Codespaces; `remoteUser` is `root`.
- **Workspace mount**: the repo is bind-mounted at `/training/` inside the container. Every absolute path in the labs (`/training/k1/...`, `/training/kkp/...`, `/training/.secrets/...`, `/training/kubermatic-ce-$KKP_INSTALLER_VERSION/...`) refers to that mount, **not** to the host path. Do not rewrite these paths to host paths — they are part of the trainee's literal copy-paste experience.
- **Required env vars** (sourced from `/root/.trainingrc`, set up in lab 00): `GCE_PROJECT`, `TRAINEE_NAME`, `DOMAIN`, `DNS_ZONE_NAME`, `K8S_VERSION`, `TF_VERSION`, `K1_VERSION`, `KKP_INSTALLER_VERSION`, `GOOGLE_CREDENTIALS`. The `make verify` target enforces these.
- **Required secrets** (gitignored, in `/training/.secrets/`): `gce` / `gce.pub` (SSH keypair for KubeOne to reach nodes), `gcloud-service-account.json` (GCE service account JSON, also exported via `GOOGLE_CREDENTIALS`).
- **Tool versions are pinned in the lab text**: `K1_VERSION=1.11.1`, `KKP_INSTALLER_VERSION=2.28.1` (then upgraded to `2.28.2` in lab 11), Kubernetes `1.32.4` → `1.32.6` → `1.33.2`. These exact strings appear inline in the READMEs.

The `.claude/settings.json` denies `Read`/`Glob` of `.secrets/**` — respect that, do not try to read service-account JSON or SSH keys.

## Lab flow at a glance

The numeric prefix is the order; later labs assume earlier labs' state:

1. `00_prerequisites` — install `kubeone`, configure `gcloud`, generate SSH key, write `/root/.trainingrc`, run `make verify`.
2. `01_create-k1-cluster` — `make -C /training/k1/ create-cluster` (terraform apply → `kubeone apply`); copy resulting kubeconfig to `/root/.kube/config`.
3. `02_install-kkp-installer` — download the `kubermatic-installer` binary.
4. `03_prepare-kkp-master-configuration` — copy chart dir + example yamls into `/training/kkp/`, mutate them with `yq`/`sed` (domain, secrets, htpasswd hash, telemetry uuid).
5. `04_setup-kkp-master` — `kubermatic-installer deploy` master, create GCE DNS A records for `$DOMAIN` and `*.$DOMAIN`, switch from staging to prod LetsEncrypt and re-run installer.
6. `05_setup-kkp-seed` — create `seed-kubeconfig` secret, apply `kkp/seed.yaml`, add `*.kubermatic.$DOMAIN` DNS, configure minio, run `kubermatic-installer deploy kubermatic-seed`.
7. `06_create-user-cluster` — UI-driven user-cluster creation; verify control-plane self-heals on `etcd-0` deletion; scale via `MachineDeployment`.
8. `07_add-system-applications` / `08_add-applications` — enable cluster-autoscaler system app; apply `kkp/training-application.yaml` ApplicationDefinition (helm OCI chart from `quay.io/kubermatic-labs/helm-charts`).
9. `09_upgrade-user-cluster` — pin available versions in `kubermatic.yaml` via `yq`, then upgrade cluster + machinedeployment.
10. `10_templating` — apply `kkp/gce-preset.yaml` (with base64 SA injected), create ClusterTemplate via UI.
11. `11_upgrade-kkp` — bump `KKP_INSTALLER_VERSION` to 2.28.2, re-run installer for master and seed.
12. `99_teardown` — `kubectl delete clusters --all`, `kubeone reset`, delete DNS records, `terraform destroy`, delete leftover minio PVC disk.

`.99_todos/` contains stub READMEs for unfinished labs (oauth, master/seed/MLA split) — these are author notes, not part of the trainee path. The leading dot hides them from the VS Code file tree (`.devcontainer/devcontainer.json` `files.exclude`).

## When editing labs — conventions to preserve

- **Mutations are done with `yq -i` or `sed -i`** against the files in `kkp/` and `k1/`. The committed YAML files contain TODO placeholders (e.g. `serviceAccount: TODO` in `gce-preset.yaml`, `email: TODO-STUDENT-EMAIL@cloud-native.training` in `clusterissuer.yaml`); the lab's `yq`/`sed` step is what fills them in. Don't "fix" placeholders by hardcoding values — the placeholder + mutation pattern is intentional so trainees see what they're customising.
- **Hardcoded `XXXXX` placeholders** (e.g. `cluster-XXXXX`, `kubeconfig-admin-XXXXX`, `pvc-XXXXX`) are deliberate — the trainee substitutes the real id. Keep them as `XXXXX`.
- **Don't reorder commands within a lab** — order encodes a teaching narrative (e.g. lab 04 intentionally deploys with staging certs first, fails, then switches to prod to demonstrate `certificateIssuer` switchover).
- **Verification idiom**: most labs end with a `watch -n 1 kubectl ... get pods` or similar. Preserve it; trainees rely on it to know when to proceed.
- The `kubermatic.yaml` flow uses `kubermatic-installer deploy` for master setup and `kubectl apply -f kubermatic.yaml` for incremental config tweaks afterwards (e.g. lab 09 versions list). Both forms appear deliberately.
- **Secrets in commits**: per commit `a713771`, do not echo passwords or secret values into `bash -c` invocations or other forms that would expose them in the process list. Use file redirection / env-var-with-stdin forms instead.

## Out of scope

There is no build, no test suite, no linter. Don't run `make verify` from a host shell — it expects to be inside the trainee container. Don't try to spin up the actual KKP stack from this repo unless you genuinely have GCE credentials, a DNS zone, and intend to incur cloud costs.
