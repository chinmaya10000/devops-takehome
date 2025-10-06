from flask import Flask
app = Flask(__name__)

@app.route("/")
def home():
    return "Hello from Chinmaya - DevOps Take-Home Task (Python Flask)!"

@app.route("/healthz")
def health():
    return {"status": "ok"}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
