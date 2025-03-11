#!/bin/bash
# mainframe_operations.sh
# Set up environment
export PATH=$PATH:/usr/lpp/java/J8.0_64/bin
export JAVA_HOME=/usr/lpp/java/J8.0_64
export PATH=$PATH:/usr/lpp/zowe/cli/node/bin
# Check Java availability
java -version
# Set ZOWE_USERNAME
ZOWE_USERNAME="Z53746" # Replace with the actual username

export ZOWE_USERNAME=z53746

# Change to the cobolcheck directory
cd cobol-check
echo "Changed to $(pwd)"
ls -al
# Make cobolcheck executable
chmod +x cobolcheck
echo "Made cobolcheck executable"
# Make script in scripts directory executable
cd scripts
chmod +x linux_gnucobol_run_tests
echo "Made linux_gnucobol_run_tests executable"
cd ..
# Function to run cobolcheck and copy files 

run_cobolcheck() {
    program=$1
    echo "Running cobolcheck for $program"
    # Run cobolcheck, but don't exit if it fails
    ./cobolcheck -p $program
    echo "Cobolcheck execution completed for $program (exceptions may have occurred)"
    # Check if CC##99.CBL was created, regardless of cobolcheck exit status

    if [ -f "CC##99.CBL" ]; then
        # Copy to the MVS dataset
        if cp "CC##99.CBL" "${ZOWE_USERNAME}.cbl(${program})"; then
            echo "Copied CC##99.CBL to ${ZOWE_USERNAME}/cbl/${program}.CBL"
        else
            echo "Failed to copy CC##99.CBL to ${ZOWE_USERNAME}/cbl/${program}.CBL"
        fi
    else
        echo "CC##99.CBL not found for $program"
    fi    
    
    # Subir el JCL si existe
    #if [ -f "${program}.JCL" ]; then
    if [ -f "../temp/${program}.JCL" ]; then
    #   Copiar el archivo JCL a la carpeta USS

        if cp "../temp/${program}.JCL" "/z/${ZOWE_USERNAME}.JCL(${program})"; then
            echo "Copied ${program}.JCL to /z/z53746/jcl/${program}.JCL"
        else
            echo "Failed to copy ${program}.JCL to /z/z53746/jcl/${program}.JCL"
        fi

    
    #    zowe zos-files upload file-to-data-set "../temp/${program}.JCL" "${ZOWE_USERNAME}.JCL($program)" --zosmf-profile zosmf && \
    #    echo "Copied ${program}.JCL to ${ZOWE_USERNAME}.JCL($program)" || \
    #    echo "Failed to copy ${program}.JCL to ${ZOWE_USERNAME}.JCL($program)"
    else
        echo "${program}.JCL not found ../temp"
    fi

}

# Run for each program
for program in NUMBERS EMPPAY DEPTPAY; do
    run_cobolcheck $program
done
echo "Mainframe operations completed"
