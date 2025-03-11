#!/bin/bash
# zowe_operations.sh

# Convertir a minúsculas
LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')

# Verificar si el path correcto es con 'Z' mayúscula
if zowe zos-uss issue ssh "ls /Z/$LOWERCASE_USERNAME" &>/dev/null; then
    USS_PATH="/Z/$LOWERCASE_USERNAME"
else
    USS_PATH="/z/$LOWERCASE_USERNAME"
fi

echo "-------------------------> "$USS_PATH

# Convert username to lowercase
#LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')
# Check if directory exists, create if it doesn't

if ! zowe zos-files list uss-files "$USS_PATH/cobolcheck" &>/dev/null; then
    echo "Directory does not exist. Creating it..."
    zowe zos-files create uss-directory $USS_PATH/cobolcheck
else
    echo "Directory already exists."
fi

# Check if cbl directory exists, create if it doesn't
if ! zowe zos-files list uss-files "$USS_PATH/cbl" &>/dev/null; then
    echo "Directory cbl does not exist. Creating it..."
    zowe zos-files create uss-directory $USS_PATH/cbl
else
    echo "Directory cbl already exists."
fi

zowe zos-uss issue ssh "chmod 777 $USS_PATH/cbl"

# Upload files
zowe zos-files upload dir-to-uss "./cobol-check" "$USS_PATH/cobolcheck" --recursive --binary-files "bin/cobol-check-0.2.16.jar"

#zowe zos-files upload file-to-uss "./cobol-check/bin/cobol-check-0.2.16.jar" "/z/$LOWERCASE_USERNAME/cobolcheck/bin/cobol-check-0.2.16.jar" --binary
#zowe zos-files upload dir-to-uss "./cobol-check" "/z/$LOWERCASE_USERNAME/cobolcheck" --recursive "bin/cobol-check-0.2.16.jar" --binary
#zowe zos-files upload file-to-uss cobol-check-0.2.16.jar "/z/z53746/cobolcheck/bin/cobol-check-0.2.16.jar" --binary

#zowe zos-files upload dir-to-uss "./cobol-check/scripts" "/z/$LOWERCASE_USERNAME/cobolcheck/scripts" --recursive
zowe zos-files upload dir-to-uss ./cobol-check/scripts /z/z53746/cobolcheck/scripts --recursive --encoding UTF-8 --binary false
#zowe zos-files upload dir-to-uss "./cobol-check/scripts" "/z/$LOWERCASE_USERNAME/cobolcheck/scripts" --recursive --text-files "*"

#zowe zos-files upload dir-to-uss "./cobol-check/src" "/z/$LOWERCASE_USERNAME/cobolcheck/src" --recursive
#zowe zos-files upload dir-to-uss "./cobol-check/src" "/z/$LOWERCASE_USERNAME/cobolcheck/src" --recursive --text-files "*"
zowe zos-files upload dir-to-uss "./cobol-check/src" "$USS_PATH/cobolcheck/src" --recursive --encoding UTF-8 --binary false

zowe zos-files upload dir-to-uss "./temp" "$USS_PATH/temp" --recursive --encoding UTF-8 --binary false

# Verify upload
echo "Verifying upload:"
zowe zos-files list uss-files "$USS_PATH/cobolcheck"
