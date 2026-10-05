#!/bin/bash
PYTHON=python3
venv=".venv"
esphome="esphome"

CPU_CORES="0,1,2,3,4,5,6,7,8"   # <-- adjust to however many cores you want to allow



if [ ! -d "${venv}" ]; then
    echo "Creating virtual environment at ${venv}"
    rm -rf "${venv}"
    "${PYTHON}" -m venv "${venv}"
    source "${venv}/bin/activate"

else
    source "${venv}/bin/activate"
fi

# Install Python dependencies
echo 'Installing Python dependencies'
pip3 install --upgrade pip
pip3 install -r requirements.txt

# --- CPU-limited esphome wrapper ---
REAL_ESPHOME="${venv}/bin/esphome"
WRAPPER="${venv}/bin/esphome-wrapped"

if [ -f "${REAL_ESPHOME}" ] && [ ! -f "${WRAPPER}" ]; then
    mv "${REAL_ESPHOME}" "${WRAPPER}"
    cat > "${REAL_ESPHOME}" <<EOF
#!/bin/bash
exec taskset -c ${CPU_CORES} "\$(dirname "\$0")/esphome-wrapped" "\$@"
EOF
    chmod +x "${REAL_ESPHOME}"
    echo "esphome wrapped with taskset -c ${CPU_CORES}"
fi
