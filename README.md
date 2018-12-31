# Git Back Up

Git back up is a collection of easily extensible, simple shell scripts to back stuff up to git.

It is not meant to be added to your PATH, since its primary use is automated backups. That said,
this documentation will refer to these scripts **as if** they were in the PATH.

Git Back Up assumes that git is configured to automatically use the credentials of the user it's
running as.

## Why?

I find myself re-imaging computers often, and it's always such a pain to restore everything. And
I want a remote backup system for my configurations that's off-site and separated by computer.
Other backup systems I've used lack the simplicity of git branches. They're more difficult to
audit and diff, more difficult to manage, and more difficult to migrate across machines.

## Requirements

* git
* `bash` or `dash` (old school bourne shell probably works tool), accessible via /bin/sh
* A few common utilities - `dirname`, `cat`, `echo`, etc.
* Other common or relevant tools, depending on the script

## Usage

The first thing you'll need to do is run `vscode.sh repo <your_repo>`, where `vscode.sh` can be any
script (they all use the same repo).

Each script (except common.sh) is an entry point. So `vscode.sh backup` will back up your VS Code
settings, and `vscode.sh restore <your_branch_here>` will restore from a given branch.

By default, branches are named `${label}-$(whoami)@$(hostname|cut -d . -f 1)`, or in the example
of my current laptop, `vscode-ericmiller@Njord`. To customize this autoformatting, see the
beginning of `common.sh`.

At this point, backups can be done with `vscode.sh backup`, restores can be done with
`vscode.sh restore vscode-$(whoami)@$(hostname|cut -d . -f 1)` (or manually specifying the branch),
the repo can be changed with `vscode.sh repo <new_repo>`, and the help page can be shown with
`vscode.sh help`

`vscode.sh` is used as an *example* here, this will work with all git-back-up scripts.

I recommend that the repo you back up to is private, just in case there winds up being something
you don't want public in the backups. Backing up sensitive information with Git Back Up is not
recommended; look into an encrypted backup system like [duplicity](http://duplicity.nongnu.org/).

### Plugins

* `brew.sh` - For use with macOS homebrew. Backs up formulae, casks, and taps. Restores same, but also installs homebrew if not present and in `$PATH`.
* `htop.sh` - Captures the htop config file.
* `shprofile` - Captures per-user shell profile for bash or zsh.
* `vscode.sh` - For use with Visual Studio code. Backs up extensions (without versions) and settings. Restores same.

### Please

Don't save binaries or databases, or anything with massive amounts of data with this. Just don't.

## Extending

`common.sh` takes care of all the logic of git integration, the temporary directory, the cleanup,
the parameters, and the help page. There are just a few things you need to do.

### Boilerplate

Your script should start with something like:

```sh
#!/bin/sh
label=brew

source "$(dirname $0)/common.sh"
```

Where `label` is a unique, git-branch-friendly name for the kinds of configurations you'll be
backing up.

It should end with a call to `gitbackup $*`, a function provided by `common.sh` to run the app.

### Backup/Restore Logic

Then, you need to create functions `backup` and `restore`. For backup, all you have to do is put
the files you want backed up into the working directory. For restore, the files you backed up are
in the working directory, and you need to put them back where they belong (or do something with
them, as is the case with package manager backups). Check out the pre-existing files for examples.

That's it - Git Back Up does the rest of the plumbing.
