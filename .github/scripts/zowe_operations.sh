#!/bin/bash
# zowe_operations.sh

# Convert username to lowercase
LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')
# Check if directory exists, create if it doesn't
if ! zowe zos-files list uss-files "/z/$LOWERCASE_USERNAME/cobolcheck" &>/dev/null; then
    echo "Directory does not exist. Creating it..."
    zowe zos-files create uss-directory /z/$LOWERCASE_USERNAME/cobolcheck
else
    echo "Directory already exists."
fi

# Check if cbl directory exists, create if it doesn't
if ! zowe zos-files list uss-files "/z/$LOWERCASE_USERNAME/cbl" &>/dev/null; then
    echo "Directory cbl does not exist. Creating it..."
    zowe zos-files create uss-directory /z/$LOWERCASE_USERNAME/cbl
else
    echo "Directory cbl already exists."
fi
zowe zos-files issue ssh "chmod 777 /z/$LOWERCASE_USERNAME/cbl"

# Upload files
zowe zos-files upload dir-to-uss "./cobol-check" "/z/$LOWERCASE_USERNAME/cobolcheck" --recursive --binary-files "bin/cobol-check-0.2.16.jar"

#zowe zos-files upload file-to-uss "./cobol-check/bin/cobol-check-0.2.16.jar" "/z/$LOWERCASE_USERNAME/cobolcheck/bin/cobol-check-0.2.16.jar" --binary
#zowe zos-files upload dir-to-uss "./cobol-check" "/z/$LOWERCASE_USERNAME/cobolcheck" --recursive "bin/cobol-check-0.2.16.jar" --binary
#zowe zos-files upload file-to-uss cobol-check-0.2.16.jar "/z/z53746/cobolcheck/bin/cobol-check-0.2.16.jar" --binary

#zowe zos-files upload dir-to-uss "./cobol-check/scripts" "/z/$LOWERCASE_USERNAME/cobolcheck/scripts" --recursive
zowe zos-files upload dir-to-uss ./cobol-check/scripts /z/z53746/cobolcheck/scripts --recursive --encoding UTF-8 --binary false
#zowe zos-files upload dir-to-uss "./cobol-check/scripts" "/z/$LOWERCASE_USERNAME/cobolcheck/scripts" --recursive --text-files "*"

#zowe zos-files upload dir-to-uss "./cobol-check/src" "/z/$LOWERCASE_USERNAME/cobolcheck/src" --recursive
#zowe zos-files upload dir-to-uss "./cobol-check/src" "/z/$LOWERCASE_USERNAME/cobolcheck/src" --recursive --text-files "*"
zowe zos-files upload dir-to-uss "./cobol-check/src" "/z/$LOWERCASE_USERNAME/cobolcheck/src" --recursive --encoding UTF-8 --binary false

zowe zos-files upload dir-to-uss "./temp" "/z/$LOWERCASE_USERNAME/temp" --recursive --encoding UTF-8 --binary false

# Verify upload
echo "Verifying upload:"
zowe zos-files list uss-files "/z/$LOWERCASE_USERNAME/cobolcheck"
