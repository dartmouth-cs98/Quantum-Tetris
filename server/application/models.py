from application.__init__ import db
import datetime

# Base models found from https://blog.theodo.com/2017/03/developping-a-flask-web-app-with-a-postresql-database-making-all-the-possible-errors/
class BaseModel(db.Model):
    """Base data model for all objects"""
    __abstract__ = True

    def __init__(self, *args):
        super().__init__(*args)

    def __repr__(self):
        """Define a base way to print models"""
        return '%s(%s)' % (self.__class__.__name__, {
            column: value
            for column, value in self._to_dict().items()
        })

    def json(self):
        """
                Define a base way to jsonify models, dealing with datetime objects
        """
        return {
            column: value if not isinstance(value, datetime.date) else value.strftime('%Y-%m-%d')
            for column, value in self._to_dict().items()
        }

class PlayerModel(db.Model):
    __tablename__ = 'players'
    __table_args__ = {'extend_existing': True}

    id = db.Column(db.Integer, primary_key=True)
    userId = db.Column(db.String())
    hiscore = db.Column(db.Integer)

    def __init__(self, userId, hiscore):
        self.userId = userId
        self.hiscore = hiscore

    def __repr__(self):
        return '<id {}>'.format(self.id)