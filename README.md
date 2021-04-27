# chckyn's guix channel

These are my [GNU Guix][guix] package definitions published in the form of
a [Guix Channel][guix-channel].

## Packages

### neovim-nightly

This package is pinned to a commit on the `nightly` branch of
[Neovim][neovim].

### tree-sitter

[Tree-sitter][tree-sitter] is a required dependency for the `nightly`
branch of Neovim, so I package it here since I could not find it in
another Guix channel.

## Usage

### via load-path

The simplest way to use this channel is to temporarily add it to Guix's
load-path:

``` shell
git clone https://github.com/chckyn/guix-channel.git
guix install -L ./guix-channel neovim-nightly
```

### via channels.scm

A more permanent solution is to configure Guix to use this channel as an
*additional channel*.  This will extend your package collection with
definitions from this channel.  Updates will be received (and authenticated)
with `guix pull`.

To use the channel, add it to your configuration in
`~/.config/guix/channels.scm`:

``` scheme
(cons* (channel
        (name 'chckyn)
        (url "https://github.com/chckyn/guix-channel.git")
        (branch "main")
        (introduction
         (make-channel-introduction
          "daa642fbaa53e9b6f1cfd22ea013e5fdf4e17e3a"
          (openpgp-fingerprint
           "2116 4C25 323C EAF7 611E  49E6 9CFB 4F28 C311 D53D"))))
       %default-channels)
```

With the channel configured, it can be used as follows:

``` shell
guix pull
guix search neovim-nightly
guix install neovim-nightly
```

[guix]: https://guix.gnu.org/
[guix-channel]: https://guix.gnu.org/manual/en/html_node/Channels.html
[neovim]: https://github.com/neovim/neovim
[tree-sitter]: https://github.com/tree-sitter/tree-sitter
