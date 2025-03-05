#!/bin/bash
# mainframe_operations.sh

# Set up environment
export PATH=$PATH:/usr/lpp/java/J8.0_64/bin
export JAVA_HOME=/usr/lpp/java/J8.0_64
export PATH=$PATH:/usr/lpp/zowe/cli/node/bin

# Verificar ubicación correcta de Zowe CLI
if ! command -v zowe &>/dev/null; then
    echo "Error: Zowe CLI no está en el PATH. Verifica su instalación."
    exit 1
fi

# Check Java availability
java -version

# Set ZOWE_USERNAME
ZOWE_USERNAME="Z53746" # Reemplaza con el usuario real

# Cambiar a la carpeta cobolcheck
cd cobolcheck || { echo "Error: No se pudo encontrar el directorio cobolcheck"; exit 1; }
echo "Changed to $(pwd)"
ls -al

# Verificar que cobolcheck es un .jar y ejecutarlo correctamente
if [ ! -f "cobolcheck-0.2.9.jar" ]; then
    echo "Error: No se encontró cobolcheck-0.2.9.jar"
    exit 1
fi

# Hacer ejecutables los scripts
chmod +x scripts/linux_gnucobol_run_tests
echo "Made linux_gnucobol_run_tests executable"

# Función para ejecutar cobolcheck y copiar archivos
run_cobolcheck() {
    program=$1
    echo "Running cobolcheck for $program"
    
    # Ejecutar cobolcheck con Java
    java -jar cobolcheck-0.2.9.jar -p "$program"
    echo "Cobolcheck execution completed for $program (exceptions may have occurred)"

    # Subir CC##99.CBL al dataset si existe
    if [ -f "CC##99.CBL" ]; then
        zowe zos-files upload file-to-data-set "CC##99.CBL" "${ZOWE_USERNAME}.CBL($program)" --zosmf-profile zosmf && \
        echo "Copied CC##99.CBL to ${ZOWE_USERNAME}.CBL($program)" || \
        echo "Failed to copy CC##99.CBL to ${ZOWE_USERNAME}.CBL($program)"
    else
        echo "CC##99.CBL not found for $program"
    fi

    # Subir el JCL si existe
    if [ -f "${program}.JCL" ]; then
        zowe zos-files upload file-to-data-set "${program}.JCL" "${ZOWE_USERNAME}.JCL($program)" --zosmf-profile zosmf && \
        echo "Copied ${program}.JCL to ${ZOWE_USERNAME}.JCL($program)" || \
        echo "Failed to copy ${program}.JCL to ${ZOWE_USERNAME}.JCL($program)"
    else
        echo "${program}.JCL not found"
    fi
}

# Ejecutar la función para cada programa
for program in NUMBERS EMPPAY DEPTPAY; do
    run_cobolcheck "$program"
done

echo "Mainframe operations completed"
