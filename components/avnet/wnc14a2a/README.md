# Sequence

- Clone repo with Dockerfile(s) and Compose files
- Build containers with Compose
- Run containers (Mbed OS development container, Firmware upgrade build container)
- Use the generated binaries to run through the upgrade process

## Prepare your environment and credentials

Create/copy your Arm Mbed Cloud mbed_cloud_dev_credentials.c in the `./creds/` subdirectory

**mbed_cloud_dev_credentials.c**

&nbsp;&nbsp;&nbsp;&nbsp;Downloaded from the [portal](https://portal.us-east-1.mbedcloud.com)

**.env**

Update the Docker Compose environment file `./.env` and add the following contents

```
    MBED_CLOUD_API_KEY1=my1_mbed_cloud_api_key_for_us_east
```

- MBED_CLOUD_API_KEY# is used by the manifest-tool and cURL when setting up a RESTful upgrade

## Docker Compose

Tested with the following:

<mark>Docker version 18.03.1-ce, build 9ee9f40</mark>

<mark>docker-compose version 1.21.1, build 5a3f1a3</mark>

<mark>System Version: macOS 10.13.4 (17E202)</mark>

<mark>Kernel Version: Darwin 17.5.0</mark>

Build containers for Mbed development and cloud client firmware upgrade images.
See each example folder for the Compose command syntax.  Note they should all be executed
from this directory context.


[examples/mbed-cloud-client-example/mbedos_k64f_avnet_cellular_wnc14a2a](examples/mbed-cloud-client-example/mbedos_k64f_avnet_cellular_wnc14a2a/README.md)

[mbed_os_dev](resources/README.md)