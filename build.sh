#!/bin/bash -e
# Install script for x64

VERSION="2106.1-8.3.1-18435609"

echo "Performing main extract"

MAIN_DIR="MainFiles"
mkdir $MAIN_DIR

tar -xf "VMware-Horizon-Linux.tar.gz" -C $MAIN_DIR --strip-components 1


#echo "Extracting client"

#tar -xf "$MAIN_DIR/x64/VMware-Horizon-Client-${VERSION}.x64.tar.gz"  -C /app/ --strip-components 1

#echo "Extracting sdk"

#tar -xf "$MAIN_DIR/x64/VMware-Horizon-Client-Linux-ClientSDK-${VERSION}.x64.tar.gz" -C /app/ --strip-components 1

echo "Extracting Everything"

cd $MAIN_DIR/x64/
for f in *; do tar -xf "$f" -C /app/ --strip-components 1; done
cd ..

echo "Installing images etc"

mkdir -p "/app/share/icons/hicolor/82x82/"
mv "/app/share/icons/vmware-view.png" "/app/share/icons/hicolor/82x82/com.vmware.HorizonClient.png"

mv "/app/share/applications/vmware-view.desktop" "/app/share/applications/com.vmware.HorizonClient.desktop"

echo "Modifying vmware files"


sed -i 's+/usr/share/icons/vmware-view.png+com.vmware.HorizonClient+' "/app/share/applications/com.vmware.HorizonClient.desktop"
sed -i 's/\/usr/\/app/' "/app/bin/vmware-view"

sed -i 's+vm_append_to_library_path "$html5mmrlibPath"+vm_append_to_library_path "$html5mmrlibPath"\n   vm_append_to_library_path "/app/lib"+' "/app/bin/vmware-view"

sed -i 's/\/usr/\/app/' "/app/bin/vmware-view-lib-scan"
sed -i 's/\/usr/\/app/' "/app/bin/vmware-url-filter"
sed -i 's/\/usr/\/app/' "/app/bin/vmware-view-log-collector"

sed -i 's+/usr+/app+' "/app/lib/vmware/view/bin/vmware-view" # Relink the main binary
sed -i 's+/usr+/app+' "/app/lib/vmware/view/env/env_utils.sh"
sed -i 's+/usr+/app+' "/app/lib/vmware/view/dct/vmware-view-log-collector"
sed -i 's+/usr+/app+' "/app/lib/vmware/view/dct/configFiles/Client.json"
sed -i 's+/usr+/app+' "/app/lib/vmware/view/dct/configFiles/Virtual_Channel/VDPService.json"

# Relink the compiled libraries
for f in `find /app/lib/vmware/ -not -type d`
do
	sed -i 's+/usr+/app+' "$f"
	sed -i 's+/usr+/app+' "$f"
	sed -i 's+/usr+/app+' "$f"
done

for f in /app/lib/vmware/view/dct/configFiles/Remote_Features/*;
do
	sed -i 's/\/usr/\/app/' "$f"
done

chmod +775 "/app/lib/vmware/libjson_linux-gcc-4.1.1_libmt.so"

echo "Linking"
cd /app/lib/
ln -s libudev.so.1 libudev.so.0
cd

echo "Clean up"
rm -rf "VMware-Horizon-Client-Linux-${VERSION}"*

echo "Complete"
