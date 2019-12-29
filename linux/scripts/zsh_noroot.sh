#!/bin/sh
INSTALL_PATH=$HOME/root_dir
mkdir $INSTALL_PATH
mkdir $INSTALL_PATH/bin
mkdir $INSTALL_PATH/etc
mkdir $INSTALL_PATH/usr
mkdir $INSTALL_PATH/usr/share

./configure --prefix=$INSTALL_PATH/usr         \
            --bindir=$INSTALL_PATH/bin         \
            --sysconfdir=$INSTALL_PATH/etc/zsh \
            --enable-etcdir=$INSTALL_PATH/etc/zsh
            
makeinfo  Doc/zsh.texi --plaintext -o Doc/zsh.txt
makeinfo  Doc/zsh.texi --html      -o Doc/html
makeinfo  Doc/zsh.texi --html --no-split --no-headers -o Doc/zsh.html

make install
make infodir=$INSTALL_PATH/usr/share/info install.info

install -v -m755 -d                 $INSTALL_PATH/usr/share/doc/zsh-5.2/html
install -v -m644 Doc/html/*         $INSTALL_PATH/usr/share/doc/zsh-5.2/html
install -v -m644 Doc/zsh.{html,txt} $INSTALL_PATH/usr/share/doc/zsh-5.2

make htmldir=$INSTALL_PATH/usr/share/doc/zsh-5.2/html install.html
install -v -m644 Doc/zsh.dvi $INSTALL_PATH/usr/share/doc/zsh-5.2
install -v -m644 Doc/zsh.pdf $INSTALL_PATH/usr/share/doc/zsh-5.2

