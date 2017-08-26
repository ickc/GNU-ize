# Credit

This started as a fork of [GNU-ize Mac OS X El Capitan](https://gist.github.com/TorgeH/4b9b0c0eee1b0b1a7ac81761faa3c772).

# Notes

To find packages that you might want to override the defaults, grep these from the [Homebrew Core repository](https://github.com/Homebrew/homebrew-core):

```bash
# these are simples, install with `--with-default-names` and you're done.
grep -irl --color=auto 'with-default-names' ./
# these varies. Use `brew info ...` to find out
grep -irHn --color=auto keg_only ./
# more specific
grep -irHn --color=auto 'keg_only :provided_by_osx' ./
grep -irHn --color=auto 'keg_only :provided_until_xcode' ./
```

If you have a list of packages you want to install, another trick is to put the info into a log and grep `PATH`, `with-default-names`, etc.


```bash
cat <<EOF | xargs brew info > temp.log
...
EOF
```
