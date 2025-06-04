from flask import Flask, render_template, request, redirect, url_for

app = Flask(__name__)

# In-memory task list
tasks = []

@app.route('/')
def index():
    return render_template('index.html', tasks=tasks)

@app.route('/add', methods=['POST'])
def add():
    task_content = request.form.get('task')
    if task_content:
        task = {
            'id': len(tasks) + 1,
            'task': task_content,
            'done': False
        }
        tasks.append(task)
    return redirect(url_for('index'))

@app.route('/complete/<int:task_id>')
def complete(task_id):
    for task in tasks:
        if task['id'] == task_id:
            task['done'] = True
    return redirect(url_for('index'))

@app.route('/delete/<int:task_id>')
def delete(task_id):
    global tasks
    tasks = [task for task in tasks if task['id'] != task_id]
    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)