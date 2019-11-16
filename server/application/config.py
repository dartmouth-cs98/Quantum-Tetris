import os
basedir = os.path.abspath(os.path.dirname(__file__))


POSTGRES = {
    'user': 'postgres',
    'pw': 'quantum-is-rad',
    'db': 'quantum_tetris',
    'host': 'localhost',
    'port': '5432',
}

class Config(object):
    DEBUG = False
    TESTING = False
    CSRF_ENABLED = True
    SECRET_KEY = 'quantum-is-cool'
    SQLALCHEMY_DATABASE_URI =  'postgresql://%(user)s:\
%(pw)s@%(host)s:%(port)s/%(db)s' % POSTGRES


class ProductionConfig(Config):
    DEBUG = False


class StagingConfig(Config):
    DEVELOPMENT = True
    DEBUG = True


class DevelopmentConfig(Config):
    DEVELOPMENT = True
    DEBUG = True


class TestingConfig(Config):
    TESTING = True