import sys
#for creating the mapper code
from sqlalchemy import Column, ForeignKey, Integer, String

# Database setup used from SQLAlchemy Tutorial found here https://realpython.com/flask-by-example-part-2-postgres-sqlalchemy-and-alembic/

#for configuration and class code
from sqlalchemy.ext.declarative import declarative_base

#for creating foreign key relationship between the tables
from sqlalchemy.orm import relationship

#for configuration
from sqlalchemy import create_engine

#create declarative_base instance
Base = declarative_base()

#we create the class Book and extend it from the Base Class.
class Book(Base):
   __tablename__ = 'book'

   id = Column(Integer, primary_key=True)
   title = Column(String(250), nullable=False)
   author = Column(String(250), nullable=False)
   genre = Column(String(250))

#creates a create_engine instance at the bottom of the file
engine = create_engine('sqlite:///players.db')

Base.metadata.create_all(engine)