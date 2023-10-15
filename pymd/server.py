#!/usr/bin/env python3

import os
from flask import Flask, render_template
import markdown

app = Flask(__name__)

# Define the directory where your Markdown files are located
markdown_directory = 'markdown_files/'

# Function to convert Markdown to HTML
def convert_markdown_to_html(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()
        html = markdown.markdown(content)
        return html

# Route to render Markdown files as HTML
@app.route('/<path:page>')
def render_markdown_page(page):
    file_path = os.path.join(markdown_directory, page + '.md')

    if not os.path.isfile(file_path):
        return "Page not found", 404

    html_content = convert_markdown_to_html(file_path)
    return render_template('page_template.html', content=html_content)

# Home page
@app.route('/')
def home():
    return render_markdown_page('index')

if __name__ == '__main__':
    app.run(debug=True)
