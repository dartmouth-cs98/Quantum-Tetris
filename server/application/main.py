# import os
from application.__init__ import app

if __name__ == '__main__':
    print(1)
    # port = int(os.environ.get('PORT', 5000))
    app.run()
else:
    gunicorn_app = app