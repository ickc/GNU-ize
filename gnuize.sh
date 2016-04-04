#!/bin/bash
PROFILE_FILE=$HOME/.bash_profile
PATH_FILE=$HOME/.bash_path

# Install required packages from Homebrew
brew tap homebrew/dupes
brew install coreutils binutils diffutils ed findutils gawk gnu-indent gnu-sed \
  gnu-tar gnu-which gnutls grep gzip screen watch wdiff wget bash gdb gpatch \
  m4 make nano file-formula git less openssh python rsync svn unzip vim \
  --default-names --with-default-names --with-gettext --override-system-vi \
  --override-system-vim --custom-system-icons
brew cleanup

# Empty the .bash_path file that holds GNU paths
echo -n 'export PATH="/usr/local/sbin' > $PATH_FILE

# Build PATH variable script in ~/.bash_path
for i in /usr/local/Cellar/*/*/bin  /usr/local/Cellar/*/*/libexec/gnubin; do
  echo -n ":${i//://}" >> $PATH_FILE
done

echo -e '${PATH+:}$PATH"\n' >> $PATH_FILE

echo -n 'export MANPATH="' >> $PATH_FILE

for i in /usr/local/Cellar/*/*/share/man /usr/local/Cellar/*/*/libexec/gnuman; do
  echo -n "$i:" 
done | sed 's#:$##' >> $PATH_FILE

echo '${MANPATH+:}$MANPATH"' >> $PATH_FILE

# Check if .bash_path is being called from .bash_profile, if not, rebuild it from scratch
if grep -qE "([$]HOME|~)/\.bash_path" $PROFILE_FILE; then
  # nothing to do -- .bash_profile already sources .bash_path
else
  [ -e "$PROFILE_FILE" ] && mv $PROFILE_FILE $(mktemp ${PROFILE_FILE}.XXXX)
  # Add Ubuntu-style PS1 to .bash_profile
  cat <<EOF > $PROFILE_FILE
alias ll="ls -ahl --color=always"
export PS1="\[\033[1;32m\]\u@\h\[\033[0m\]:\[\033[1;34m\]\w\[\033[0m\]# "
[ -f $PATH_FILE ] && source $PATH_FILE
EOF
fi

