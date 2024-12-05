# Nginx Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Changed
- Update ces-about to v0.7.0 for updated license information

## [v1.26.2-1] - 2024-11-19
- Upgrade dogu-build-lib to v2.5.0 
- Upgrade ces-build-lib to v3.0.0
- Upgrade base-image to v3.20.3-3
- Upgrade nginx Version to v1.26.2

## [v1.26.1-11] - 2024-09-26
### Added
- Animated image for dogu-starting-page

### Changed
- [#111] Use animation to show automatic reload of Dogu

## [v1.26.1-10] - 2024-09-18
### Changed
- Relicense to AGPL-3.0-only

## [v1.26.1-9] - 2024-09-13
### Changed
- [#107] Redesign error-pages
  - Change UI language of the error-pages to german

## [v1.26.1-8] - 2024-09-04
### Fixed
- Fix problems with content security policies (CSP) caused by whitelabeling

## [v1.26.1-7] - 2024-08-29
### Changed
- Update warp menu to v2.0.0 (#104)
- Make static asset urls dependent of the current warp menu version to invalidate caches

## [v1.26.1-6] - 2024-08-27
### Changed
- [#102] Redesign dogu-starting-page
- Change UI language of the dogu-starting-page to german


## [v1.26.1-5] - 2024-08-15
### Changed
- Include whitelabeling-styles in html, instead of js [#100]
- Rename whitelabeling variables to new schema

## [v1.26.1-4] - 2024-08-07
### Changed
- [#98] Upgrade base-image to v3.20.2-1

### Security
- close CVE-2024-41110 

## [v1.26.1-3] - 2024-08-06
### Added
- Default CSS Styles and Whitelabeling CSS Styles are being loaded now (#96)
  - similarly to the already existing warp-menu script and styles

## [v1.26.1-2] - 2024-07-01
### Changed
- Update base image to Version 3.20.1-2 (#92)
- Update `ces-about` to `0.5.0` (#94)

## [v1.26.1-1] - 2024-06-14
### Changed
- Write app.conf into volume instead of the container file system (#90)
   - this should make nginx more robust against container re-creations
- replace deprecated `http2` option against the current directive 
- Update nginx to 1.26.1 (#88)
- Update base image to Alpine 3.19.1

### Security
- Fixed medium CVEs:
    - CVE-2023-42366
    - CVE-2024-4603
- Fixed low CVE: CVE-2024-2511
   
## [v1.23.2-10] - 2024-01-29
### Changed
- Update `ces-confd` to `0.9.0` (#84)

## [v1.23.2-9] - 2024-01-18
### Changed
- Update `ces-confd` to `0.8.2` (#82)

## [v1.23.2-8] - 2023-11-07
### Changed
- Update `ces-about` to `0.4.0` (#80)
- Use additional routes provided by `ces-about` (#80)

## [v1.23.2-7] - 2023-07-10
### Changed
- [#78] replaced all references to myCloudogu with references to the cloudogu platform

## [v1.23.2-6] - 2023-05-05
### Fixed
- [#76] redirect errors to stderr and accesses to stdout again

## [v1.23.2-5] - 2023-04-24
### Changed
- [#74] Upgrade Base Image to 3.17.3-2

### Security
- [#74] Fixed CVE-2023-27536, CVE-2023-27536 and some others

## [v1.23.2-4] - 2023-03-31
### Added
- Add automatic refresh (every 10 seconds) of the dogu-is-starting-page (#72)

## [v1.23.2-3] - 2023-02-17
### Changed
- Update warp-menu to v1.7.2 (#70)

## [v1.23.2-2] - 2023-02-02
### Changed
- Update warp-menu to v1.7.1 (#68)
   - This will fix the bug where the warp menu was visible in print view

## [v1.23.2-1] - 2023-01-23
### Changed
- Upgrade to nginx 1.23.2; #64
- Upgrade ces-build-lib to v1.60.1
- Upgrade dogu-build-lib to v1.10.0
- Upgrade warp menu version to 1.7.0 (#67)

## [v1.21.5-8] - 2022-12-13
### Added
- Update ces-confd to 0.8.0 (#63)
- Add possibility to disable request buffer by setting registry key `config/nginx/buffering/<doguname>` to `off` (#63)

## [v1.21.5-7] - 2022-09-20
### Changed
- Update ces-confd to 0.7.0 #61

## [v1.21.5-6] - 2022-06-07

### Changed
- Update warp-menu to v1.6.0

## [v1.21.5-5] - 2022-05-25
### Changed
- Update warp-menu to v1.5.0

## [v1.21.5-4] - 2022-04-06
### Changed
- Upgrade base image to 3.15.3-1; #56

### Fixed
- Upgrade zlib to fix CVE-2018-25032; #56
- Upgrade ssl libraries to 1.1.1n-r0 and fix [CVE-2022-0778](https://security.alpinelinux.org/vuln/CVE-2022-0778)

## [v1.21.5-3] - 2022-03-23
### Changed
- changed config.yaml.tpl to support support-entries from ces-confd
- update ces-confd to version v0.6.0
- update warp-menu to version v1.4.0

## [v1.21.5-2] - 2022-01-28
### Changed
- Upgrade to ces-theme v0.7.0

## [v1.21.5-1] - 2022-01-19
### Changed
- Add integration tests for custom static HTML page #51
- Upgrade to nginx 1.21.5; #51

## [v1.17.10-9] - 2021-11-22
### Changed
- update warp menu to version 1.3.0

## [v1.17.10-8] - 2021-11-02
### Changed
- The script to append the warp menu to each page is now hosted instead of inline (#49)
- Use logging/root key

## [v1.17.10-7] - 2021-06-17
### Changed
- Update warp-menu version to v1.2.0 and add link to Cloudogu docs (#47)

## [v1.17.10-6] - 2021-06-04
### Changed
- Remove duplicated volume declaration (#45)

## [v1.17.10-5] - 2021-04-20
## Changed
- Update warp-menu to v1.1.1 (#43)

## [v1.17.10-4] - 2021-04-07
## Fixed
- Remove async flag in warp-menu script tag to generate valid html (#41)

## Changed
- Upgrade warp menu to version 1.1.0 (#41)

## [v1.17.10-3] - 2021-02-24
## Changed
- Upgrade ces-confd to version 0.5.1

## [v1.17.10-2] - 2021-02-12
## Added
- New volume `app.conf.d` for custom configuration of additional location endpoints #38

### Changed
- Add configuration for websocket connection #36

## [v1.17.10-1] - 2021-01-25
### Changed
- Update nginx to 1.17.10 #32
- Instead of the name, the new service attribute 'location' is now used as the location. #34

## [v1.17.8-8] - 2021-01-14
### Added
- Starting page for unhealthy dogus #30

### Changed
- Update ces-confd to 0.4.0 #30

## [v1.17.8-7] - 2021-01-12
### Added
- Added the ability to configure the memory limits with cesapp edit-config; #28

## [v1.17.8-6] - 2020-11-16
### Added
- Ability to deliver custom content pages. (#26)
- SHA256 checks for all manual downloads in the dockerfile

### Changed
- Update of the base image to v3.11.6-3
- Update warp-menu version to v1.0.4

## [v1.17.8-5] - 2020-07-20
### Changed
- Update styles so HTTP error pages have all the same text color.

## [1.17.8-4] - 2020-05-26
### Changed
- update warp menu to v1.0.3

## [1.17.8-3] - 2020-05-20
### Changed
- update warp menu to v1.0.2

## [1.17.8-2] - 2020-05-12
### Changed
- update warp menu to v1.0.1

## [1.17.8-1] - 2020-01-29
### Changed
- Available ciphers

### Removed
- Support for TLS 1.0 & 1.1


## v0.0.1 - v1.17.1-2 / previous versions

Up till version v1.17.1-2 there was no changelog. Please see the [release page](https://github.com/cloudogu/nginx/releases)
