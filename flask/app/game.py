from flask import (
    Blueprint, flash, g, redirect, render_template, request, url_for
)

# from app.db import get_db
from qiskit import *
from qiskit import Aer

bp = Blueprint('game', __name__)

@bp.route('/')
def mainMenu():
    circ = QuantumCircuit(3)
    # Add a H gate on qubit 0, putting this qubit in superposition.
    circ.h(0)
    # Add a CX (CNOT) gate on control qubit 0 and target qubit 1, putting
    # the qubits in a Bell state.
    circ.cx(0, 1)
    # Add a CX (CNOT) gate on control qubit 0 and target qubit 2, putting
    # the qubits in a GHZ state.
    circ.cx(0, 2)

    circ.draw()

    # Run the quantum circuit on a statevector simulator backend
    backend = Aer.get_backend('statevector_simulator')

    # Create a Quantum Program for execution
    job = execute(circ, backend)

    result = job.result()

    outputstate = result.get_statevector(circ, decimals=3)
    print(outputstate);
    return render_template('mainMenu.html')