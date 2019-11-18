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
# Sample JSON Body
# {
# 	"username": "player",
# 	"hiscore": 90
# }
#
# Sample response
# {
#   "hiscore": 90,
#   "id": 4,
#   "username": "player"
# }
@app.route('/api/createPlayer', methods=['POST'])
def createPlayer():
    if request.method == 'POST':
        params=request.get_json()
        newPlayer = models.PlayerModel(params['username'], params['hiscore'])
        response = player.createPlayer(newPlayer)
        return response
    return None
# Sample request
# [SERVER_NAME]/api/fetchPlayer?username=player
# Sample response
# {
#   "hiscore": 90,
#   "id": 4,
#   "username": "player"
# }
@app.route('/api/fetchPlayer/', methods=['GET'])
def fetchPlayer():
    if request.method == 'GET':
        username = request.args.get('username', default= None, type= str)
        response = player.fetchPlayer(username)
        return response
    return None

# Sample JSON body
# {
# 	"username": "player",
# 	"hiscore": 15
# }
# Sample response
# {
#   "hiscore": 15,
#   "id": 4,
#   "username": "player"
# }
@app.route('/api/updateHiscore', methods=['PUT'])
def updateHiscore():
    if request.method == 'PUT':
        params=request.get_json()
        updatePlayer = models.PlayerModel(params['username'], params['hiscore'])
        response = player.updateHiscore(updatePlayer)
        return response
    return None

# Sample request
# [SERVER_NAME]/api/deletePlayer/?username=player
#
# Sample response
# {
#   "hiscore": 15,
#   "id": 4,
#   "username": "player"
# }
@app.route('/api/deletePlayer/', methods=['DELETE'])
def delete():
    if request.method == 'DELETE':
        username = request.args.get('username', default= None, type= str)
        response = player.delete(username)
        return response
    return None

#************** QUANTUM ENDPOINTS *****************
quantum=q.Quantum()

# Sample request
# [SERVER_NAME]/api/generateRandomNumber/?max=10
#
# Sample response
# {
#   "randomInt": 2
# }
@app.route('/api/generateRandomNumber/', methods=['GET'])
def generateRandomNumber():
    if request.method == 'GET':
        maxNum = request.args.get('max', default= None, type= int)
        response = quantum.generateRandomNumber(maxNum)
        return response
    return None
# Sample Request
# [SERVER_NAME]/api/determineSuperposition/?prob=60
#
# Sample result
# {
#   "result": 0
# }
#
@app.route('/api/determineSuperposition/', methods=['GET'])
def determineSuperposition():
    if request.method == 'GET':
        prob = request.args.get('prob', default= None, type= int)
        response = quantum.determineSuperposition(prob)
        return response
    return None

# Sample JSON body
# {
# 	"grid" : {
# 		"0": {
# 			"value": 0,
# 			"x": 0,
# 			"y": 0
# 		},
# 		"1": {
# 			"value": 1,
# 			"x": 0,
# 			"y": 1
# 		}
# 	}
# }
# Sample JSON response
# {
#   "result": {
#     "0": {
#       "value": 1,
#       "x": 0,
#       "y": 0
#     },
#     "1": {
#       "value": 0,
#       "x": 0,
#       "y": 0
#     }
#   }
# }
@app.route('/api/flipGrid', methods=['POST'])
def flipGrid():
    if request.method == 'POST':
        params=request.get_json()
        response = quantum.flipGrid(params['grid'])
        return response
    return None