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
# Upload files
zowe zos-files upload dir-to-uss "./cobol-check" "/z/$LOWERCASE_USERNAME/cobolcheck" --recursive --binary-files "bin/cobol-check-0.2.16.jar"
#zowe zos-files upload file-to-uss cobol-check-0.2.16.jar "/z/z53746/cobolcheck/bin/cobol-check-0.2.16.jar" --binary

#zowe zos-files upload dir-to-uss "./cobol-check/scripts" "/z/$LOWERCASE_USERNAME/cobolcheck/scripts" --recursive
zowe zos-files upload dir-to-uss ./cobol-check/scripts /z/z53746/cobolcheck/scripts --recursive --encoding UTF-8 --binary false
#zowe zos-files upload dir-to-uss "./cobol-check/scripts" "/z/$LOWERCASE_USERNAME/cobolcheck/scripts" --recursive --text-files "*"

#zowe zos-files upload dir-to-uss "./cobol-check/src" "/z/$LOWERCASE_USERNAME/cobolcheck/src" --recursive
#zowe zos-files upload dir-to-uss "./cobol-check/src" "/z/$LOWERCASE_USERNAME/cobolcheck/src" --recursive --text-files "*"
zowe zos-files upload dir-to-uss "./cobol-check/src" "/z/$LOWERCASE_USERNAME/cobolcheck/src" --recursive --encoding UTF-8 --binary false


# Verify upload
echo "Verifying upload:"
zowe zos-files list uss-files "/z/$LOWERCASE_USERNAME/cobolcheck"
