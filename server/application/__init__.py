import os
from flask import Flask, request
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy

from application import models
# create and configure the application and database
app = Flask(__name__, instance_relative_config=True)
cors = CORS(app, resources={r"/api/*": {"origins": "*"}})
app.config.from_object(os.environ['APP_SETTINGS'])
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)
db.init_app(app)

from . import quantum as q
from . import player as p

#************** PLAYER ENDPOINTS *****************
player=p.Player()

# Purpose: Creates a player in database with given highscore
# Data contract
# userId: str
# hiscore: int
# Sample JSON Body
# {
# 	"userId": "player",
# 	"hiscore": 90
# }
#
#
# Sample response
# {
#   "hiscore": 90,
#   "id": 4,
#   "userId": "player"
# }
@app.route('/api/createPlayer', methods=['POST'])
def createPlayer():
    if request.method == 'POST':
        params=request.get_json()
        newPlayer = models.PlayerModel(params['userId'], params['hiscore'])
        response = player.createPlayer(newPlayer)
        return response
    return None
# Purpose: Fetches a player in database with given userId
# Data contract
# userId: str
# Sample request
# [SERVER_NAME]/api/fetchPlayer?userId=player
#
# Sample response
# {
#   "hiscore": 90,
#   "id": 4,
#   "userId": "player"
# }
@app.route('/api/fetchPlayer', methods=['GET'])
def fetchPlayer():
    if request.method == 'GET':
        userId = request.args.get('userId', default= None, type= str)
        response = player.fetchPlayer(userId)
        return response
    return None

# Purpose: Updates a player's hiscore in database from given userId and hiscore
# Data contract
# userId: str
# hiscore: int
#
# Sample JSON body
# {
# 	"userId": "player",
# 	"hiscore": 15
# }
# Sample response
# {
#   "hiscore": 15,
#   "id": 4,
#   "userId": "player"
# }
@app.route('/api/updateHiscore', methods=['PUT'])
def updateHiscore():
    if request.method == 'PUT':
        params=request.get_json()
        updatePlayer = models.PlayerModel(params['userId'], params['hiscore'])
        response = player.updateHiscore(updatePlayer)
        return response
    return None

# Purpose: Deletes a player in database with given userId
# Data contract
# userId: str
# Sample request
# [SERVER_NAME]/api/deletePlayer?userId=player
#
#
# Sample response
# {
#   "hiscore": 15,
#   "id": 4,
#   "userId": "player"
# }
@app.route('/api/deletePlayer', methods=['DELETE'])
def delete():
    if request.method == 'DELETE':
        userId = request.args.get('userId', default= None, type= str)
        response = player.delete(userId)
        return response
    return None

#************** QUANTUM ENDPOINTS *****************
quantum=q.Quantum()

# Purpose: Generates random integer between 0 and provided max int
# Data contract
# max: int
# Sample request
# [SERVER_NAME]/api/generateRandomNumber?max=10
#
#
# Sample response
# {
#   "randomInt": 2
# }
@app.route('/api/generateRandomNumber', methods=['GET'])
def generateRandomNumber():
    if request.method == 'GET':
        maxNum = request.args.get('max', default= None, type= int)
        response = quantum.generateRandomNumber(maxNum)
        return response
    return None

# Purpose: Create a superposition of two piece with random types and probabilities
# Data contract
# NO DATA NEEDED
#
# Sample Request
# [SERVER_NAME]/api/createSuperposition
#
# {
#   "result": {
#     "piece1": {
#       "prob": 0.25,
#       "type": 0
#     },
#     "piece2": {
#       "prob": 0.75,
#       "type": 4
#     }
#   }
# }
#
@app.route('/api/createSuperposition', methods=['GET'])
def createSuperposition():
    if request.method == 'GET':
        response = quantum.createSuperposition()
        return response
    return None

# Purpose: Calculates a superposition result (0 or 1) based on given probability of 0
# Data contract
# prob: float (0-1)
#
# Sample Request
# [SERVER_NAME]/api/determineSuperposition?prob=.60
#
# Sample result
# {
#   "result": 0
# }
#
@app.route('/api/determineSuperposition', methods=['GET'])
def determineSuperposition():
    if request.method == 'GET':
        prob = request.args.get('prob', default= None, type= float)
        response = quantum.determineSuperposition(prob)
        return response
    return None

# Purpose: Applies an H gate to any given superposition piece and return a new probabilities
# Data contract
# prob: float (0-1)
#
# Sample Request
# [SERVER_NAME]/api/applyHGate

# Sample JSON Object
# {
#      "piece1": {
#        "prob": 0.2,
#        "type": 0
#      },
#      "piece2": {
#        "prob": 0.8,
#        "type": 4
#      }
# }
#
# Sample result
# {
#   "result": {
#     "piece1": {
#       "prob": 0.18,
#       "type": 0
#     },
#     "piece2": {
#       "prob": 0.82,
#       "type": 4
#     }
#   }
# }
#
@app.route('/api/applyHGate', methods=['POST'])
def applyHGate():
    if request.method == 'POST':
        params = request.get_json()
        response = quantum.applyHGate(params)
        return response
    return None

# Purpose: Applies an X gate to any given superposition piece and return a new probabilities
# Data contract
# prob: float (0-1)
#
# Sample Request
# [SERVER_NAME]/api/applyHGate

# Sample JSON Object
# {
#      "piece1": {
#        "prob": 0.2,
#        "type": 0
#      },
#      "piece2": {
#        "prob": 0.8,
#        "type": 4
#      }
# }
#
# Sample result
# {
#   "result": {
#     "piece1": {
#       "prob": 0.8,
#       "type": 0
#     },
#     "piece2": {
#       "prob": 0.2,
#       "type": 4
#     }
#   }
# }
#
@app.route('/api/applyXGate', methods=['POST'])
def applyXGate():
    if request.method == 'POST':
        params = request.get_json()
        response = quantum.applyXGate(params)
        return response
    return None

# Purpose: Flips piece based on state
# Data contract
# piece: int
# Sample request
# [SERVER_NAME]/api/flipEntangledPiece?state=1
#
#
# Sample response
# {
#   "result": 0
# }
@app.route('/api/flipEntangledPiece', methods=['GET'])
def flipEntangledPiece():
    if request.method == 'GET':
        state = request.args.get('state', default= None, type= int)
        response = quantum.flipEntangledPiece(state)
        return response
    return None