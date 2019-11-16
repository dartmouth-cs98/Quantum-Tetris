from flask import Flask, request
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from application import models
from application.config import DevelopmentConfig

# create and configure the application
app = Flask(__name__, instance_relative_config=True)
cors = CORS(app, resources={r"/api/*": {"origins": "*"}})
app.config.from_object(DevelopmentConfig)
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)
db.init_app(app)

from . import quantum as q
from . import player as p

#************** PLAYER ENDPOINTS *****************
player=p.Player()

@app.route('/api/createPlayer', methods=['POST'])
def createPlayer():
    if request.method == 'POST':
        params=request.get_json()
        newPlayer = models.PlayerModel(params['username'], params['hiscore'])
        response = player.createPlayer(newPlayer)
        return response
    print("CreatePlayer")
    return None


@app.route('/api/fetchPlayer/', methods=['GET'])
def fetchPlayer():
    if request.method == 'GET':
        username = request.args.get('username', default= None, type= str)
        response = player.fetchPlayer(username)
        return response
    print("FetchPlayer")
    return None

@app.route('/api/updateHiscore', methods=['PUT'])
def updateHiscore():
    if request.method == 'PUT':
        params=request.get_json()
        updatePlayer = models.PlayerModel(params['username'], params['hiscore'])
        response = player.updateHiscore(updatePlayer)
        return response
    print("CreatePlayer")
    return None

@app.route('/api/deletePlayer/', methods=['DELETE'])
def delete():
    if request.method == 'DELETE':
        username = request.args.get('username', default= None, type= str)
        response = player.delete(username)
        return response
    print("DeletePlayer")
    return None

#************** QUANTUM ENDPOINTS *****************
quantum=q.Quantum()
@app.route('/api/generateRandomNumber/', methods=['GET'])
def generateRandomNumber():
    if request.method == 'GET':
        maxNum = request.args.get('max', default= None, type= int)
        response = quantum.generateRandomNumber(maxNum)
        return response
    print("GenerateRandomNumber")
    return None

@app.route('/api/determineSuperposition/', methods=['POST'])
def determineSuperposition():
    if request.method == 'POST':
        params=request.get_json()
        piece1 = params['piece1']
        piece2 = params['piece2']
        response = quantum.determineSuperposition(piece1, piece2)
        return response
    print("DetermineSuperposition")
    return None
