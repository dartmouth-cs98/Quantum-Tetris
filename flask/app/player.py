@bp.route('/api/createPlayer', methods=('POST'))
def createPlayer():
    if request.method == 'POST':
        username = request.form['username']
        hiscore = request.form['hiscore']
        db = get_db()
        error = None

        if not username:
            error = 'Username is required.'
        elif not password:
            error = 'HiScore is required.'
        elif db.execute(
            'SELECT id FROM user WHERE username = ?', (username,)
        ).fetchone() is not None:
            error = 'Player {} is already registered.'.format(username)

        if error is None:
            db.execute(
                'INSERT INTO player (username, hiscore) VALUES (?, ?)',
                (username, hiscore)
            )
            db.commit()
            return redirect(url_for('game'))

        flash(error)

    return render_template('mainMenu.html')
@bp.route('/api/<string:name>/fetchPlayer', methods=('GET'))
def fetchPlayer(name):
    player = get_db().execute(
        'SELECT username, hiscore'
        ' FROM player'
        ' WHERE username= ?',
        (name,)
    ).fetchone()

    if player is None:
        abort(404, "Player id {0} doesn't exist.".format(id))

    return player
@bp.route('/api/<int:id>/delete', methods=('POST',))
def delete(id):
    player = fetchPlayer(id)
    db = get_db()
    db.execute('DELETE FROM player WHERE id = ?', (id,))
    db.commit()
    return player