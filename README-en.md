# TrustVPN

OpenVPN docker container for trustvpn projects
This is a small wrap up of ```kylemanna/openvpn```, nothing more

## Configuration and initalization

User profiles are defined by files in app/profiles folder. File names shall match profile names as operated by openvpn-backend. Should you need to alter/add profiles you will need to rebuild container or modify container internals.

The name ```blocked``` is reserved for blocked users. It should not be used as a profile name. It is not controlled but will break blocking logic.

Container shall be initialized with the following command:
```
docker run -rm -v <Path to OpenVPN configuration folder>:/etc/openvpn trustvpn-container bash -c "trustvpn-container-config -u <host name>"
```

## API

API calls are actually bash scripts that shall be executed inside container after its initialization, i.e.: something like
```
docker run -rm -v <Path to OPneVPN configuration folder>:/etc/openvpn trustvpn-container bash -c "<API call with parameters>"
```
Please refer to ```tests api-tests.sh``` for examples

All API calls return 0 on success, 1 in case of error. Additionally ```create\modify\block\remove``` output end output with ```" == OK == "``` in case of success.

```
trustvpn-client-create <user name> <profile name>
```
Sets up access for ```<user name>```,  links personal configuration to ```<profile name>```

```
trustvpn-client-get <user name>
```
Outputs to ```stdout``` personal OpenVPN configuration file for ```<user name>```

```
trustvpn-client-modify <user name> <profiles>
```
Links ```<user name>``` personal configuration to ```<profile name>```

```
trustvpn-client-block <user name>
```
Blocks profile for ```<user name>```, i.e.:  removes personal configuration from ```ccd``` folder but does not revoke the key

```
trustvpn-client-remove <user name>
```
Removes profile for ```<user name>```, i.e.: revokes key, removes personal configuration
