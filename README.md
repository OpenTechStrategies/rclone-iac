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
### SSH access

To be able to `ssh` into the created instances with your existing ssh-key pass the public part as described below.

Run `export TF_VAR_PUBLIC_KEY=~/.ssh/id_rsa.pub` you can also pass a custom path for example  `export TF_VAR_PUBLIC_KEY=custom/path/to/pubkey.pub`

We also use [terraform provisioners](). This means a private key is needed by the provision to connect and execute the provision instructions hence pass the private part of your ssh-key as described below.

Run `export TF_VAR_PRIVATE_KEY=~/.ssh/id_rsa` you can also pass a custom path for example `export TF_VAR_PRIVATE_KEY=custom/path/to/privkey`


### Customizing provision script

`local-provision` local provision is just a bash that is not tracked where one can customize the provision process even more by adding more stuff. Anything (bash code) added to the `local-provision` script would be executed during the provisioning of the machines.

## Schedule cron jobs

It is possible to add test-commands from the [qa-repo](https://github.com/permanentOrg/sftp-qa) for uploading and downloading to a custom cron schedule by editing the `local-provision` script.

For example adding more test commands or changing when the crons run, see part of `local-provision` script that looks like;

```
echo "00 14 * * * ~/permanent-rclone-qa/upload-test.py ~/permanent-rclone-qa/test-tree/special-files/1000-1B --remote-dir=1000-10B-$(hostname)-parallel --log-file=log-1000-1B-$(hostname).txt --remote=dev --archive-path='/archives/rclone QA 1 (dev) (07av-0000)/My Files/'" >> uploadcron
```


Do:

- `cp local-provision.example local-provision` (to have the sample cron and test commands)



### Change number of machines

The default number of machines that would be created is 1.

Run `export TF_VAR_NUMBER_OF_MACHINES=5` (This example sets the number of machines to 5.)

---
- `terraform plan`

If everything looks good

- `terraform apply`