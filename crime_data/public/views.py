# -*- coding: utf-8 -*-
"""Public section, including homepage and signup."""
import os

from flask import (Blueprint, flash, redirect, render_template, request,
                   send_file, url_for)
from flask_login import login_required, login_user, logout_user

from crime_data.common.auth import basic_auth
from crime_data.extensions import login_manager
from crime_data.public.forms import LoginForm
from crime_data.user.forms import RegisterForm
from crime_data.user.models import User
from crime_data.utils import flash_errors

blueprint = Blueprint('public', __name__, static_folder='../static')

@login_manager.user_loader
def load_user(user_id):
    """Load user by ID."""
    return User.get_by_id(int(user_id))

@blueprint.route('/', methods=['GET', 'POST'])
def home():
    """Home page."""
    form = LoginForm(request.form)
    # Handle logging in
    if request.method == 'POST':
        if form.validate_on_submit():
            login_user(form.user)
            flash('You are logged in.', 'success')
            redirect_url = request.args.get('next') or url_for('user.members')
            return redirect(redirect_url)
        else:
            flash_errors(form)
    return render_template('public/home.html', form=form)

@blueprint.route('/logout/')
@login_required
def logout():
    """Logout."""
    logout_user()
    flash('You are logged out.', 'info')
    return redirect(url_for('public.home'))

@blueprint.route('/register/', methods=['GET', 'POST'])
def register():
    """Register new user."""
    form = RegisterForm(request.form, csrf_enabled=False)
    if form.validate_on_submit():
        User.create(username=form.username.data,
                    email=form.email.data,
                    password=form.password.data,
                    active=True)
        flash('Thank you for registering. You can now log in.', 'success')
        return redirect(url_for('public.home'))
    else:
        flash_errors(form)
    return render_template('public/register.html', form=form)

@blueprint.route('/about/')
def about():
    """About page."""
    form = LoginForm(request.form)
    return render_template('public/about.html', form=form)

@blueprint.route('/docs/', methods=['GET'])
def docs():
    return render_template('public/docs.html')

@blueprint.route('/prototypes/', methods=['GET'])
@basic_auth.required
def prototypes():
    key = os.environ.get('CRIME_DATA_SECRET', 'secret-key')
    return render_template('/prototypes/index.html', key=key)

@blueprint.route('/prototypes/sentences/', methods=['GET'])
@basic_auth.required
def sentences():
    return render_template('/prototypes/sentences.html')

@blueprint.route('/prototypes/filters/', methods=['GET'])
@basic_auth.required
def filters():
    return render_template('/prototypes/filters.html')

@blueprint.route('/prototypes/queries/', methods=['GET'])
@basic_auth.required
def queries():
    return render_template('/prototypes/queries.html')
