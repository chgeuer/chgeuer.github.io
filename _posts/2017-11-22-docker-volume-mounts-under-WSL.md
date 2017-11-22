---
layout: default
title: "docker volume mounts under WSL"
date: 2017-11-22  09:30:00
---

Docker is a nice way to bring executables onto my laptop which I don't want to install in the local filesystem (to prevent bit rod). Examples could be [running jekyll from within docker](http://blog.swietochowski.eu/2016/07/31/Setting-up-jekyll-locally-with-docker.html) or the new [Elixir 1.6 code formatter in docker](http://blog.leif.io/use-docker-to-run-the-new-elixir-code-formatter/).

On my Windows box, I have docker for Windows installed, which expects volume mount parameters in the form of `-v C:/Users/chgeuer/Desktop:/mnt`, i.e. the local laptop's filesystem path is the Windows-style path with a drive letter, and the backslashes substituted by forward slashes.

On the Linux side of things, people usually mount the current working directory by specifying `-v $(pwd):/mnt`. When I run that on the Windows subsystem for Linux (or is the the Linux subsystem for Windows?), that expands to `-v /mnt/c/Users/chgeuer/Desktop:/mnt`. That `/mnt/c` stuff unfortunately isn't recognized by the docker for Windows daemon. 

## Solution

Instead of `-v $(pwd):/app`, use `-v $(echo $(pwd) | sed 's/^\/mnt\/\(.\)/\1:/'):/app`

This basically calls `$(pwd)` to determine the current working directory, and replaces `/mnt/x` with `x:`, so Docker works correctly.

## Example

A rather convoluted way to `ls` the current directory would be

```bash
docker run --rm --volume=$(echo $(pwd) | sed 's/^\/mnt\/\(.\)/\1:/'):/foo -it alpine:latest ls -als /foo
```
