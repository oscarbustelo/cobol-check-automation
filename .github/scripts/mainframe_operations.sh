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

# Capturar el directorio actual
BASE_DIR=$(pwd)

# Construir la ruta completa del JAR
JAR_PATH="$BASE_DIR/COBOL-CHECK/bin/cobol-check-0.2.9.jar"

# Construir la ruta del config.properties
JAR_PATH_CONF="$BASE_DIR/COBOL-CHECK/config.properties"

# Construir la ruta del linux_gnucobol_run_tests
JAR_PATH_LIN="$BASE_DIR/COBOL-CHECK/scripts/linux_gnucobol_run_tests"

# Mostrar las rutas para depuración
echo "Usando JAR en: $JAR_PATH"
echo "Usando config en: $JAR_PATH_CONF"
echo "Usando linux_gnucobol_run_tests en: $JAR_PATH_LIN"

# Verificar que el JAR existe
if [ ! -f "$JAR_PATH" ]; then
    echo "Error: No se encontró cobolcheck-0.2.9.jar en $JAR_PATH"
    exit 1
fi

# Verificar que el config existe
if [ ! -f "$JAR_PATH_CONF" ]; then
    echo "Error: No se encontró config.properties en $JAR_PATH_CONF"
    exit 1
fi

# Verificar que el linux_gnucobol_run_tests existe
if [ ! -f "$JAR_PATH_LIN" ]; then
    echo "Error: No se encontró linux_gnucobol_run_tests en $JAR_PATH_LIN"
    exit 1
fi

# Hacer ejecutables los scripts
# chmod +x scripts/linux_gnucobol_run_tests
chmod +x "$JAR_PATH_LIN"
echo "Made linux_gnucobol_run_tests executable"

# Ejecutar el JAR
# java -jar "$JAR_PATH" -p "$program"
java -Dconfig.file="$JAR_PATH_CONF" -jar "$JAR_PATH" -p "$program"

# Función para ejecutar cobolcheck y copiar archivos
run_cobolcheck() {
    program=$1
    echo "Running cobolcheck for $program"
    
    # Ejecutar cobolcheck con Java
#   java -jar "$JAR_PATH" -p "$program"
    java -Dconfig.file="$JAR_PATH_CONF" -jar "$JAR_PATH" -p "$program"
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
