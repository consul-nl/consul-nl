# Deploying a Consul instance

## TODO: explain about creating and applying tenants

Make sure correct ssh certificate is loaded:

```bash
eval "$(ssh-agent -s)"

ssh-add ~/.ssh/{key_name}
```

Deploy the consul instance using the deploy.sh script:

```bash
sh deploy.sh [-p] {tenant_name}
```

where the `-p` flag denotes that you're deploying to production.
