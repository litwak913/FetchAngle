#!/bin/bash

echo "Downloading"
curl -s "https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json" | jq -r ".channels.Stable.downloads.chrome[].url" | parallel wget {}

echo "Extract"
OLDIFS="$IFS"
IFS=$'\n'
macX64ANGLE=(`unzip -Z1 chrome-mac-x64.zip | grep GL`)
macARMANGLE=(`unzip -Z1 chrome-mac-arm64.zip | grep GL`)
winX32ANGLE=(`unzip -Z1 chrome-win32.zip | grep GL`)
winX64ANGLE=(`unzip -Z1 chrome-win64.zip | grep GL`)
IFS="$OLDIFS"
rm -rf windows32 windows64 macosx64 macosarm64

mkdir windows32 windows64 macosx64 macosarm64

unzip -j chrome-mac-x64.zip "${macX64ANGLE[0]}" -d macosx64
unzip -j chrome-mac-x64.zip "${macX64ANGLE[1]}" -d macosx64

unzip -j chrome-mac-arm64.zip "${macARMANGLE[0]}" -d macosarm64
unzip -j chrome-mac-arm64.zip "${macARMANGLE[1]}" -d macosarm64


for i in ${winX32ANGLE[@]}; do
unzip -j chrome-win32.zip "$i" -d windows32 
done

for i in ${winX64ANGLE[@]}; do
unzip -j chrome-win64.zip "$i" -d windows64
done

echo "Packaging"
printf "# SHA256\n\`\`\`\n" > $GITHUB_STEP_SUMMARY
for s in **/lib*; do
echo `sha256sum $s` >> $GITHUB_STEP_SUMMARY
done
printf "\n\`\`\`\n" >> $GITHUB_STEP_SUMMARY

zip -9 -r angle.zip windows32 windows64 macosx64 macosarm64
