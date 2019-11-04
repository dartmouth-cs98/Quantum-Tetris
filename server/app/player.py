from werkzeug.exceptions import abort

from flask import make_response, jsonify

class Player():
    def __init__(self, db):
        self.db = db
        self.cur = None

    def createPlayer(self, username, hiscore):
        if self.cur is None:
            self.cur = self.db.get_db().cursor()


        error = None
        if not username:
            error = 'Username is required.'
        elif hiscore != 0 and not hiscore :
            error = 'HiScore is required.'
        elif self.cur.execute(
            'SELECT id FROM player WHERE username = ?', (username,)
        ).fetchone() is not None:
            error = 'Player {} is already registered.'.format(username)

        if error is None:
            self.cur.execute(
                'INSERT INTO player (username, hiscore) VALUES (?, ?)',
                (username, hiscore)
            )
            return jsonify(
                username=username,
                hiscore=hiscore,
                id=self.cur.lastrowid,
            )

        return abort(make_response(jsonify(error), 400))

    def fetchPlayer(self, playerName):
        if self.cur is None:
            self.cur = self.db.get_db().cursor()
        player = self.cur.execute(
            'SELECT *'
            ' FROM player'
            ' WHERE username= ?',
            (playerName,)
        ).fetchone()

        if player is None:
            return abort(make_response(jsonify('Player {} does not exist.'.format(playerName)), 400))

        return jsonify(
            id=player[0],
            username=player[1],
            hiscore=player[2],
        )

    def delete(self, playerName):
        if self.cur is None:
            self.cur = self.db.get_db().cursor()
        player = self.fetchPlayer(playerName)
        self.cur.execute('DELETE FROM player WHERE id = ?', (player.json['id'],))
        return jsonify(
            id=player.json['id'],
            username=player.json['username'],
            hiscore=player.json['hiscore'],
        )