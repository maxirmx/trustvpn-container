# TrustVPN

OpenVPN docker container

## API

```
trustvpn-client-create <user name> <profile name>
```
Creates profile (key pair) for ```<user name>```,  links personal configuration to ```<profile name>```

```
trustvpn-client-get <user name>
```
Outputs to stdout personal OpenVPN configuration file for ```<user name>```

```
trustvpn-client-modify <user name> <profiles>
```
Links ```<user name>``` personal configuration to ```<profile name>```

```
trustvpn-client-block <user name>
```
Blocks profile for ```<user name>```, i.e.:  removes personal configuration from ccd folder but does not revoke the key

```
trustvpn-client-remove <user name>
```
Removes profile for ```<user name>```, i.e.: revokes key, removes personal configuration


trustvpn-container-config -u $HOST
