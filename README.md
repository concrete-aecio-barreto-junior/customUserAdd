# [customUserAdd.sh](https://github.com/concrete-aecio-barreto-junior/customUserAdd/blob/master/customUserAdd.sh)

## Description

Script for adding users with customized access with secure config files handling.

## Operation/workflow

## 1. Useradd
> if _VerificaUsuario $Usuario
	>> echo Usuario ja cadastrado
> else
	>> if _AdicionaUsuario $Usuario
			>>> echo usuario adicionado com sucesso
			>>> if _AtualizaSenha $Usuario
				 >>>> echo senha atualizada conforme padrao inicial
			>>> else
				 >>>> echo erro na atualizacao da senha. fazer manualemnte
			>>> fi
	 >> else
			>>> echo erro no cadastro do usuario
	 >> fi
> fi

## 2. SSH config

## 3. Sudoers





	- Check if user already exist else add;
		 - Set a initial password;
		 _Security files `/etc/sudoers`, `/etc/ssh/sshd_config` are kept logged and backed up_





		 >> - Check if user's into `sshd.config` file, else add;
	 	>> - Restart SSH daemon;

		>> - Check if user's into `sudoers` file, else add;


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
