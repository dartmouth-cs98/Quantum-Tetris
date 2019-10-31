from . import db
from flask import jsonify

class Player:
    def __init__(self):
        self.db = db
        pass

    def createPlayer(self, username, hiscore):

        cur = self.db.get_db().cursor()

        error = None
        if not username:
            error = 'Username is required.'
        elif hiscore != 0 and not hiscore :
            error = 'HiScore is required.'
        elif cur.execute(
            'SELECT id FROM player WHERE username = ?', (username,)
        ).fetchone() is not None:
            error = 'Player {} is already registered.'.format(username)

        if error is None:
            cur.execute(
                'INSERT INTO player (username, hiscore) VALUES (?, ?)',
                (username, hiscore)
            )
            return jsonify(
                username=username,
                hiscore=hiscore,
                id=cur.lastrowid,
            )

        return error

    def fetchPlayer(self, name):
        player = self.db.execute(
            'SELECT username, hiscore'
            ' FROM player'
            ' WHERE username= ?',
            (name,)
        ).fetchone()

        if player is None:
            return None

        return jsonify(
            username=player.username,
            hiscore=player.hiscore,
            id=player.id,
        )

    def delete(self,id):
        player = self.fetchPlayer(id)
        self.db.execute('DELETE FROM player WHERE id = ?', (id,))
        self.db.commit()
        return player