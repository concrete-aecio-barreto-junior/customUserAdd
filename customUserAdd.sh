#!/bin/bash
 
# Titulo        : "CustomUserAdd.sh"
# Descricao     : Este script garante a adicao segura de usuarios: 
#                    1. Cria usuario
#                    2. Acrescenta ao sudoers
#                    3. Autoriza no sshd.conf
# Autor         : Aecio Junior <aecio.barreto.junior@concrete.com.br>
# Data          : Fri Feb  2 12:49:13 EST 2018
# Versao        : v1.0
# Data          : Fri Feb 16 14:17:26 EST 2018 
# Versao        : v1.1
# Usage         : ssh -p22 -T sshuser@endereco.IP < ./CustomUserAdd.sh username
 
##----------------- Variaveis -----------------##
 
## Usuario a ser cadastrado.
Usuario="$1"

## Referencias de usuarios contidos no sudoers
UserRef1="fulano"
UserRef2="ciclano"
UserRef3="beltrano"

##------------------ Funcoes ------------------##
## Funcao para verificar existencia de um dado usuario
_VerificaUsuario(){
   local RC=0
   local Usuario=$1
   id $Usuario || local RC=$?
   return $RC
}
 
## Funcao para cadastrar usuario
_AdicionaUsuario(){
   local RC=0
   local Usuario=$1
   local Comentario="User added by `basename $0`"
   local DirHome=/home/$Usuario
   local Shell="/bin/bash"
   sudo /usr/sbin/useradd --create-home --comment "$Comentario" --home "$DirHome" --shell "$Shell" $Usuario || local RC=$?
   return $RC
}
 
## Atualiza senha do usuario para senha inicial padrao
## Solicitar troca de senha no primeiro acesso;
_AtualizaSenha(){
   local RC=0
   local Usuario=$1
   local SenhaInicial='p@ssw0rd'
   echo "$Usuario:$SenhaInicial" | sudo /usr/sbin/chpasswd || local RC=$?
   return $RC
}
 
## Verifica se o acesso ssh esta autorizado para dado usuario
_VerificaSSH(){
   local RC=0
   local Usuario=$1
   sudo grep -E "^AllowUsers.*$Usuario" /etc/ssh/sshd_config || local RC=$?
   return $RC
}
 
## Realiza backup de arquivo de configuracao fornecido como argumento
_BackupArquivoConfiguracao(){
   local RC=0
   local Arquivo=$1
   sudo cp -Rfa $Arquivo{,.`date "+%Y%m%d-%H%M"`} || local RC=$?
   return $RC
}
 
## Acrescenta usuario no arq. config. do SSH autorizando acesso
_AutorizarSSH(){
   local RC=0
   local Usuario=$1
   sudo sed -i "/^AllowUsers/s/.*/& $Usuario/" /etc/ssh/sshd_config || local RC=$?
   return $RC
}
 
## Reinicia o ssh daemon
_ReiniciarSSH(){
   local RC=0
 
   { sudo test -f /etc/init.d/ssh && sudo /etc/init.d/ssh restart; } || \
   { sudo test -f /etc/init.d/sshd && sudo /etc/init.d/sshd restart; } || \
   local RC=$?
 
   return $RC
}
 
## Verifica se dado usuario encontra-se no sudo
_VerificaSUDO(){
   local RC=0
   local Usuario=$1
   sudo grep -E -e "$UserRef1.*$1" -e "$UserRef2.*$1" -e "$UserRef3.*$1" /etc/sudoers || local RC=$?
   return $RC
}
 
## Acrescenta usuario CIT no sudoers
_AutorizarSUDO(){
   local RC=0
   local Usuario=$1
   sudo sed -i "/$UserRef1\|$UserRef2\|$UserRef3/s/.*/&,$Usuario/" /etc/sudoers || local RC=$?
   return $RC
}
 
## Muda atributos de bit imutavel (on/off)
_MudaAtributos(){
 
   local RC=0
   local ST="$1"
   if [ "$ST" == "on" ]; then
      local State='+i'
   elif [ "$ST" == "off" ]; then
      local State='-i'
   fi
 
   sudo chattr $State /etc/ssh/sshd_config || local RC=$?
   sudo chattr $State /etc/sudoers || local RC=$?
   sudo chattr $State /etc/passwd || local RC=$?
   sudo chattr $State /etc/shadow || local RC=$?
   sudo chattr $State /etc/gshadow || local RC=$?
   sudo chattr $State /etc/group || local RC=$?
 
   return $RC
}

_FuncionUsage(){
    echo -e "Usage: \n\t CustomUserAdd.sh [username|--help|-U]"
    return 2 
}

##------------------- Inicio do Script --------------------#

if [ $# -eq 1 ]; then
   if [ "$1" == "--usage" -o "$1" == "-U" ]; then
      _FuncionUsage
   else

      ### Desativa bit imutavel
      sudo test -f /root/unlock && sudo /root/unlock || { _MudaAtributos off || echo erro desativando atributos; }
 
      ### Verifica se o usuario existe, do contrario, adicionar.
      if _VerificaUsuario $Usuario
      then
         echo Usuario ja cadastrado
      else
         if _AdicionaUsuario $Usuario
         then
            echo usuario adicionado com sucesso
            if _AtualizaSenha $Usuario
            then
               echo senha atualizada conforme padrao inicial
            else
               echo erro na atualizacao da senha. fazer manualemnte
            fi
         else
            echo erro no cadastro do usuario
         fi
      fi
 
      ### Verifica se o acesso ssh esta autorizado ao usuario, senão, autorizar.
      if _VerificaSSH $Usuario
      then
         if _ReiniciarSSH
         then
            echo ssh daemon reinciado por precaucao
         else
            echo erro reiniciando ssh
         fi
      else
         if _BackupArquivoConfiguracao /etc/ssh/sshd_config
         then
            if _AutorizarSSH $Usuario
            then
               echo usuario adicionado no ssh
               if _ReiniciarSSH
               then
                  echo ssh reinciado apos adicao de usuario na configuracao
               else
                  echo problemas reinciando ssh
               fi
            else
               echo erro autorizando ssh
            fi
         else
            echo erro backupeando arquivo de configuracao /etc/ssh/sshd_config
         fi
      fi
 
      ### Verifica se o usuario esta no sudosh, senão, adicionar.
      if _VerificaSUDO $Usuario
      then
         echo Usuario ja cadastrado no sudo
      else
         if _BackupArquivoConfiguracao /etc/sudoers
         then
            echo arquivo sudoers backupeado
            if _AutorizarSUDO $Usuario
            then
               echo sudo autorizado
            else
               echo erro autorizando o sudo
            fi
         else
            echo erro no backup do arquivo
         fi
      fi
 
      ### Ativa bit imutavel
      sudo test -f /root/lock && sudo /root/lock || { _MudaAtributos on || echo erro ativando atributos; }
   fi
else
   _FuncionUsage
fi

#-------------------- Fim do Script --------------------#
