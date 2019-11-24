#/bin/bash


# Notes of commands ran while trying to set git up on IBMi
# Reference:    https://www.itjungle.com/2015/03/03/fhg030315-story03/


# Install git through yum
/QOpenSys/pkgs/bin/yum install git.ppc64


# Find where it was installed, if needed
find /QOpenSys -name "git" 2> /dev/null


# View bash_profile
cat ~/.bash_profile

  
# Add path to path variable of bash_profile
touch ~/.bash_profile
echo PATH=$PATH:/QOpenSys/QIBM/ProdData/OPS/tools/bin/ >> ~/.bash_profile


# Setup your user
git config --global user.email "First.Last@somewhere.com"
git config --global user.name "First Last"


# Generate ssh key
find /QOpenSys -name "ssh-keygen" 2> /dev/null
/QOpenSys/QIBM/ProdData/SC1/OpenSSH/bin/ssh-keygen


# Add ssh key to github, optionally
cat ~/.ssh/id_rsa.pub  # copy this


# Problem:     fatal: unable to access 'https://github.com/youruser/Some-Repo.git/': SSL certificate problem: unable to get local issuer certificate
# Solution: Disable ssl verification for the duration of the git command. https://stackoverflow.com/questions/11621768/how-can-i-make-git-accept-a-self-signed-certificate
git -c http.sslVerify=false pull origin master

# or in repo
git config http.sslVerify false


# VS Code SSH Extension
#    SSH FS Extension https://marketplace.visualstudio.com/items?itemName=Kelvin.vscode-sshfs