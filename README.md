# sshkeysfs

A really hacky implementation of a FuSE-Filesystem. The intended use-case is a more
reverse-proxyish ssh-server.

## Getting started

### Quickstart

```bash
# pull the container
docker pull steigr/ssh-reverse-proxy
# load fuse kernel module
sudo modprobe fuse
# run the container, with access to fuse and CAP_SYS_ADMIN to mount sshkeysfs
docker run \
  --rm -ti \
  -p 22:22 \
  -v /users.yml:/users.yaml \
  --env MAP_URI=/users.yml \
  --device /dev/fuse \
  --cap-add SYS_ADMIN \
  steigr/ssh-reverse-proxy
```

### Custom-Build

If you do not trust me (and there is no reason in doing so) you may read the sources `sshkeysfs` and `rpssh` and build
the container on your own:

```bash
git pull https://github.com/steigr/sshkeysfs.git
docker build -t ssh-reverse-proxy .
sudo modprobe fuse
docker run \
  --rm -ti \
  -p 22:22 \
  -v /users.yml:/users.yaml \
  --env MAP_URI=/users.yml \
  --device /dev/fuse \
  --cap-add SYS_ADMIN \
	ssh-reverse-proxy
```

### Remote Datasource

MAP_URI may point to any YAML-File which ruby's `open-uri` may read.

### YAML-Format

```yaml
- name: user
  target: 127.0.0.1:2220
  keys:
  - ssh-rsa ...

## The problem

In the container-age ssh access to server is unevitable. The SSH-Protocol lacks somthing like
the HTTP-`Host`-Header which may router requests to some backend machine or container.

## Conventional solutions

There are two ways make something like a reverse-proxy for ssh.

### Enlightened client

Pimp your `~/.ssh/config` with ProxyCommand. Your client must be aware of the (rapidly) changing
IP-address of the target-server.

### Enlightened Proxy

Pimp your `~/.ssh/authorized_keys` with the `command="..."`-option and forward authenticated connections
to the target machine. The proxy must be aware of the target machine's IP-address.
( sshkeyfs uses this solution ).

## Wishlist

Something which indicates the target-machine before authentication.
This is rather problematic because of possible DDoS-attacks.

## TODO

At the moment the target-machine is implicitly defined via username. A mapping via give public-key is possible
but not yet implemented.

## Security

`sshkeysfs` provide `/etc/passwd`-File for the proxy-machine and an `authorized_keys`-file as well as an `config`-file
per User. There are only ssh public keys, IP-addresses and usernames. The SSH-Connection uses AgentForwarding, thus no
private data will be exposed for authentication or routing.