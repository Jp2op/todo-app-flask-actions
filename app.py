import os
import bugsnag
from bugsnag.flask import handle_exceptions
from flask import Flask, render_template, request, redirect

# --- Conditional Datadog setup ---
if os.getenv("DD_TRACE_ENABLED", "true").lower() == "true":
    from ddtrace import patch_all, tracer
    patch_all()
    DATADOG_ENABLED = True
else:
    tracer = None
    DATADOG_ENABLED = False

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
    if DATADOG_ENABLED and tracer:
        with tracer.trace("custom.test_datadog_trace", service="flask-todo-app"):
            return "Datadog trace captured."
    return "Datadog tracing is disabled."

@app.route('/health')
def health():
    return "OK", 200

# Optional: useful for local dev (but Gunicorn is used in container)
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)