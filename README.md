# Permanent `rclone` IaC

IaC for [Permanent](https://permanent.org) [rclone](https://github.com/PermanentOrg/Sftp-service) QA.

## Setup

- `git clone git@github.com:OpenTechStrategies/permanent-rclone-iac.git`
    - OR `git clone https://github.com/OpenTechStrategies/permanent-rclone-iac.git`
- `cd rclone-iac`
- `cp rclone.conf.example rclone.conf`
- `terraform init`

### Getting `rclone.conf` credentials

`rclone` is usually configured interactively. To make this automated infrastructure simple we use defaulted to copying an existing ready-made configuration file to test machines instead of configuring them one after the other or taking more complex routes.

This means:

- You have to [install rclone](https://rclone.org/install/) on a secured machine (Ideally the host from which this IaC is run)
- Configure the [permanent remotes](https://rclone.org/remote_setup/) see [Running rclone against Permanent.org instances](https://github.com/permanentOrg/sftp-service/#running-rclone-against-permanentorg-instances) for more detailed information if any confusion arises.
- Replace the contents of `rclone.conf` with the content of your local configuration from `~/.config/rclone/rclone.conf`
### SSH Access

To be able to `ssh` into the created instances with your existing ssh-key pass the public part as described below.

Run `export TF_VAR_PUBLIC_KEY=~/.ssh/id_rsa.pub` you can also pass a custom path for example  `export TF_VAR_PUBLIC_KEY=custom/path/to/pubkey.pub`

We also use [terraform provisioners](). This means a private key is needed by the provision to connect and execute the provision instructions hence pass the private part of your ssh-key as described below.

Run `export TF_VAR_PRIVATE_KEY=~/.ssh/id_rsa` you can also pass a custom path for example `export TF_VAR_PRIVATE_KEY=custom/path/to/privkey`

---
- `terraform plan`

If everything looks good

- `terraform apply`