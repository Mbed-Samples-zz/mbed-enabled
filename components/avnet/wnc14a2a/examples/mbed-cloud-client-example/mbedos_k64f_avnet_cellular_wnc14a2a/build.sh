#!/bin/sh

echo "Create epoch time file /root/epoch_time.txt"
date +%s > /root/epoch_time.txt
EPOCH_TIME=$(cat /root/epoch_time.txt)

MBED_CLOUD_VERSION=1.3.1.1
MBED_CLOUD_UPDATE_EPOCH=0
MBED_CLOUD_MANIFEST_TOOL_VERSION=master

MBED_OS_VERSION=master
MBED_OS_COMPILER=GCC_ARM

TARGET_NAME=K64F

CLIENT_GITHUB_REPO="mbed-cloud-client-example"

GITHUB_URI="https://github.com/ARMmbed"

FIRST_IMAGE_NAME=${EPOCH_TIME}.${TARGET_NAME}.WIFI

echo "---> Make Source Download dirs"
mkdir -p /root/Source /root/Download/manifest_tool

######################### MANIFEST TOOL #########################

echo "---> Install mbed cloud client tools"
pip install git+${GITHUB_URI}/manifest-tool.git@${MBED_CLOUD_MANIFEST_TOOL_VERSION}

echo "---> cd /root/Download/manifest_tool"
cd /root/Download/manifest_tool

echo "---> Initialize manifest tool"
manifest-tool init -d "mbed.quickstart.company" -m "qs v1" -q --force -a ${MBED_CLOUD_API_KEY1}

echo "---> Install mbed-cloud-sdk"
pip install mbed-cloud-sdk

echo "---> Create .mbed_cloud_config.json"
cp /root/Config/.mbed_cloud_config.json /root/.mbed_cloud_config.json

echo "---> Add api key to .mbed_cloud_config.json"
jq '.api_key = "'${MBED_CLOUD_API_KEY}'"' /root/.mbed_cloud_config.json | sponge /root/.mbed_cloud_config.json

######################### APPLICATION #########################

echo "---> cd /root/Source"
cd /root/Source

echo "---> Clone ${GITHUB_URI}/${CLIENT_GITHUB_REPO}"
git clone ${GITHUB_URI}/${CLIENT_GITHUB_REPO}.git

echo "---> cd /root/Source/${CLIENT_GITHUB_REPO}"
cd /root/Source/${CLIENT_GITHUB_REPO}

echo "---> Run mbed deploy ${MBED_CLOUD_VERSION}"
mbed deploy ${MBED_CLOUD_VERSION}

echo "---> Run mbed update ${MBED_CLOUD_VERSION}"
mbed update ${MBED_CLOUD_VERSION}

echo "---> cp /root/Download/manifest_tool/update_default_resources.c"
cp /root/Download/manifest_tool/update_default_resources.c .

echo "---> Copy mbed_cloud_dev_credentials.c to project"
cp /root/Creds/mbed_cloud_dev_credentials.c .

echo "---> Copy standard mbed_app.json config"
cp configs/eth_v4.json mbed_app.json

# echo "---> Enable mbed-trace.enable in mbed_app.json"
# jq '.target_overrides."*"."mbed-trace.enable" = 1' mbed_app.json | sponge mbed_app.json

echo "---> Change LED blink to LED1 in mbed_app.json"
jq '.config."led-pinname"."value" = "LED1"' mbed_app.json | sponge mbed_app.json

# https://github.com/Avnet/wnc14a2a-driver/#90928b81747ef4b0fb4fdd94705142175e014b30

echo "---> Set up WNC config in mbed_app.json"
jq '.config."network-interface"."value" = "CELLULAR_WNC14A2A"' mbed_app.json | sponge mbed_app.json

echo "---> Enable increase drivers.uart-serial-txbuf-size mbed_app.json"
jq '.target_overrides."*"."drivers.uart-serial-txbuf-size" = 4096' mbed_app.json | sponge mbed_app.json
jq '.target_overrides."*"."drivers.uart-serial-rxbuf-size" = 4096' mbed_app.json | sponge mbed_app.json

echo "---> Set up WNC debug in mbed_app.json"
jq '.config."wnc_debug"."value" = 0' mbed_app.json | sponge mbed_app.json
jq '.config."wnc_debug_setting"."value" = 4' mbed_app.json | sponge mbed_app.json

# latest from master as of 2018/05/16
echo "---> Add latest easy-connect"
cd easy-connect && mbed update 21a78a40e94ba9298e05ce54738c6b42657ae010 && cd ..

echo "---> Compile first mbed client"
mbed compile -m ${TARGET_NAME} -t ${MBED_OS_COMPILER} --profile release >> ${EPOCH_TIME}-mbed-compile-client.log

echo "---> Combine bootloader with application"
cd tools && python combine_bootloader_with_app.py -m k64f -b mbed-bootloader-k64f-block_device-sotp-v3_3_0.bin -a .././BUILD/${TARGET_NAME}/${MBED_OS_COMPILER}/mbed-cloud-client-example.bin -o ../${EPOCH_TIME}-combined.bin && cd ..

echo "---> Copy the final binary to the share directory"
cp ${EPOCH_TIME}-combined.bin /root/Share/${EPOCH_TIME}-combined.bin

echo "---> Code change for upgrade image"
sed -r -i -e 's/static DigitalOut led\(MBED_CONF_APP_LED_PINNAME, LED_OFF\);/static DigitalOut led(MBED_CONF_APP_LED_PINNAME, LED_ON);/' source/platform/mbed-os/common_button_and_led.cpp

echo "---> Compile upgrade image"
mbed compile -m ${TARGET_NAME} -t ${MBED_OS_COMPILER} --profile release >> ${EPOCH_TIME}-mbed-compile-client.log

echo "---> Copy upgrade image to share ${EPOCH_TIME}-upgrade.bin"
cp BUILD/${TARGET_NAME}/${MBED_OS_COMPILER}/mbed-cloud-client-example_application.bin /root/Share/${EPOCH_TIME}-upgrade.bin

echo "---> Copy build log to /root/Share"
cp ${EPOCH_TIME}-mbed-compile-client.log /root/Share/

echo "---> Run upgrade campaign using manifest tool"
echo "cd /root/Download/manifest_tool"
echo "manifest-tool update device -p /root/Share/${EPOCH_TIME}-upgrade.bin -D my_connected_device_id"

echo "---> Keeping the container running with a tail of the build logs"
tail -f /root/epoch_time.txt
