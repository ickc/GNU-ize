#!/usr/bin/env bash

version="0.3"

usage="${BASH_SOURCE[0]} [-hU] --- install GNU tools as defaults on macOS. Version %s

where:
	-h	show this help message
	-U	upgrade instead of fresh install
	-p	prefix of the homebrew environment. Default: %s
"

# getopts ######################################################################

# reset getopts
OPTIND=1

# Initialize parameters
upgrade=False
prefix=/usr/local

# get the options
while getopts "Up:h" opt; do
	case "$opt" in
	U)	upgrade=True
		;;
	p)	prefix="$OPTARG"
		;;
	h)	printf "$usage" "$version" "$prefix"
		exit 0
		;;
	*)	printf "$usage" "$version" "$prefix"
		exit 1
		;;
	esac
done

if [[ $upgrade = False ]]; then
	install=install
else
	install=upgrade
fi

# brew install #########################################################

brew $install gcc

# Use gcc and g++ for packages from homebrew that build from source
export HOMEBREW_CC=$(find $prefix/bin -iname "gcc??")
export HOMEBREW_CC=${HOMEBREW_CC##*/}
export HOMEBREW_CXX=$(find $prefix/bin -iname "g++??")
export HOMEBREW_CXX=${HOMEBREW_CXX##*/}

# Install required packages from Homebrew
# error: git, gnutls, svn, vim, emacs
cat <<EOF | xargs brew $install
bash
binutils
coreutils
diffutils
e2fsprogs
file-formula
gawk
gdb
gpatch
gzip
less
m4
nano
openssh
rsync
screen
unzip
watch
wdiff
wget
aescrypt-packetizer
ed
findutils
gnu-indent
gnu-sed
gnu-tar
gnu-time
gnu-units
gnu-which
grep
inetutils
make
zsh
EOF

if [[ $upgrade == True ]]; then
	brew upgrade
fi

brew cleanup

# .path ################################################################

# default to use gcc
printf "%s\n" "# homebrew compiling using gcc" "export HOMEBREW_CC=$HOMEBREW_CC" "export HOMEBREW_CXX=$HOMEBREW_CXX" "" > $HOME/.path


# gnubin
echo "export PATH=\"$(echo $prefix/opt/*/libexec/gnubin | tr ' ' :):\$PATH\"" >> $HOME/.path
# gnuman
echo "export MANPATH=\"$(echo $prefix/opt/*/libexec/gnuman | tr ' ' :):\$MANPATH\"" >> $HOME/.path
# special cases
cat << "EOF" >> $HOME/.path
# keg-only path
export PATH="$prefix/opt/openssl/bin:$PATH"
# put to the last of PATH because "this installs several executables which shadow macOS system commands."
export PATH="$PATH:$prefix/opt/e2fsprogs/bin"
export PATH="$PATH:$prefix/opt/e2fsprogs/sbin"
EOF

# .bash_profile or equiv ###############################################

echo 'Add the following line to your .bash_profile, .bashrc, .zshrc or equivalent.'
printf "%s\n" "" '[[ -f $HOME/.path ]] && . $HOME/.path' ""

if ! grep -qE "$prefix/bin/bash" /etc/shells; then
	echo "Adding $prefix/bin/bash to /etc/shells. Ctrl-C if not needed."
	sudo sh -c "echo \"$prefix/bin/bash\" >> /etc/shells"
	echo "Adding $prefix/bin/zsh to /etc/shells. Ctrl-C if not needed."
	sudo sh -c "echo \"$prefix/bin/zsh\" >> /etc/shells"
fi
