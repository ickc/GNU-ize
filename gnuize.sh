#!/bin/bash

# Install Homebrew (if not already installed)
ruby -e "$(curl -fsSL "\
"https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install required packages from Homebrew
brew tap homebrew/dupes
brew install coreutils binutils diffutils ed findutils gawk gnu-indent gnu-sed \
  gnu-tar gnu-which gnutls grep gzip screen watch wdiff wget bash gdb gpatch \
  m4 make nano file-formula git less openssh python rsync svn unzip vim \
  --default-names --with-default-names --with-gettext --override-system-vi \
  --override-system-vim --custom-system-icons

# Empty the .bash_path file that holds GNU paths
> ~/.bash_path

# Build PATH variable script in ~/.bash_path
for i in /usr/local/Cellar/*/*/bin; do
  echo 'export PATH="'$i':$PATH"' >> ~/.bash_path
done
for i in /usr/local/Cellar/*/*/libexec/gnubin; do
  echo 'export PATH="'$i':$PATH"' >> ~/.bash_path
done
for i in /usr/local/Cellar/*/*/share/man; do
  echo 'export MANPATH="'$i':$MANPATH"' >> ~/.bash_path
done
for i in /usr/local/Cellar/*/*/libexec/gnuman; do
  echo 'export MANPATH="'$i':$MANPATH"' >> ~/.bash_path
done

# Check if .bash_path is being called from .bash_profile
PATCH=`grep "~/.bash_path" ~/.bash_profile`
if [ "$PATCH" == "" ]; then
  # Add Ubuntu-style PS1 to .bash_profile
  cat <<EOF > ~/.bash_profile
export PS1="\[\033[1;32m\]\u@\h\[\033[0m\]:\[\033[1;34m\]\w\[\033[0m\]# "
EOF
  # Add .bash_path to .bash_profile
  echo "source ~/.bash_path" >> ~/.bash_profile
fi
