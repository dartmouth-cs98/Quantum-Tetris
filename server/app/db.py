import sqlite3
import click
import os
from flask import current_app, g
from flask.cli import with_appcontext
def get_db():
	db = getattr(g, '_database', None)
	if db is None:
		db = g._database = sqlite3.connect(os.path.join(current_app.instance_path, 'app.sqlite'))
	return db


def close_db(e=None):
	db = g.pop('db', None)
	if db is not None:
		db.close()


def init_db():
	db = get_db()
	with current_app.open_resource('schema.sql') as f:
		db.executescript(f.read().decode('utf8'))


@click.command('init-db')
@with_appcontext
def init_db_command():
	"""Clear the existing data and create new tables."""
	init_db()
	click.echo('Initialized the database.')


def init_app(app):
	app.teardown_appcontext(close_db)
	app.cli.add_command(init_db_command)