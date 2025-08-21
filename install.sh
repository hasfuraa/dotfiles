#!/bin/bash

green='\033[0;32m'
red='\033[0;31m'
nc='\033[0m'

backup_name () {
  suffix="BACKUP--`date +%Y%m%d-%H%M`"
  echo -n $1.$suffix
}

backup () {
  echo "cp -Rp $1 `backup_name $1`;" | bash -x
}


# Install bashrc.mine.
installed=$(grep -i -e "source ~/.bashrc.mine" ~/.bashrc)
if [ -n "$installed" ]; then
  printf "${red}SKIP:${nc} %15.15s already sources ~/.bashrc.mine \n" ".bashrc"
else
  printf "${green}BASHRC:${nc} echo -n 'source ~/.bashrc.mine' >> ~/.bashrc\n"
  echo -n 'source ~/.bashrc.mine' >>  ~/.bashrc
fi

# Install zshrc.mine.
installed=$(grep -i -e "source ~/.zshrc.mine" ~/.zshrc)
if [ -n "$installed" ]; then
  printf "${red}SKIP:${nc} %15.15s already sources ~/.zshrc.mine \n" ".zshrc"
else
  printf "${green}BASHRC:${nc} echo -n 'source ~/.zshrc.mine' >> ~/.zshrc\n"
  echo -n 'source ~/.zshrc.mine' >>  ~/.zshrc
fi

# Link .rc files.
rc_files=$(ls -a | tr [:blank:] "\n" | grep -v -E "^[\.]+$" | grep -v -E "install" | grep -v -E ".git")
for f in $rc_files
do
  if [ -L ~/$f ]; then
    lf=`readlink ~/$f`
    printf "${red}SKIP:${nc} %15.15s already links to %s.\n" $f $lf
  elif [ -f ~/$f ] || [ -d ~/$f ]; then
    printf "%s already exists and is a regular file or directory...\n" $f
    printf "Backup %s to %s and link %s to %s [y/n]? " "~/$f" "~/`backup_name $f`" "~/$f" "$(pwd)/$f"
    read do_backup
    if [ 'y' == $do_backup ]; then
	backup ~/$f && rm -r ~/$f && ln -s $(pwd)/$f ~/$f
	echo "+ rm -r ~/$f && ln -s $(pwd)/$f ~/$f"
    fi
  else
    printf "${green}LINK:${nc} ln -s $(pwd)/f ~/$f\n"
    ln -s $(pwd)/$f ~/$f
  fi
done

FOLDER=~/.vim/bundle/Vundle.vim
if [ ! -d ${FOLDER} ] ; then
  git clone https://github.com/VundleVim/Vundle.vim.git ${FOLDER}
fi
vim +PluginInstall +qall
