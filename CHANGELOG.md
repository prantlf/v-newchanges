# Changes

## [0.8.1](https://github.com/prantlf/v-newchanges/compare/v0.8.0...v0.8.1) (2025-03-22)

### Bug Fixes

* Adapt to breaking changes in teh V compiler ([d090488](https://github.com/prantlf/v-newchanges/commit/d0904888b3c02248910b159867cc3639f1a45271))

## [0.8.0](https://github.com/prantlf/v-newchanges/compare/v0.7.1...v0.8.0) (2024-11-17)

### Features

* Prefer sections for maps when saving the initial ini file ([36aa377](https://github.com/prantlf/v-newchanges/commit/36aa3779cec993035ac370dcf449980add2b9db2))

### Bug Fixes

* Stop using underscores in configurable titles for notes like BREAKING_CHANGE ([d42c272](https://github.com/prantlf/v-newchanges/commit/d42c27201812f2df0a8e8bcc5f4ad8f1d6b26a84))

### BREAKING CHANGES

If you configured the title of the breaking change notes using the key `BREAKING_CHANGE`, change it to `BREAKING CHANGE`. If you used other note sections with spaces in their names, do the same - use the same note name to configure the section title - with spaces.

When the default ini file is saved, type-mapping and type-titles will be stord in sectoins with properties instead of with a single long property. The other way of representing a map - a string with colon and common delimiters - is still supported, it is just not the default one.

## [0.7.1](https://github.com/prantlf/v-newchanges/compare/v0.7.0...v0.7.1) (2024-11-16)

### Bug Fixes

* Rebuild with new dependencies ([2b5f220](https://github.com/prantlf/v-newchanges/commit/2b5f2206014a917a3de0bb2badb85a10bf0a0a04))

## [0.7.0](https://github.com/prantlf/v-newchanges/compare/v0.6.0...v0.7.0) (2024-11-16)

### Features

* Add a package for the riscv64 architecture ([cb80cc6](https://github.com/prantlf/v-newchanges/commit/cb80cc602baa15e9cb17b612a404fa184440336b))
* Map non-standard change types to standard ones ([b564a6a](https://github.com/prantlf/v-newchanges/commit/b564a6aad41d017c2f654469e834a2ce75915f9f))

## [0.6.0](https://github.com/prantlf/v-newchanges/compare/v0.5.2...v0.6.0) (2024-04-26)

### Features

* Add displayable titles for change types refactor, docs, style, build ([5f5af3f](https://github.com/prantlf/v-newchanges/commit/5f5af3fd1e85fa7d872174ad46cbc115fabd2718))

## [0.5.2](https://github.com/prantlf/v-newchanges/compare/v0.5.1...v0.5.2) (2024-04-17)

### Bug Fixes

* Upgrade dependencies ([fa08d9c](https://github.com/prantlf/v-newchanges/commit/fa08d9c3ec93a248550c11948909c9323869e325))

## [0.5.1](https://github.com/prantlf/v-newchanges/compare/v0.5.0...v0.5.1) (2024-03-30)

### Bug Fixes

* Compute pre-releases with prantlf.semvut ([2a91167](https://github.com/prantlf/v-newchanges/commit/2a9116789f936fa0f36277696c3c9e86e6fc2d1a))

## [0.5.0](https://github.com/prantlf/v-newchanges/compare/v0.4.0...v0.5.0) (2024-03-24)

### Features

* Support pre-releases ([c3989cd](https://github.com/prantlf/v-newchanges/commit/c3989cd6a9e6588fa817c1f8f912d8e0e4ad86d8))

## [0.4.0](https://github.com/prantlf/v-newchanges/compare/v0.3.0...v0.4.0) (2023-12-15)

### Features

* Add the man file ([f0c8c32](https://github.com/prantlf/v-newchanges/commit/f0c8c32c871b9a46a1d68c3c8078a4abca9135f1))

## [0.3.0](https://github.com/prantlf/v-newchanges/compare/v0.2.0...v0.3.0) (2023-12-14)

### Features

* Add the linux arm64 support ([0234f3f](https://github.com/prantlf/v-newchanges/commit/0234f3f3f54cf910dc9c9d3013929e4ce308d26c))

## [0.2.0](https://github.com/prantlf/v-newchanges/compare/v0.1.2...v0.2.0) (2023-12-12)

### Features

* Add build for arm64 ([15bd66e](https://github.com/prantlf/v-newchanges/commit/15bd66e8b49fef5ae086b175bc27f49ee89ab896))
* Build for Windows by cross-compiling ([e44880f](https://github.com/prantlf/v-newchanges/commit/e44880f8ee4defe22e23651f8c542d828693b7f9))

## [0.1.2](https://github.com/prantlf/v-newchanges/compare/v0.1.1...v0.1.2) (2023-10-24)

### Bug Fixes

* Build with updated dependencies ([7be45cc](https://github.com/prantlf/v-newchanges/commit/7be45cc933d453c8ab472b8022f3f24d8172c8b7))

## [0.1.1](https://github.com/prantlf/v-newchanges/compare/v0.1.0...v0.1.1) (2023-10-23)

### Bug Fixes

* Do not start the written file log with ./ ([c4304f6](https://github.com/prantlf/v-newchanges/commit/c4304f687d84f7ed56d895b2dacf6950c8c0be69))

## [0.1.0](https://github.com/prantlf/v-newchanges/compare/v0.0.2...v0.1.0) (2023-10-22)

### Features

* Allow extracting the date of the last release from the changelog ([089102d](https://github.com/prantlf/v-newchanges/commit/089102d9e83815d2f806640426369ad368292ab9))
* Try fetching the missing history ([9e7cf16](https://github.com/prantlf/v-newchanges/commit/9e7cf16993725b7994d664d3be4dae9ebc68fd2f))

## [0.0.2](https://github.com/prantlf/v-newchanges/compare/v0.0.1...v0.0.2) (2023-10-22)

### Bug Fixes

* Workaround compiler bug with multiline pattern print on Windows ([267f282](https://github.com/prantlf/v-newchanges/commit/267f2828e3506024b6e715548116be92d2579bd2))

## 0.0.1 (2023-10-21)

Initial release
