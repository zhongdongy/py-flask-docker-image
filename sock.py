import logging
import socket
import time
from os import remove
from os.path import exists

UNIX_SOCKET_FILE = '/tmp/py-flask-docker-image.sock'
logging.basicConfig(filename='/tmp/py-flask-docker-image-sock.log', encoding='utf-8', level=logging.DEBUG)


def main():
    if exists(UNIX_SOCKET_FILE):
        remove(UNIX_SOCKET_FILE)

    server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    server.bind(UNIX_SOCKET_FILE)

    logging.info(f'Unix sock bound to `{UNIX_SOCKET_FILE}` and listening')

    while True:
        server.listen(1)
        conn, addr = server.accept()
        datagram = conn.recv(1024)
        if datagram:
            data = datagram.decode('utf-8').strip()
            tokens = data.split("@@")  # `@@` is the delimiter of command and message
            logging.info(f"Command=`{tokens[0]}`, message=`{tokens[1]}`")
        time.sleep(0.5)


if __name__ == '__main__':
    main()
