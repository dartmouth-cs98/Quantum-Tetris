# Flask Alternative Server Framework Workshop

![](https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSku6UZdlw0Pj4CO8SHFYRmzKPvWRPqlDhkfOic9I6sAa74wrQ7)

## Overview

Today you are going to build a CRUD blog using Flask.  While you are working through this workshop, please pay attention to the similarities and differences between what you learned when completing the blog lab.
[Slides](https://docs.google.com/presentation/d/1v1XC6wuX_SOszyiKSqosMqEx33uaNXA5nm2-_v3kgZo/edit?usp=sharing)

Since Flask uses Python, you also may be able to see different cases where it may be advantageous for you to use Python for your backend.  For example, many of us in this class have experience writing in Python.  Also, there may be library components that you are familiar with in Python that you want to incorporate with some of your backend components, in which case it might be necessary for you to use a backend server framework.

Please work through the steps of this workshop and flag one of us over if you have any questions.

This is what your site should look like when you are done: [link](https://cs52-flask-posts.herokuapp.com/) 

## Installation Instructions

### Python
You will need Python3 to complete this tutorial.  Try running `python3` in your terminal. If your terminal jumps to a python prompt, you have Python3.  Otherwise please install python3 here: 
https://www.python.org/downloads/

Today, we are gonna use pip as our package-management system. You can think of pip as the Python equivalent of the yarn package manager we used in the labs. Pip should already be installed since we are using Python 3  downloaded from python.org. However, you can run the command ```pip``` in your terminal to check if you have pip installed. If not, please follow this [link](https://pip.pypa.io/en/stable/installing/) and install pip. Then, you need to pip install flask.

Run this command to pip install flask

```
pip install flask
```

Now we are ready to go!

## Flask Application Setup

We have already created the folder structure for you.  In the app directory, find ```__init__.py```.  This file is sort of like the server.js file we used with the Express.js framework in the labs - where we initialize the app and tell the app where to look for important files.  The file should have the below code:

```python
import os
from flask import Flask

def create_app(test_config=None):
    # create and configure the app
    app = Flask(__name__, instance_relative_config=True)
    app.config.from_mapping(
        SECRET_KEY='dev',
        DATABASE=os.path.join(app.instance_path, 'app.sqlite'),
    )

    if test_config is None:
        # load the instance config, if it exists, when not testing
        app.config.from_pyfile('config.py', silent=True)
    else:
        # load the test config if passed in
        app.config.from_mapping(test_config)

    # ensure the instance folder exists
    try:
        os.makedirs(app.instance_path)
    except OSError:
        pass

    # a simple page that says hello
    @app.route('/hello')
    def hello():
        return 'Hello, World!'

    return app
```

Now that you are in the Flask environment (if you are not in Flask environment, please repeate the last step of the installation instructions), you are ready to initialize Flask.  Run the following commands (these will allow you to run Flask in development mode):

```
export FLASK_APP=app
export FLASK_ENV=development
flask run
```

**Note:** If you have to restart the Flask environment (you may have to throughout this tutorial if you ever exit), you will have to re-execute the following commands:

```
. venv/bin/activate
export FLASK_APP=app
export FLASK_ENV=development
flask run
```

<!-- TODO: it may also be beneficial here to explain how to use / install a Python linter; some people may find this userful in addition to the Linter they are already using -->

In VSCode, use the **pylint** Python linter to help you with your code like the JavaScript linters that we have been using so far in class.  It is important to to check that indentation is correct when running Python code.  VSCode will likely prompt you to install a linter when you open your first .py file.  If it does not, please open the marketplace tab and install the **pylint** linter.

## Database Setup

Like our blog lab, you will only focus on adding and removing posts. For the database component, you need to define the structure for the blog posts. Under your app folder, find the file called db.py. 

To mix things up a bit, instead of MongoDB / Mongoose, our blog will use a SQLite database to store users and posts with no object relational mapping (i.e. no Mongoose). In the SQL workshop we did on Tuesday, we used an Object Relational Mapper which handled writing the actual SQL commands for us. In this tutorial, since we are not using an ORM, you will write (or more accurately paste) actual SQL commands. Python comes with built-in support for SQLite in the sqlite3 module. If you are curious about SQLite and want to learn more about it, follow this [link](https://sqlite.org/lang.html).

First we need to create a connection to the database. Any queries and operations are performed using the connection, which is closed after the work is finished. In web applications this connection is typically tied to the request. It is created at some point when handling a request, and closed before the response is sent.

You now should add the following code to your db.py file in order to establish the connection and close it after we are done.

```python
def get_db():
    if 'db' not in g:
        g.db = sqlite3.connect(
            current_app.config['DATABASE'],
            detect_types=sqlite3.PARSE_DECLTYPES
        )
        g.db.row_factory = sqlite3.Row

    return g.db


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

```

Now we need to create the actual datastructure to store the posts. In SQLite, this is done with tables. We need two tables, one for user, which stores id, username and password, and one for post, which stores all attributes associated with a post. In this tutorial, we will link each post to an author, and only the author who created the post can edit/delete the post. Pretty cool right?!

Now in your app folder, find the file called *schema.sql* to establish those two tables. Since this is done in SQL, we are gonna provide the code below. If you are already familiar with SQL, feel free to try it yourself!

```sql
DROP TABLE IF EXISTS user;
DROP TABLE IF EXISTS post;

CREATE TABLE user (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL
);

CREATE TABLE post (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  author_id INTEGER NOT NULL,
  created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  image_url TEXT,
  FOREIGN KEY (author_id) REFERENCES user (id)
);
```

Now we need to tell our *db.py* file to run these SQL commands. The code below that you already added to your *db.py* file will handle running this SQL commands. The `@click.command('init-db')` syntax creates a flask command `flask init-db` that we can call from our Flask environment shell to initialize the databse whenever we want.

```python
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
```

Finally, we need to tell our main application to use this database, more specifically our init_db() and init_db_command() functions. To do that, we have a function in *db.py* that takes the application and does the registration for us.  This code should already be in your db.py.

```python
def init_app(app):
    app.teardown_appcontext(close_db)
    app.cli.add_command(init_db_command)
```

We are almost done with database now. The last thing we need to do is to call the init_app() function in our *__init__.py* file. Above the return statement, call the function like this:

```python
from . import db
db.init_app(app)
```

We can now use the flask command to initialize our database. Run this in your terminal:

```
flask init-db
```

Now you should see an folder titled instance, and under it a file called *app.sqlite*.

## Blueprint

Flask blueprint files are written in Python and they are sort of like combining the route.js and controller files we used in Express. Unlike our Express backend in the labs where we responded with JSON, we will be responding with server rendered html/css in this tutorial.   Under app, find the file, ```auth.py``` (similar to the user_model from our blog project). We have initialized the blueprint for you there already.

To access the blueprint, it has to be register with the app. Please copy the following code to your ```__init__.py``` file just above the `return app` statement:

```python

from . import auth
app.register_blueprint(auth.bp)

```

Great, now we want to render HTML with a form for the users to fill out when they register.  Return to ```auth.py``` and add the following code to handle login requests by the user:

```python
@bp.route('/register', methods=('GET', 'POST'))
def register():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        db = get_db()
        error = None

        if not username:
            error = 'Username is required.'
        elif not password:
            error = 'Password is required.'
        elif db.execute(
            'SELECT id FROM user WHERE username = ?', (username,)
        ).fetchone() is not None:
            error = 'User {} is already registered.'.format(username)

        if error is None:
            db.execute(
                'INSERT INTO user (username, password) VALUES (?, ?)',
                (username, generate_password_hash(password))
            )
            db.commit()
            return redirect(url_for('auth.login'))

        flash(error)

    return render_template('auth/register.html')
```

As you can see above, a route has defined, so this will handle requests to the register route.  At the end, when the form is submitted a POST request will be made.  Validation is done to check the username and password.  If they are fine, like the authentication that we did in the lab, the password is hashed and the user is redirected to hte login page.

Similarly, at the end of the ```auth.py``` file, please paste the following code to handle requests for the user to login

```python
@bp.route('/login', methods=('GET', 'POST'))
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        db = get_db()
        error = None
        user = db.execute(
            'SELECT * FROM user WHERE username = ?', (username,)
        ).fetchone()

        if user is None:
            error = 'Incorrect username.'
        elif not check_password_hash(user['password'], password):
            error = 'Incorrect password.'

        if error is None:
            session.clear()
            session['user_id'] = user['id']
            return redirect(url_for('index'))

        flash(error)

    return render_template('auth/login.html')
```

When the user is logged in, like with our blog, we need to register this as part of the session (similar to how we stored a token for if the user is logged in from lab 5):

```python
@bp.before_app_request
def load_logged_in_user():
    user_id = session.get('user_id')

    if user_id is None:
        g.user = None
    else:
        g.user = get_db().execute(
            'SELECT * FROM user WHERE id = ?', (user_id,)
        ).fetchone()
```

We have registering and logging in.  The user also needs to be able to logout.  To do so, please paste this in the ```auth.py``` file:

```python
@bp.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('index'))
```

In lab 5, we did not want the user to always be able to access every view if they were not logged in.  For example, we did not want the user to be able to edit the posts.  Similarly here, we are going to create a function which we can apply to views to define whether authentication is required.  This is similar to how we marked certain calls as requiring auth in lab 5.  Please add the following code to the end of ```auth.py```:

```python
def login_required(view):
    @functools.wraps(view)
    def wrapped_view(**kwargs):
        if g.user is None:
            return redirect(url_for('auth.login'))

        return view(**kwargs)

    return wrapped_view
```

```url_for``` like routes allows a URL to be generated based on arguments.  The URL does not have to be specifically accessing a file that is stored.  

Now you have the authentication part and the user should be able to sign in and out when you are viewing the final site.

## Templates

So you have called the function render_template() in your python code, but we haven't written any templates yet. So let's go ahead and do that. Find the folder called templates in your app folder. Templates is what flask uses to display content. Think of it as something that loads the static webpage, but also tells the dynamic data where they should be. Therefore, we will write our templates pretty much just like HTML, with a few modifications. Flask uses [jinja](http://jinja.pocoo.org/docs/2.10/templates/) to render the templates. You can click on the link if you want to find out more about the syntax and usage!

Every single page of ours should share a very similar layout. To avoid rewriting HTML code, we can create a base.html file, and have every other template extend that. In the base.htmml file put in the following code for now.

```html
<!doctype html>
<title>{% block title %}{% endblock %} - Posts</title>
<link rel="stylesheet" href="{{ url_for('static', filename='style.css') }}">
<nav>
  <h1>Posts</h1>
  <ul>
    {% if g.user %}
      <li><span>{{ g.user['username'] }}</span>
      <li><a href="{{ url_for('auth.logout') }}">Log Out</a>
    {% else %}
      <li><a href="{{ url_for('auth.register') }}">Register</a>
      <li><a href="{{ url_for('auth.login') }}">Log In</a>
    {% endif %}
  </ul>
</nav>
<section class="content">
  <header>
    {% block header %}{% endblock %}
  </header>
  {% for message in get_flashed_messages() %}
    <div class="flash">{{ message }}</div>
  {% endfor %}
  {% block content %}{% endblock %}
</section>
```

As you can see, this is just some good old HTML, but we do have a few things we should notice. First of all, all the {} are part of the jinja syntax. They allow us to create placeholders for dynamic data in static HTML, or even run some simple if statements and for loops. For instance, if you look inside the nav component, you will see that we are rendering the nav bar differently based on whether we have a logged in user (```{% if g.user %}```). The ```{% block header %}``` and ```{% block content %}``` parts will get replaced by whatever we write in our other templates. However, the nav bar will be the same for each page. Again, you can follow the jinja link above if you want to find out more about it!

Now we are ready to write other templates! Create a auth folder under templates to store all the authentication related templates. Let's write one for the registration page and in register.html. 

```html
{% extends 'base.html' %}

{% block header %}
  <h1>{% block title %}Register{% endblock %}</h1>
{% endblock %}

{% block content %}
  <form method="post">
    <label for="username">Username</label>
    <input name="username" id="username" required>
    <label for="password">Password</label>
    <input type="password" name="password" id="password" required>
    <input type="submit" value="Register">
  </form>
{% endblock %}
```

As you can see, we are just extending the base.html file and filling in the ```{% block header %}``` and ```{% block content %}``` parts. 

Now go ahead and try the log in page, login.html! This should be very similar to the registration page. 

<details>
<summary>Did you finish? Let's double check.</summary>

```html
{% extends 'base.html' %}

{% block header %}
  <h1>{% block title %}Log In{% endblock %}</h1>
{% endblock %}

{% block content %}
  <form method="post">
    <label for="username">Username</label>
    <input name="username" id="username" required>
    <label for="password">Password</label>
    <input type="password" name="password" id="password" required>
    <input type="submit" value="Log In">
  </form>
{% endblock %}
```
</details>

We are done with templates for now!

**Note: at this point, we haven't written our landing page yet, so all you will see on the localhost is still just "Hello World!" Don't worry, we are getting to that very soon!**

## Styling!

Now your blog website should have the basic authentication functions and displays. Let's style it up a little bit. You would style flask web apps with CSS. Yay you can flex your CSS skills again. Open the *style.css* file under the static folder. This is where flask goes to find the styling, since we already had that in your *base.html* file. We provided the styling for you already, since our focus for this workshop is not CSS, but feel free to spice it up!

## Blog functions!

So now we are done with both the blueprint and the templates of authentication, we just need to do the same for our blog functions. Go to the *blog.py* file under app, which stores your blog blueprint. You will see that we have defined it for you already. Now we need to register it with our app the same way we did for auth. Add the following code to your *__init__.py* above the return function.

```python
from . import blog
app.register_blueprint(blog.bp)
app.add_url_rule('/', endpoint='index')
```

This also tells flask that the home page '/' connects to index. But now we also have "Hello World" at the home page '/'. Don't worry. We are taking care of that, but first, let's actually write the page index.

### Home Page

The homepage will just show a list view of all the posts. Add this to our *blog.py* file.

```python
@bp.route('/')
def index():
    db = get_db()
    posts = db.execute(
        'SELECT p.id, title, image_url, body, created, author_id, username'
        ' FROM post p JOIN user u ON p.author_id = u.id'
        ' ORDER BY created DESC'
    ).fetchall()
    return render_template('blog/index.html', posts=posts)
```

Now we add the corresponding template code in *index.html*.

```html
{% extends 'base.html' %}

{% block header %}
  <h1>{% block title %}Posts{% endblock %}</h1>
  {% if g.user %}
    <a class="action" href="{{ url_for('blog.create') }}">New</a>
  {% endif %}
{% endblock %}

{% block content %}
  {% for post in posts %}
    <article class="post">
      <header>
        <div>
          <h1>{{ post['title'] }}</h1>
          <div class="about">by {{ post['username'] }} on {{ post['created'].strftime('%Y-%m-%d') }}</div>
        </div>
        {% if g.user['id'] == post['author_id'] %}
          <a class="action" href="{{ url_for('blog.update', id=post['id']) }}">Edit</a>
        {% endif %}
      </header>
      <img class="post-image" src="{{ post['image_url'] }}"/>
      <p class="body">{{ post['body'] }}</p>
    </article>
    {% if not loop.last %}
      <hr>
    {% endif %}
  {% endfor %}
{% endblock %}
```

Now are you ready to see the page? Go to *__init__.py*, and comment out the hello world function

```python
@app.route('/')
def hello():
    return 'Hello, World!'
```

You should be able to see the index page right now. If not, maybe restart your page using ```flask run```. 

### Create

You can see that we added a link to ```blog.create```. Let's actually implement that function! Let's add a create() function in our *blog.py*.

```python
@bp.route('/create', methods=('GET', 'POST'))
@login_required
def create():

    if request.method == 'POST':
        title = request.form['title']
        image_url = request.form['image_url']
        body = request.form['body']
       
        error = None

        if not title:
            error = 'Title is required.'

        if error is not None:
            flash(error)
        else:
            db = get_db()
            db.execute(
                'INSERT INTO post (title, body, image_url, author_id)'
                ' VALUES (?, ?, ?, ?)',
                (title, body, image_url, g.user['id'])
            )
            db.commit()
            return redirect(url_for('blog.index'))

    return render_template('blog/create.html')
```

As you can see, we have the ```@login_required```, which is a very simple way to force users to log in before creating a post. We will do the same thing for editing and deleting later. Now you should be pretty familiar with the flow, and you will know that our next step is the template for creating a new post. Go to the *create.html* file, and add the following:

```html
{% extends 'base.html' %}

{% block header %}
  <h1>{% block title %}New Post{% endblock %}</h1>
{% endblock %}

{% block content %}
  <form method="post">
    <label for="title">Title</label>
    <input name="title" id="title" value="{{ request.form['title'] }}" required>
    <label for="image_url">Image URL</label>
    <input name="image_url" id="image_url" value="{{ request.form['image_url'] }}">
    <label for="body">Body</label>
    <textarea name="body" id="body">{{ request.form['body'] }}</textarea>
    <input type="submit" value="Save">
  </form>
{% endblock %}

```

### Update

For both update and delete, you will need to fetch a post by id and check that the user did create this post. We add the function get_post() to our blog.py.

```python
def get_post(id, check_author=True):
    post = get_db().execute(
        'SELECT p.id, title, body, image_url, created, author_id, username'
        ' FROM post p JOIN user u ON p.author_id = u.id'
        ' WHERE p.id = ?',
        (id,)
    ).fetchone()

    if post is None:
        abort(404, "Post id {0} doesn't exist.".format(id))

    if check_author and post['author_id'] != g.user['id']:
        abort(403)

    return post
```

Now you are ready to implement the updating function. You will need to write both a function in blog.py and a template. Our update function would be very similar to our create function, but instead of INSERT we will use UPDATE.

<details>
<summary>Are you done with both the blueprint function and the template? Let's check your answers!</summary>


Your function in blog.py should look like this:

```python
@bp.route('/<int:id>/update', methods=('GET', 'POST'))
@login_required
def update(id):
    post = get_post(id)

    if request.method == 'POST':
        title = request.form['title']
        image_url = request.form['image_url']
        body = request.form['body']
        error = None

        if not title:
            error = 'Title is required.'

        if error is not None:
            flash(error)
        else:
            db = get_db()
            db.execute(
                'UPDATE post SET title = ?, body = ?, image_url = ? WHERE id = ?',
                (title, body, image_url, id)
            )
            db.commit()
            return redirect(url_for('blog.index'))
            
    return render_template('blog/update.html', post=post)
```


And your template update.html should be like this:

```html
{% extends 'base.html' %}

{% block header %}
  <h1>{% block title %}Edit "{{ post['title'] }}"{% endblock %}</h1>
{% endblock %}

{% block content %}
  <form method="post">
    <label for="title">Title</label>
    <input name="title" id="title"
      value="{{ request.form['title'] or post['title'] }}" required>
    <label for="image_url">Image URL</label>
    <input name="image_url" id="image_url" value="{{ request.form['image_url'] or post['image_url'] }}" >
    <label for="body">Body</label>
    <textarea name="body" id="body">{{ request.form['body'] or post['body'] }}</textarea>
    <input type="submit" value="Save">
  </form>
  <hr>
  <form action="{{ url_for('blog.delete', id=post['id']) }}" method="post">
    <input class="danger" type="submit" value="Delete" onclick="return confirm('Are you sure?');">
  </form>
{% endblock %}
```

</details>

### Delete

Deletion is actually easier than updating, since we don't need a template for that. As you can see, we referred to blog.delete above. Let's go ahead and add that function in blog.py.

```python
@bp.route('/<int:id>/delete', methods=('POST',))
@login_required
def delete(id):
    get_post(id)
    db = get_db()
    db.execute('DELETE FROM post WHERE id = ?', (id,))
    db.commit()
    return redirect(url_for('blog.index'))
```

And we are done with our blog functions!!!

## Deployment

At this point, if you do ```flask run``` in your terminal, you fully functional post app should be running on the localhost. That means we only have deploying left to do! There are many ways you can deploy flask, but today we are sticking with what we know already: we are going to deploy to heroku! Deployment with flask actually can be a bit tricky, so make sure you follow the instructions carefully. 

First let's create the app on heroku. It is actually a lot easier to do this in the terminal. By now, you should have heroku CLI installed already from previous labs. If you are not logged in, run the command ```heroku login``` to do so. After you logged in, run the command

```
heroku create YOUR_APP_NAME
```

Now heroku automatically creates the app under your account, and you can just do ```git push heroku master``` to push up your code like you did before. However, before we are ready to do that, we need to setup a couple of things.

First, when deploying a Python app, heroku looks for a requirements.txt, which includes all the dependencies it needs to install before running the app. **We have provided the file for you already**, but later on if you use flask on your own, you can generate the file using ```pip freeze > requirements.txt```.

We also need a web service to get our app running. gunicorn is commonly used with Flask so let's install that first.

```
pip install gunicorn
```

In order to successfully run gunicorn, we need to create a new file under our main folder that initializes the whole app. Go ahead and create *main.py* in the main folder, and add in the following code.

```python
from app.__init__ import create_app

if __name__ == '__main__':
    create_app = create_app()
    create_app.run()
else:
    gunicorn_app = create_app()
```

Now if you run the command below in your terminal, gunicorn should be able to host your app on a local server.

```
gunicorn main:gunicorn_app
```

Basically, this is telling gunicorn to go to the main.py file, and open gunicorn_app. We are almost there! Now we know this is how we host our app on the web, but how can we tell heroku that? Like the labs, we need a Procfile. Go ahead and create Procfile under the main folder. It only needs to have this one line:

```
web: gunicorn main:gunicorn_app
```

When heroku launches the app, it looks for a Procfile that tells it what to do. Our Procfile does exactly that!

Finally, we are ready to push to heroku and deploy! Don't forget to add and commit all your changes! Now push all your code and start the application!

```
git push heroku master
heroku ps:scale web=1
```

You can either go to the link or do ```heroku open``` to see your app running in the browser. We are done!

## What you should have at this point

* [ ] Made blog interface 
* [ ] Styled nicely
* [ ] Built page for viewing posts
* [ ] Built page for making a post
* [ ] Built page for editing a post
* [ ] Deployed to heroku

## Summary / What you Learned

*In this workshop, you learned how to create a blog framework similar to that made during the blog lab.  Here, you used an alternative framework, Flask, to achieve the same purpose.  In addition, you learned the following specific skills:*

* [ ] How to apply the skills you have learned to a different framework.
* [ ] Why having a different backend may be more suitable for different cases.
* [ ] The skills that you learned about Python can transfer to web development.

## Reflection

*Please answer the following two reflection questions for this workshop on Flask:*

* [ ] What parallels did you see between the code that you assembled in Flask and the code that you have been writing for this course thusfar with React and other libraries?
* [ ] What are the advantages and disadvantagese to using Flask over other server frameworks?  

## Resources

* Flask installation: http://flask.pocoo.org/docs/1.0/installation/
* Flask tutorial (modified from here to parallel the blog that we created using React and Javascript): http://flask.pocoo.org/docs/1.0/tutorial/
