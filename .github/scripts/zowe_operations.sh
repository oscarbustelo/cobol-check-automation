#!/bin/bash
# zowe_operations.sh
# Convert username to lowercase
LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')
# Definir perfil de Zowe (ajusta si usas otro perfil)
ZOSMF_PROFILE="zosmf"
# Check if directory exists, create if it doesn't
if ! zowe zos-files list uss-files "/z/$LOWERCASE_USERNAME/cobolcheck" --zosmf-profile $ZOSMF_PROFILE &>/dev/null; then
    echo "Directory does not exist. Creating it..."
    zowe zos-files create uss-directory "/z/$LOWERCASE_USERNAME/cobolcheck" --zosmf-profile $ZOSMF_PROFILE
else
    echo "Directory already exists."
fi
# Upload files
# Subir el directorio sin marcarlo como binario (archivos de texto normales)
zowe zos-files upload dir-to-uss "./cobol-check" "/z/$LOWERCASE_USERNAME/cobolcheck" --recursive --zosmf-profile zosmf
# Subir el .jar como binario
zowe zos-files upload file-to-uss "./cobol-check/cobol-check-0.2.9.jar" "/z/$LOWERCASE_USERNAME/cobolcheck/cobol-check-0.2.9.jar" --binary --zosmf-profile zosmf
# Verify upload
echo "Verifying upload:"
zowe zos-files list uss-files "/z/$LOWERCASE_USERNAME/cobolcheck" --zosmf-profile $ZOSMF_PROFILE
# adaptado a zowe v 3
