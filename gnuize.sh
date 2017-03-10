#!/bin/bash
PROFILE_FILE=$HOME/.bash_profile
PATH_FILE=$HOME/.bash_path

# multilib is for compiling for other architechture, which may not work with OpenMP
brew install gcc --without-multilib

# backup .bash_profile if existed
[ -e "$PROFILE_FILE" ] && mv $PROFILE_FILE $(mktemp ${PROFILE_FILE}.XXXX)

# Use gcc and g++ for packages from homebrew that build from source
printf "%s\n" "export HOMEBREW_CC=$(find /usr/local/bin -iname "gcc??")" "export HOMEBREW_CXX=$(find /usr/local/bin -iname "g++??")" "" > $PROFILE_FILE

# Install required packages from Homebrew
brew tap homebrew/dupes
brew install coreutils binutils diffutils ed findutils gawk gnu-indent gnu-sed \
  gnu-tar gnu-which gnutls grep gzip screen watch wdiff wget bash gdb gpatch \
  m4 make nano file-formula git less openssh python rsync svn unzip vim \
  --default-names --with-default-names --with-gettext --override-system-vi \
  --override-system-vim --custom-system-icons
brew cleanup

# link the python applications installed above to /Applications
brew linkapps python

# prepare PATH
# Empty the .bash_path file that holds GNU paths
printf "%s\n" 'export PATH="/usr/local/sbin\' > $PATH_FILE
# Build PATH variable script in ~/.bash_path
for i in /usr/local/Cellar/*/*/bin  /usr/local/Cellar/*/*/libexec/gnubin; do
  printf "%s\n" ":${i//://}\\" >> $PATH_FILE
done
#finalize PATH variable (adding back the old PATH, if exists, and closing the qoutes)
printf "%s\n" '${PATH+:}$PATH"' '' >> $PATH_FILE

# prepare MANPATH
# start the MANPATH
printf "%s\n" 'export MANPATH="\' >> $PATH_FILE
# build the contents of MANPATH, the closing quote needs to be within the sed statement
for i in /usr/local/Cellar/*/*/share/man /usr/local/Cellar/*/*/libexec/gnuman; do
  printf "%s\n" "$i:\\" >> $PATH_FILE
done
#finalize MATHPATH variable (adding back the old MATHPATH, if exists, and closing the qoutes)
printf "%s\n" '${MANPATH+:}$MANPATH"' >> $PATH_FILE

# Check if .bash_path is being called from .bash_profile, if not, rebuild it from scratch
if ! grep -qE "([$]HOME|~)/\.bash_path" $PROFILE_FILE; then
  # Add Ubuntu-style PS1 to .bash_profile
  cat <<EOF >> $PROFILE_FILE
# GNU-ize
alias ll="ls -ahl --color=always"
export PS1="\[\033[1;32m\]\u@\h\[\033[0m\]:\[\033[1;34m\]\w\[\033[0m\]# "
[ -f $PATH_FILE ] && source $PATH_FILE

EOF
fi
