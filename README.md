# TrustVPN

OpenVPN docker container

## API

```
o-client-create <user name> <profile name>
```
Creates profile (key pair) for ```<user name>```,  links personal configuration to ```<profile name>```

```
o-clent-get <user name>
```
Outputs to stdout personal OpenVPN configuration file for ```<user name>```

```
o-clent-modify <user name> <profiles>
```
Links ```<user name>``` personal configuration to ```<profile name>```

```
o-clent-remove <user name>
```
Removes profile for ```<user name>```, i.e.: revokes key, removes personal configuration
