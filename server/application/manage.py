from application.__init__ import app, db
from flask_script import Manager
from flask_migrate import Migrate, MigrateCommand

### Starter code for most database functionality found at https://realpython.com/flask-by-example-part-2-postgres-sqlalchemy-and-alembic/
migrate = Migrate(app, db)
manager = Manager(app)

manager.add_command('db', MigrateCommand)

if __name__ == '__main__':
    manager.run()