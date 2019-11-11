from werkzeug.exceptions import abort

from flask import make_response, jsonify
from qiskit import *
import math

class Quantum():

	MAX_QUBITS = 5
	machineName = 'qasm_simulator'

	def __init__(self, db):
		self.db = db
		self.cur = None


	# Code adapted from https://blog.red-badger.com/2018/9/24/generate-true-random-numbers-with-a-quantum-computer
	def generateRandomNumber(self, maxInt):

		result = self.getRandNum(maxInt)

		error = None
		if result is None:
			error = "Error in fetching quantum result"

		if error is None:
			return jsonify(
				randomInt=result,
			)

		return abort(make_response(jsonify(error), 400))

	def determineSuperposition(self, piece1, piece2):

		result = self.findSuperposition(piece1, piece2)

		error = None
		if result is None:
			error = "Error in determining superposition"

		if error is None:
			return jsonify(
				piece=result,
			)

		return abort(make_response(jsonify(error), 400))

	def findSuperposition(self, piece1, piece2):

		q = QuantumRegister(3)
		c = ClassicalRegister(1)
		qc = QuantumCircuit(q, c)

		qc.h(0)
		qc.h(1)
		qc.cx(0,2)
		qc.cx(1,2)
		qc.measure(0, 0)
		qc.measure(1, 0)
		qc.measure(2, 0)

		simulator = Aer.get_backend(self.machineName)
		job_sim = execute(qc, backend = simulator, shots=1000)
		sim_result = job_sim.result()
		try:
			sim_result.get_counts(qc)['0']
			return piece1
		except KeyError:
			return piece2

	def getRandNum(self, maxInt):
		result = self.random_int(self.nextPowerOf2(maxInt))
		while result > maxInt:
			result = self.random_int(self.nextPowerOf2(maxInt))
		return result


	def random_int(self, maxInt):
		bits = ''
		n_bits = self.numBits(maxInt - 1)
		register_sizes = self.getRegisterSizes(n_bits, self.MAX_QUBITS)

		for x in register_sizes:
			q = QuantumRegister(x)
			c = ClassicalRegister(x)
			qc = QuantumCircuit(q, c)

			qc.h(q)
			qc.measure(q, c)

			simulator = Aer.get_backend(self.machineName)
			job_sim = execute(qc, backend = simulator, shots=1)
			sim_result = job_sim.result()
			counts = sim_result.get_counts(qc)

			bits += self.bitFromCounts(counts)
		return int(bits, 2)

	def nextPowerOf2(self, n):
		return int(math.pow(2, math.ceil(math.log(n, 2))))

	def bitFromCounts(self, counts):
		return [k for k, v in counts.items() if v == 1][0]

	def numBits(self, n):
		return math.floor(math.log(n, 2)) + 1 if n != 0 else 1

	def getRegisterSizes(self, n, max_qubits):
		register_sizes = [max_qubits for i in range(int(n / max_qubits))]
		remainder = n % max_qubits
		return register_sizes if remainder == 0 else register_sizes + [remainder]
