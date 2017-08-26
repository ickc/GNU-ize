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
brew tap homebrew/dupes
brew install coreutils binutils diffutils ed findutils gawk gnu-indent gnu-sed \
	gnu-tar gnu-which gnutls grep gzip screen watch wdiff wget bash gdb gpatch \
	m4 make nano file-formula git less openssh rsync svn unzip vim \
	gnu-time \
	--default-names --with-default-names --with-gettext --override-system-vi \
	--override-system-vim --custom-system-icons
brew install emacs --with-cocoa --with-gnutls --with-imagemagick@6 --with-librsvg
brew cleanup

# .bash_path ###########################################################

# prepare PATH
# Empty the .bash_path file that holds GNU paths
printf "%s\n" 'export PATH="/usr/local/sbin\' > $HOME/.bash_path
# Build PATH variable script in ~/.bash_path
for i in /usr/local/Cellar/*/*/bin	/usr/local/Cellar/*/*/libexec/gnubin; do
	printf "%s\n" ":${i//://}\\" >> $HOME/.bash_path
done
#finalize PATH variable (adding back the old PATH, if exists, and closing the qoutes)
printf "%s\n" '${PATH+:}$PATH"' '' >> $HOME/.bash_path

# prepare MANPATH
# start the MANPATH
printf "%s\n" 'export MANPATH="\' >> $HOME/.bash_path
# build the contents of MANPATH, the closing quote needs to be within the sed statement
for i in /usr/local/Cellar/*/*/share/man /usr/local/Cellar/*/*/libexec/gnuman; do
	printf "%s\n" "$i:\\" >> $HOME/.bash_path
done
#finalize MATHPATH variable (adding back the old MATHPATH, if exists, and closing the qoutes)
printf "%s\n" '${MANPATH+:}$MANPATH"' >> $HOME/.bash_path

# .bash_profile ########################################################

# default to use gcc
printf "%s\n" "" "# homebrew compiling using gcc" "export HOMEBREW_CC=$HOMEBREW_CC" "export HOMEBREW_CXX=$HOMEBREW_CXX" "" >> $HOME/.bash_profile

# Add Ubuntu-style PS1 to .bash_profile
cat <<EOF >> $HOME/.bash_profile
# GNU-ize
alias ll="ls -ahl --color=always"
export PS1="\[\033[1;32m\]\u@\h\[\033[0m\]:\[\033[1;34m\]\w\[\033[0m\]# "
[ -f $HOME/.bash_path ] && source $HOME/.bash_path
EOF

# rather than creating a new bash profile, or trying to be smart when writing the bash profile, ask the user to cleanup any potential conflicts.
# because the gcc version might be different and difficult to detect. Moreover, these commands are not harmful to be loaded more than once.
echo "Please cleanup the bash profile."
open $HOME/.bash_profile
