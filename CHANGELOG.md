# Nginx Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
