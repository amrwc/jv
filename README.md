# jv – Java Version (Manager)

Zsh script for managing the JVM/JDK version in the current Shell instance.

<sup>Should've called it `JVM` though.</sup>

## Setup and usage

```console
git clone git@github.com:amrwc/jv.git
cd jv
. jv.zsh 14
```

Optionally, for convenience's sake, add a symlink to the script to be able to
use it anywhere:

```console
ln -s "$(pwd)/jv.zsh" /usr/local/bin/jv
```
