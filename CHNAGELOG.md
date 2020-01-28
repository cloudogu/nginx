# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [Unreleased]

Feature Branch 15379 unset unsave TLS

## Changed

- Removed unsecure TLS configuration from ssl.conf.tpl (disabled TLS 1.0 & 1.1)
- Edited ciphers in ssl.conf.tpl for max compatibility down to IE6 & WinXP with TLS 1.2
- Delted all ciphers only used by TLS 1.0 & TLS 1.1 


## v0.0.1 - v1.17.1-2 / previous versions

Up till version v1.17.1-2 there was no change log. Please see the [release page](https://github.com/cloudogu/nginx/releases) 

