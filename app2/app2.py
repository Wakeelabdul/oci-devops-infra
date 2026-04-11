from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return "<h1>Hello OCI! This is my DevOps Project running on OKE. This is App 2 now</h1>"

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5001)
