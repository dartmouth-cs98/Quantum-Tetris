from werkzeug.exceptions import abort
from models import PlayerModel

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
        elif PlayerModel.query.filter_by(username=player.username).first() is not None:
            error = 'Player {} is already registered.'.format(player.username)

        if error is None:
            db.session.add(player)
            db.session.commit()
            return jsonify(
                username=player.username,
                hiscore=player.hiscore,
            )

        return abort(make_response(jsonify(error), 400))

    # def fetchPlayer(self, playerName):
    #     if self.cur is None:
    #         self.cur = self.db.get_db().cursor()
    #     player = self.cur.execute(
    #         'SELECT *'
    #         ' FROM player'
    #         ' WHERE username= ?',
    #         (playerName,)
    #     ).fetchone()
	#
    #     if player is None:
    #         return abort(make_response(jsonify('Player {} does not exist.'.format(playerName)), 400))
	#
    #     return jsonify(
    #         id=player[0],
    #         username=player[1],
    #         hiscore=player[2],
    #     )
    # def updatePlayer(self, username, hiscore):
    #     if self.cur is None:
    #         self.cur = self.db.get_db().cursor()
	#
	#
    #     error = None
    #     if not username:
    #         error = 'Username is required.'
    #     elif hiscore != 0 and not hiscore :
    #         error = 'HiScore is required.'
	#
    #     if error is None:
    #         self.cur.execute(
    #             'UPDATE player SET hiscore = ? WHERE username = ?',
    #             (hiscore, username)
    #         )
    #         return jsonify(
    #             username=username,
    #             hiscore=hiscore,
    #             id=self.cur.lastrowid,
    #         )
	#
    #     return abort(make_response(jsonify(error), 400))
	#
    # def delete(self, playerName):
    #     if self.cur is None:
    #         self.cur = self.db.get_db().cursor()
    #     player = self.fetchPlayer(playerName)
    #     self.cur.execute('DELETE FROM player WHERE id = ?', (player.json['id'],))
    #     return jsonify(
    #         id=player.json['id'],
    #         username=player.json['username'],
    #         hiscore=player.json['hiscore'],
    #     )