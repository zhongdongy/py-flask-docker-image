import logging

logging.basicConfig(filename='/tmp/py-flask.log', encoding='utf-8', level=logging.DEBUG)
try:
    from main import create_app

    logging.info('Factory method `create_app()` found in `main` module, proceed to start')
    app = create_app()
except ModuleNotFoundError as e:
    logging.error('[FATAL]: Module `main` required and it should provide `create_app()` method with no parameters')
    exit(1)
