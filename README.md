# [customUserAdd.sh](https://github.com/concrete-aecio-barreto-junior/customUserAdd/blob/master/customUserAdd.sh)

## Description

Script for adding users with customized access with secure config files handling.

## Operation/workflow

1. Useradd
	- Check if user already exist else add;
	- Set a initial password;
	
2. SSH config
	- Check if user's into "sshd.config" file, else add;
	- Restart SSH daemon;

3. Sudoers
	- Check if user's into "sudoers" file, else add;

## Usage

Running on remote host:

```
ssh -p22 -T sshuser@IP address < ./customUserAdd.sh username
```

## Notes

This script:

* ... considers return codes to assure right flow;
* ... check file contents before change it;
* ... script do backup files before handle it;
* ... script assure secure attributes about files (chattr);
