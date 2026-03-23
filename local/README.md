# Local Setup

## Preparation

1. Create `backend.star`:

```
load("@builtin//struct.star", "module")

def __platform_properties(ctx):
    return {
        "default": {
            "OSFamily": "Linux",
        },
        "large": {},
    }

backend = module(
    "backend",
    platform_properties = __platform_properties,
)
```

2. Update `.gclient`:

Add the following to the `custom_vars` section:

```
"reapi_instance": "shard",
"reapi_address": "localhost:8980",
"reapi_backend_config_path": "path_to_your_backend.star"
```

3. Run `glient sync`.

4. Add `use_remoteexec = true` to `out/Default/args.gn` and re-run gn generation.

5. Create `src/build/config/siso/.sisorc`:

```
ninja --reapi_grpc_conn_pool=1 --reapi_keep_exec_stream
```

## Usage

1. For the simple proof of concept, just do port forward with `ssh`:

```sh
ssh -L 8980:localhost:8980 -L 9090:localhost:9090 -L 9091:localhost:9091 user@remote-server
```

2. Inside `src`, Run

```
# No need to authentication over SSH
export RBE_service_no_security=true

autoninja -C out/Default $TARGET
```
