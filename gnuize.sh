#!/usr/bin/env bash

set -e

# brew install #########################################################

brew install gcc

# Use gcc and g++ for packages from homebrew that build from source
export HOMEBREW_CC=$(find /usr/local/bin -iname "gcc??")
export HOMEBREW_CC=${HOMEBREW_CC##*/}
export HOMEBREW_CXX=$(find /usr/local/bin -iname "g++??")
export HOMEBREW_CXX=${HOMEBREW_CXX##*/}

# Install required packages from Homebrew
cat <<EOF | xargs brew install
bash
binutils
coreutils
diffutils
file-formula
gawk
gdb
gnutls
gpatch
gzip
less
m4
nano
openssh
rsync
screen
svn
watch
wget
EOF

cat <<EOF | xargs brew install --with-default-names
ed
findutils
gnu-indent
gnu-sed
gnu-tar
gnu-time
gnu-which
grep
make
EOF

cat <<EOF | xargs brew install --with-gettext
git
wdiff
EOF

brew install vim --with-gettext --with-override-system-vi
brew install emacs --with-cocoa --with-gnutls --with-imagemagick@6 --with-librsvg

brew cleanup

# .bash_path ###########################################################

# default to use gcc
printf "%s\n" "# homebrew compiling using gcc" "export HOMEBREW_CC=$HOMEBREW_CC" "export HOMEBREW_CXX=$HOMEBREW_CXX" "" > $HOME/.bash_path

cat <<EOF >> $HOME/.bash_path
# Ubuntu-style PS1
alias ll="ls -ahl --color=always"
export PS1="\[\033[1;32m\]\u@\h\[\033[0m\]:\[\033[1;34m\]\w\[\033[0m\]# "
# cellar path
export PATH="/usr/local/opt/file-formula/bin:\$PATH"
export PATH="/usr/local/opt/m4/bin:\$PATH"
export PATH="/usr/local/opt/unzip/bin:\$PATH"
export PATH="/usr/local/opt/coreutils/libexec/gnubin:\$PATH"
export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:\$MANPATH"
EOF

# .bash_profile ########################################################

if ! grep -qE "([$]HOME|~)/\.bash_path" $HOME/.bash_profile; then
	printf "%s\n" "" '[ -f $HOME/.bash_path ] && . $HOME/.bash_path' "" >> $HOME/.bash_profile
fi
