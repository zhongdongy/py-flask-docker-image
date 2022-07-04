from flask import Flask


def create_app() -> Flask:
    app = Flask(__name__, template_folder='templates')

    @app.route('/')
    def home():

        return "Hello, Python Flask Docker Image"

    return app
