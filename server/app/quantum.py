from werkzeug.exceptions import abort

from flask import make_response, jsonify
from qiskit import *
from qiskit import Aer

class Quantum():
	def __init__(self, db):
		self.db = db
		self.cur = None


	# This code at the moment does not produce a random number this is just for testing
	def generateRandomNumber(self):

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

		outputState = result.get_statevector(circ, decimals=3)

		error = None
		if outputState is None:
			error = "Error in fetching quantum result"

		if error is None:
			return jsonify(
				output=outputState.size,
			)

		return abort(make_response(jsonify(error), 400))
