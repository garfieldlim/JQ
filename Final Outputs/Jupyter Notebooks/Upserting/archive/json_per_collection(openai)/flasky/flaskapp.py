# flask_app.py
from flask import Flask, request, jsonify
from flask_cors import CORS
from main import main  # Ensure you have main.py that includes your main function

app = Flask(__name__)
CORS(app)  # This will allow your Flutter app to make requests to this server

@app.route('/search', methods=['POST'])
def search():
    data = request.get_json()
    question = data.get('question')
    if question is None:
        return jsonify({'error': 'No question provided'}), 400

    try:
        results = main(question)  # Pass the question to your main function
        return jsonify(results)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=7999, debug=True)
