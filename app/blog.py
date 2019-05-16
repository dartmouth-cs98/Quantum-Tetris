from flask import (
    Blueprint, flash, g, redirect, render_template, request, url_for
)
from werkzeug.exceptions import abort

from app.db import get_db
from app.auth import login_required

bp = Blueprint('blog', __name__)