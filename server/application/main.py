from .__init__ import app

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
else:
    gunicorn_app = app