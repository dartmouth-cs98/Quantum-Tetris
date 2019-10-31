import os
from flask import Flask, request
from flask_cors import CORS
from . import db
from . import game
from app.player import Player

def create_app(test_config=None):
    # create and configure the app
    application = Flask(__name__, instance_relative_config=True)
    cors = CORS(application, resources={r"/api/*": {"origins": "*"}})
    application.config.from_mapping(
        SECRET_KEY='dev',
        DATABASE=os.path.join(application.instance_path, 'app.sqlite'),
    )
    if test_config is None:
        # load the instance config, if it exists, when not testing
        application.config.from_pyfile('config.py', silent=True)
    else:
        # load the test config if passed in
        application.config.from_mapping(test_config)

    # ensure the instance folder exists
    try:
        os.makedirs(application.instance_path)
    except OSError:
        pass

    # Commented out so that we can run everything without a db for now
    db.init_app(application)
    application.register_blueprint(game.bp)
    application.add_url_rule('/', endpoint='game')


    player=Player()
    @application.route('/api/createPlayer', methods=['POST'])
    def createPlayer():
        if request.method == 'POST':
            params=request.get_json()
            username = params['username']
            hiscore = params['hiscore']
            response = player.createPlayer(username, hiscore)
            return response
        print("CreatePlayer")


    @application.route('/api/fetchPlayer', methods=['GET'])
    def fetchPlayer():
        if request.method == 'GET':
            username = request.username
            response = player.fetchPlayer(username)
            return response
        print("FetchPlayer")

    @application.route('/api/deletePlayer', methods=['DELETE'])
    def delete():

        return player

    return application
