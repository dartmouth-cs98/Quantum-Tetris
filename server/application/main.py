import os
from application.__init__ import app

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=os.environ['PORT'])
else:
    gunicorn_app = app