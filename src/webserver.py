from flask import request, Flask, jsonify
from ORMConnector import ORMConnector

app = Flask(__name__)
orm = ORMConnector()

def request_handler(page = 1):
    try:
        body = request.json
        
        if request.method == 'POST':
            return jsonify(orm.get_movies_list(body['top_number'], body['genres'], body['year_from'], body['year_to'], body['regexp'], page))
        elif request.method == 'GET':
            orm.insert_new_rating(body['id'], body['rate'])
            return jsonify({'response': 'OK'})
    except BaseException:
        return jsonify({'error': 'wrong request'})

    return jsonify({'error': 'no such method'})


@app.route('/<int:page>', methods=['GET', 'POST'])
def index_page(page = 1):
    return request_handler(page)


@app.route('/<path:u_path>/<int:page>', methods=['GET', 'POST'])
def catch_all_page(u_path, page = 1):  
    return request_handler(page)


@app.route('/', methods=['GET', 'POST'])
def index():
    return request_handler()


@app.route('/<path:u_path>', methods=['GET', 'POST'])
def catch_all(u_path):  
    return request_handler()


if __name__ == '__main__':
    app.run(port=80)
