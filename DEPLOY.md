# Deploying a Consul instance

This repo deploys via Capistrano, wrapped by `deploy.sh`. Deploys are tenant-aware: before deploying, the script overlays tenant-specific config/customizations from `tenants/` into the repo working tree.

## Quick start

1. Ensure your SSH key/certificate is loaded (for the target host and for any private git repo access):

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/{key_name}
```

2. Run a deploy:

```bash
sh deploy.sh [-p] <tenant>
```

- Without `-p`, deploys to **staging** and loads `.env.<tenant>`.
- With `-p`, deploys to **production** and loads `.env.production.<tenant>`.

## What `deploy.sh` does

Given `<tenant>`, the script performs the following steps:

1. Picks the env file:
   - staging: `.env.<tenant>`
   - production: `.env.production.<tenant>`

2. Exports variables from that env file into the current shell, using `grep ... | xargs`.

3. Applies tenant overlays via `bin/tenant -a <tenant>`.

4. Generates `config/deploy-secrets.yml` from `config/deploy-secrets.yml.example`:
   - replaces `xxx.xxx.xxx.xxx` with `$HOST`
   - replaces `user: "deploy"` with `user: "$ANSIBLE_USER"`

5. Runs Capistrano:
   - staging: `cap staging deploy --trace`
   - production: `cap production deploy --trace`

6. Ensures `delayed_job` systemd units are installed/reloaded:
   - `cap <env> delayed_job:install_systemd`
   - `cap <env> delayed_job:systemd_reload`

## Tenants (`bin/tenant`)

Tenant application is implemented in `bin/tenant`.

### Apply flow

`bin/tenant -a <tenant>` overlays files from:

- `tenants/base/` (applied first)
- `tenants/<tenant>/` (applied second, as overrides)

…into the repo root (one directory above `bin/tenant`).

Important behavior details:

- The “base” pass uses `clear: true`, meaning destination paths for matching entries are removed before copying.
- The tenant-specific pass uses `clear: false`, so it only overlays/overwrites what it copies.
- Copy selection is special:
  - All files in the tenant tree are copied.
  - Directories are only copied when the directory name is `custom`.
  - The script then recurses into subdirectories (so `custom/` directories can exist at multiple depths).

This means the tenant mechanism is mainly for overriding/adding “custom” assets/config and specific config files shipped in the tenant directories.

### Creating/updating tenants

Tenant directories live under `tenants/` (for example: `tenants/fryslan`, `tenants/leeuwarden`, etc.).

- To create a new tenant, the expected layout is `tenants/<name>/`.
- You can start by copying from `tenants/base/` and then removing anything you don’t want to override.

Note: `bin/tenant --init <name>` currently creates `tenant/<name>` (singular), but `--apply` looks for `tenants/<name>` (plural). In practice, deployments use `--apply` and expect tenant directories under `tenants/`.

## Required env vars

`deploy.sh` expects at least the following to be set in the chosen `.env...` file:

- `HOST`: server IP/hostname used when generating `config/deploy-secrets.yml`
- `ANSIBLE_USER`: SSH user written into `config/deploy-secrets.yml`

It also prints `$REPO` and `$branch`, so those are commonly present as well (and may be used by Capistrano config depending on your setup).

## Notes

- `bin/tenant -a <tenant>` modifies files in your working tree. Run deploys from a clean git state so it’s obvious what changed, and avoid committing generated files like `config/deploy-secrets.yml`.
