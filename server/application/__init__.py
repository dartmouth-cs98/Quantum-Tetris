from flask import Flask, request
from flask_cors import CORS
from . import database_setup
from application.quantum import Quantum
from application.player import Player
from flask_sqlalchemy import SQLAlchemy
from application.config import DevelopmentConfig
from application import models

# create and configure the application
app = Flask(__name__, instance_relative_config=True)
cors = CORS(app, resources={r"/api/*": {"origins": "*"}})
app.config.from_object(DevelopmentConfig)
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)
db.init_app(app)

#************** PLAYER ENDPOINTS *****************
player=Player(database_setup)

@app.route('/api/createPlayer', methods=['POST'])
def createPlayer():
    if request.method == 'POST':
        params=request.get_json()
        username = params['username']
        hiscore = params['hiscore']

        response = player.createPlayer(username, hiscore)
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

@app.route('/api/updatePlayer', methods=['PUT'])
def updatePlayerr():
    if request.method == 'PUT':
        params=request.get_json()
        username = params['username']
        hiscore = params['hiscore']
        response = player.updatePlayer(username, hiscore)
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
quantum=Quantum(database_setup)
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
