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
    SQLALCHEMY_DATABASE_URI =  'postgres://uyssafbiyxiubm:eec00b1dbd6bd435c70d4de310a030acb27a7235138189bcd610534fd7a0fda5@ec2-54-243-44-102.compute-1.amazonaws.com:5432/d3l75bhln5utku'


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