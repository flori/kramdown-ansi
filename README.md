# Kramdown ANSI - Output markdown with ANSI

## Description

Kramdown::ANSI: A library for rendering Markdown(ish) documents with beautiful
ANSI escape sequences in the terminal.

## Installation (gem &amp; bundler)

To install Kramdown::ANSI, you can use the following methods:

1. Type

```shell
gem install kramdown-ansi
```

in your terminal.

1. Or add the line

```ruby
gem 'kramdown-ansi'
```

to your Gemfile and run `bundle install` in your terminal.

## Usage

In your own software the library can be used as shown in this example:

```ruby
require 'kramdown/ansi'

puts Kramdown::ANSI.parse(markdown)
```

## Executables

| Method | Description |
| :----- | :---------- |
| `md` executable | Outputs [Markdown](https://spec.commonmark.org/current/) files with ANSI escape sequences in the terminal |
| `git-md` executable | A Git plugin that outputs [Markdown](https://spec.commonmark.org/current/) formatted git commit messages into the terminal |

### The md executable

The `md` executable can by used with file arguments:

```shell
md Foo.md Bar.md …
```

or as a unix filter:

```shell
cat Foo.md Bar.md | md
```

It outputs the markdown files with ANSI escape sequences in the terminal. If
the file has more lines than the current terminal window has, it attempts to
open a pager command like `less` or `more` and pipes its output into it.
By setting the `PAGER` environment variable accordingly one can define a custom
command for this purpose.

The output of the `md` command can be seen in this screenshot:

![md output](./img/md.png)

### The git-md executable

The `git-md` executable is a git plugin that can be used to output markdown
formatted git commit messages (just like `git log`) into the terminal using

```shell
git md
```

You can pass arguments to it like you would of `git log`, e.g.

```shell
git md -p
```

to show the patches additionally to the log messages.

By setting the `GIT_PAGER` or `PAGER` environment variable accordingly one can
define a custom command for this purpose as well, unless a different
pager command was defined setting `git config set core.pager FOO`, in which
case the FOO command is used as a pager for all git commands including `git
md`.

The output of the `git md` command can be seen in this screenshot:

![git md output](./img/git-md.png)


## Download

The homepage of this library is located at

* https://github.com/flori/kramdown-ansi

## Author

<b>Kramdown ANSI</b> was written by Florian Frank [Florian Frank](mailto:flori@ping.de)

## License

[MIT License](./LICENSE)

## Mandatory Kitten Image

![cat](./spec/assets/kitten.jpg)

---

This is the end.
