# New Changes (Changelog) Generator

Creates or updates the changelog file from commit messages formatted according to [Conventional Commits].

> The [Conventional Commits] is a specification for adding human and machine readable meaning to commit messages. It's a lightweight convention on top of commit messages. It provides an easy set of rules for creating an explicit commit history; which makes it easier to write automated tools on top of. This convention dovetails with [Semantic Versioning], by describing the features, fixes, and breaking changes made in commit messages.

About writing commit messages, see [A Note About Git Commit Messages], [How to Write a Git Commit Message] and [Git Commit Good Practice]. See also the tool [vp] for automating the whole package publishing.

[Node.js] users can install this tool using [node-newchanges] too.

## Synopsis

Update `CHANGELOG.md` automatically from the commit messages:

    ❯ newchanges
    discovered 1 classified commit from 1 total since v0.2.1
    version 0.3.0 (2023-08-13) and 10 lines written to "./CHANGELOG.md"

## Usage

Updates the changelog file using git log messages by default if no command is specified.

    newchanges [options] [commands]

### Commands

    init                      generate a config file with defaults

### Options

    -c|--config <name>        file name or path of the config file
    -l|--log <file>           file to read from and write to (default: to find)
    -t|--tag-prefix <prefix>  expect git tags prefixed (default: "v")
    -h|--heading <level>      level of the log entry headings (default: 2)
    -l|--logged-types <types> change types to include in the log
    -f|--from <hash>          start at a specific commit (default: last change)
    -t|--to <hash>            end at a specific commit (default: HEAD)
    -u|--try-unshallow        try fetch missing commits and tags if not found
    -p|--path <path>          consider only specific path (default: git root)
    -r|--repo-url <url>       URL of the git repository (default: from git)
    -o|--override-version <v> set the new version to the specified value
    -e|--write-changes <file> write the new changes to the specified file
    -w|--write-version <file> write the version number to the specified file
    -a|--assume-patch         assume a patch release for insignificant commits
    -0|--bump-major-0         bump the major version also if it is 0
    --pre-release             bump the existing pre-release number
    --pre-id <id>             first pre-release identifier (default: "next")
    -d|--dry-run              print the new changes on the console only
    -N|--no-failure           do not fail if the change log was not updated
    -i|--print-last           print changes for the last version on the console
    -q|--quiet                omit the summary note on the standard output
    -v|--verbose              print the new changes on the console too
    -V|--version              print the version of the executable and exits
    -h|--help                 print the usage information and exits

Default change types to include in the log: "feat", "fix", "perf". If the commit message includes the note "BREAKING CHANGE", it will be included in the log regardless of its type.

###  Examples:

    $ newchanges -f v0.1.0 -t v0.2.0
    $ newchanges -d

## Description

Let us have a look at the following changelog excerpt:

> ### [14.0.1](https://github.com/prantlf/jsonlint/compare/v14.0.0...v14.0.1) (2023-04-27)
>
> #### Bug Fixes
>
> * Ensure error location by custom parsing ([9757213](https://github.com/prantlf/jsonlint/commit/9757213eda5de9684099024d0c4f59e4d4f59c97))
> * Upgrade dependencies ([30f611a](https://github.com/prantlf/jsonlint/commit/30f611a1fc24a9003929a1f399d1694de65401ed))
>
> ### [14.0.0](https://github.com/prantlf/jsonlint/compare/v13.1.0...v14.0.0) (2023-03-05)
>
> #### Features
>
> * Support JSON Schema drafts 2019-09 and 2020-12 and JSON Type Definition ([0b9130c](https://github.com/prantlf/jsonlint/commit/0b9130ceae5f6f27cbe3e6d65207127862ffe584))
>
> #### BREAKING CHANGES
>
> * The default environment recognises only JSON Schema drafts 06 and 07 automatically.
>   Not 04 any more. The environment for JSON Schema drafts 04 has to be selected explicitly.
>   Also, JSON Schema drafts 06 and 07 are handled by AJV@8 instead of AJV@6. It shouldn't
>   make any difference, but the implementation is new and could perform a stricter validation.

Which is rendered from the following source:

```
## [14.0.1](https://github.com/prantlf/jsonlint/compare/v14.0.0...v14.0.1) (2023-04-27)

### Bug Fixes

* Ensure error location by custom parsing ([9757213](https://github.com/p...t/9...7))
* Upgrade dependencies ([30f611a](https://github.com/prantlf/jsonlint/commit/3...d))

## [14.0.0](https://github.com/prantlf/jsonlint/compare/v13.1.0...v14.0.0) (2023-03-05)

### Features

* Support JSON Schema drafts 2019-09 and 2020-12 and JSON Type Definition ([0b9130c](h...t/0...4))

### BREAKING CHANGES

* The default environment recognises only JSON Schema drafts 06 and 07 automatically.
  Not 04 any more. The environment for JSON Schema drafts 04 has to be selected explicitly.
  Also, JSON Schema drafts 06 and 07 are handled by AJV@8 instead of AJV@6. It shouldn't
  make any difference, but the implementation is new and could perform a stricter validation.
```

Which was generated from the following commits:

```
commit ffc5c32d2811c00b8f237592467fcc898f035c9f (tag: v14.0.1)
Author: Ferdinand Prantl <prantlf@gmail.com>
Date:   Thu Apr 27 06:09:42 2023 +0000

  14.0.1

commit 9757213eda5de9684099024d0c4f59e4d4f59c97
Author: Ferdinand Prantl <prantlf@gmail.com>
Date:   Thu Apr 27 08:06:46 2023 +0200

  fix: Ensure error location by custom parsing

  The native JSON.parse does not always provide the error location
  at the end of the error message. These two invalid inputs either
  include or not include the error location and it is different
  with Node.js 18 and Node.js 20:

    { "foo": \"baz }
    { "foo": baz }

  If the location is missing, let us parse the input once more
  by the custom parser, which always provides the error location.

commit 30f611a1fc24a9003929a1f399d1694de65401ed
Author: Ferdinand Prantl <prantlf@gmail.com>
Date:   Thu Apr 27 08:03:55 2023 +0200

  fix: Upgrade dependencies

commit d92083d6028dcc3205fbb8512c64e360a46c0fc8
Author: Ferdinand Prantl <prantlf@gmail.com>
Date:   Sun Mar 5 15:45:04 2023 +0100

  chore: Update benchmarks and add the json-6 parser

commit a3de000313453b9012511b3252ed43085dbdfb96 (tag: v14.0.0)
Author: Ferdinand Prantl <prantlf@gmail.com>
Date:   Sun Mar 5 11:50:39 2023 +0000

  14.0.0

commit 0b9130ceae5f6f27cbe3e6d65207127862ffe584
Author: Ferdinand Prantl <prantlf@gmail.com>
Date:   Sun Mar 5 01:29:50 2023 +0100

  feat: Support JSON Schema drafts 2019-09 and 2020-12 and JSON Type Definition

  Upgrade AJV to the latest version and retain the previous AJV@6
  to be able to suport JSON Schema draft 04.

  BREAKING CHANGE: The default environment recognises only JSON Schema drafts
  06 and 07 automatically. Not 04 any more. The environment for JSON Schema
  drafts 04 has to be selected explicitly. Also, JSON Schema drafts 06 and 07
  are handled by AJV@8 instead of AJV@6. It shouldn't make any difference,
  but the implementation is new and could perform a stricter validation.
```

### Changes

	# Changes

	## [14.0.3](https://github.com/prantlf/jsonlint/compare/v14.0.2...v14.0.3) (2023-04-27)

    * Replace ajv@6 with ajv-draft-04 ([b1535a3](https://github.com/test/test/commit/b...f))

	## 1.0.1 (2011-05-21)
    ...

#### Configuration

For analysing:

```yml
version_re = ^\s*(?<heading>#+)\s+(?:(?<version>\d+\.\d+\.\d+)|(?:\[(?<version>\d+\.\d+\.\d+)\])).+\((?<date>[-\d]+)\)\s*$
```

For generating:

```yml
prolog = # Changes
version_tpl = {heading} [{version}]({repo_url}/compare/{tag_prefix}{prev_version}...{tag_prefix}{version}) ({date})
change_tpl = #{heading} {title}
commit_tpl = * {description} ([{short_hash}]({repo_url}/commit/{hash}))
```

### Commits

Examples of commit messages and matching configuration:

#### Example

    fix: Replace ajv@6 with ajv-draft-04

    Support JSON Schema draft 04 by a more modern package.

#### Configuration

```
subject_re = ^\s*(?<type>[^: ]+)\s*:\s*(?<description>.+)$
```

#### Example

    Replace ajv@6 with ajv-draft-04 (fix)

    Support JSON Schema draft 04 by a more modern package.

#### Configuration

```
subject_re = ^\s*(?<description>.+)\s*\((?<type>[^ ]+)\)\s*$
```

#### Example

    Replace ajv@6 with ajv-draft-04 (fix, #87, #101)

    Support JSON Schema draft 04 by a more modern package.

#### Configuration

```
subject_re = ^\s*(?<description>.+)\s*\((?<type>[^ ]+)(?:\s*,\s*#(?<issue>[^ ]+))?(?:\s*,\s*#(?<issue>[^ ]+))?\)\s*$
```

#### Example

    Replace ajv@6 with ajv-draft-04

    Support JSON Schema draft 04 by a more modern package.

    Type: fix
    Fixes #87 #95
    Fixes #101

#### Configuration

```
subject_re = ^\s*(?<description>.+)$
footer_re = ^(?:Type:\s*(?<type>[^ ]+))|(?:Fixes\s*#(?<issue>[^ ]+)(?:\s*#(?<issue>[^ ]+))?)\s*$
```

## Contributing

In lieu of a formal styleguide, take care to maintain the existing coding style. Lint and test your code.

## License

Copyright (c) 2023-2024 Ferdinand Prantl

Licensed under the MIT license.

[Conventional Commits]: https://www.conventionalcommits.org/
[Semantic Versioning]: https://semver.org/
[A Note About Git Commit Messages]: https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
[How to Write a Git Commit Message]: https://cbea.ms/git-commit/
[Git Commit Good Practice]: https://wiki.openstack.org/wiki/GitCommitMessages
[vp]: https://github.com/prantlf/vp
[node-newchanges]: https://github.com/prantlf/node-newchanges
[Node.js]: http://nodejs.org/
