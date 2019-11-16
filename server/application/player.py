from werkzeug.exceptions import abort
from application import models
from flask import make_response, jsonify
from application.__init__ import db

class Player():
    def __init__(self):
        pass

    def createPlayer(self, player):
        error = None
        if not player.username:
            error = 'Username is required.'
        elif player.hiscore != 0 and not player.hiscore :
            error = 'HiScore is required.'
        elif models.PlayerModel.query.filter_by(username=player.username).first() is not None:
            error = 'Player {} is already registered.'.format(player.username)

        if error is None:
            db.session.add(player)
            db.session.commit()
            return jsonify(
                id=player.id,
                username=player.username,
                hiscore=player.hiscore,
            )

        return abort(make_response(jsonify(error), 400))

    def fetchPlayer(self, playerName):
        player = models.PlayerModel.query.filter_by(username=playerName).first()

        if player is None:
            return abort(make_response(jsonify('Player {} does not exist.'.format(playerName)), 400))

        return jsonify(
            id=player.id,
            username=player.username,
            hiscore=player.hiscore,
        )
    def updateHiscore(self, player):

        error = None
        if not player.username:
            error = 'Username is required.'
        elif player.hiscore != 0 and not player.hiscore :
            error = 'HiScore is required.'


        if error is None:
            updatedPlayer = models.PlayerModel.query.filter_by(username=player.username).first()
            updatedPlayer.hiscore = player.hiscore
            db.session.commit()
            return jsonify(
                username=updatedPlayer.username,
                hiscore=updatedPlayer.hiscore,
                id=updatedPlayer.id,
            )

        return abort(make_response(jsonify(error), 400))

    def delete(self, playerName):
        player = models.PlayerModel.query.filter_by(username=playerName).first()
        db.session.delete(player)
        db.session.commit()
        return jsonify(
            id=player.id,
            username=player.username,
            hiscore=player.hiscore,
        )