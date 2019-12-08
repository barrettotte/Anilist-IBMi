# Anilist-IBMi


A basic display file and RPGLE program built over the Anilist GraphQL API (Just for fun/practice).


This is my first IBM i side project using GNU Make, git, and VS Code.
I still used SDA for display files because its a lot less tedious.


## Commands
* Build - ```gmake all```
* Clean - ```gmake clean```
* Log - ```gmake > buildlog.txt 2>&1```
* Copy dspf - ```gmake copy``` (still using SDA for DSPFs)
* Pushing - ```git -c http.sslVerify=false push origin master```


## VS Code
* SSH terminal session for running git and gmake commands
* SSH FS VS Code Extension https://marketplace.visualstudio.com/items?itemName=Kelvin.vscode-sshfs
* Do not use CRLF line endings, use LF (lower right)


## Setup Environment 
```sql
-- Set user's default PASE Shell using DB2 for i
CALL QSYS2.SET_PASE_SHELL_INFO('*CURRENT', '/QOpenSys/pkgs/bin/bash');
```

```bash
# Install git through yum (/QOpenSys/pkgs/bin/)
yum install git.ppc64
yum install make-gnu.ppc64

# config git user
git config --global user.email "First.Last@somewhere.com"
git config --global user.name "First Last"

# Add yum packages install directory to PATH
touch ~/.profile
echo PATH=$PATH:/QOpenSys/pkgs/bin >> ~/.profile
```


## References
* RPG & DB2 Summit 2019 - Liam's session on git + IBMi
* https://github.com/NielsLiisberg/RPG-vsCode-Getting-Started
* Fix DSPF open in linear main https://www.rpgpgm.com/2018/09/closing-all-files-with-one-operation-in.html
