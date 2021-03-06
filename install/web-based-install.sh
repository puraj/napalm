#!/bin/sh
#

version=1.7.2
tar=/tmp/napalm.tar.gz
extract=/tmp/napalm

bootstrap='[[ -f ~/.napalm/profile ]] && source ~/.napalm/profile'
pre15=$(grep --fixed-strings --count 'source "$bash_script"' ~/.bashrc)
post15=$(grep --fixed-strings --count "$bootstrap" ~/.bashrc)

set -o errexit # not for grep


# Warn about pre 1.5 installations
if [ $pre15 -ne 0 ]; then
  cat <<'EOF'
WARNING: Detected napalm with version less than 1.5

You should remove previously installed napalm before proceeding. The following
summarizes uninstallation procedure for napalm before 1.5. Note that it differs
from uninstall procedure described at https://github.com/mbezjak/napalm and this
one should be used instead.

  1) remove $NAPALM_HOME directory; execute 'napalm -v' to find out the value of
     $NAPALM_HOME
  2) remove potential symbolic link from '~/bin' directory
  3) remove any 'export PATH=...' calls in '~/.bashrc' that mention napalm
  4) remove old napalm bootstrap code in '~/.bashrc'; it usually has the
     following form:
         [[ -d ~/.napalm ]] && {
           ...
         }

Note that there is no need to remove ~/.napalm directory before upgrading!

Once napalm is uninstalled press any key to continue. Press ctrl+c to cancel.
EOF
  read any
  echo
fi


# download and install
rm -rf $tar $extract
mkdir $extract
wget https://github.com/mbezjak/napalm/tarball/$version -O $tar
tar --extract --file $tar --directory $extract

echo '------------------------------------------------'
echo Installing napalm $version
echo
make --directory=$extract/$(ls $extract) install "$@"
echo
echo


# Setup bootstrap in ~/.bashrc
if [ $post15 -eq 0 ]; then
  cat <<EOF
napalm 1.5 and above requires one line bootstrap in '~/.bashrc':
    $bootstrap
Should that line be automatically added to the end of '~/.bashrc' (y/n)?
EOF
  read answer
  echo
  if [ "$answer" = y ]; then
    printf "\n%s" "$bootstrap" >> ~/.bashrc
    echo "Added '$bootstrap' to ~/.bashrc"
  else
    cat <<EOF
You should manually add napalm bootstrap to '~/.bashrc':
    $bootstrap
EOF
  fi

  cat <<EOF

napalm can now be updated by executing the following command:
    $ napalm replace napalm $version

EOF
fi


echo Restart terminal to complete napalm $version installation

exit 0
