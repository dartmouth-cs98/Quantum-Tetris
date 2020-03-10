#!/bin/bash

pip install flask
pip install flask-cors
pip install sqlalchemy
pip install flask_sqlalchemy
pip install flask_script
pip install flask_migrate
pip install psycopg2
export FLASK_APP=application
export FLASK_ENV=development
export MAX_QUBITS=5
export MACHINE_NAME="qasm_simulator"
export DATABASE_URL="postgresql://localhost/quantum_tetris"
export PORT=5000
export APP_SETTINGS="config.DevelopmentConfig"
rm -rf migrations
python -m application.manage db init
python -m application.manage db migrate
python -m application.manage db upgrade
python -m application.manage runserver
