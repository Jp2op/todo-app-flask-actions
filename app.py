import os
import bugsnag
from bugsnag.flask import handle_exceptions
from flask import Flask, render_template, request, redirect
from ddtrace import patch_all, tracer

# Enable automatic instrumentation
patch_all()

app = Flask(__name__)

# --- Bugsnag setup ---
bugsnag.configure(
    api_key=os.environ.get("BUGSNAG_API_KEY", ""),
    project_root=os.path.dirname(os.path.realpath(__file__)),
    notify_release_stages=["production", "development"],
    release_stage=os.environ.get("FLASK_ENV", "development")
)
handle_exceptions(app)

# In-memory todo list
todos = []

@app.route('/')
def index():
    return render_template('index.html', todos=todos)

@app.route('/add', methods=['POST'])
def add():
    todo = request.form.get('todo')
    if todo:
        todos.append(todo)
    return redirect('/')

@app.route('/error')
def trigger_error():
    raise Exception("Test error for Bugsnag")

@app.route('/datadog')
def test_datadog_trace():
    with tracer.trace("custom.test_datadog_trace", service="flask-todo-app"):
        return "Datadog trace captured."

@app.route('/health')
def health():
    return "OK", 200

# Optional: useful for local dev (but Gunicorn is used in container)
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)