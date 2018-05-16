# Mbed OS + FRDM-K64F + NXP FRDM-K64F + Avnet AT&T IoT Starter Kit WNC 14A2A cellular + Mbed Cloud Client Public

Build the base container and the example container

`docker-compose -f resources/mbed_os_dev.yml -f examples/mbed-cloud-client-example/mbedos_k64f_avnet_cellular_wnc14a2a/compose.yml up -d`

Run the example container which does one full firmware build including the bootloader and one upgrade image that can be used for a campaign

Watch the active log while the container is building and running

`docker logs -f mbedos_k64f_avnet_cellular_wnc14a2a`

Destroy the container and keep the base mbed_os_dev image

`docker-compose -f resources/mbed_os_dev.yml -f examples/mbed-cloud-client-example/mbedos_k64f_avnet_cellular_wnc14a2a/compose.yml down`

This will give you the following files:

    *firmware applicaiton that increments a resource connected to mbed cloud*
    share/${EPOCH_TIME}_mbed-cloud-client-example.bin

This will give you the following files in a <mark>./share/</mark> directory:

    *combined application + bootloader*
    ${EPOCH_TIME}-combined.bin

    *upgrade application only with red led on*
    ${EPOCH_TIME}-combined.bin

##### Debugging or ad-hoc usage of the container

Get a shell in to the running container to poke around

`docker exec -it mbedos_k64f_avnet_cellular_wnc14a2a bash`