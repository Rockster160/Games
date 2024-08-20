import argparse
from prompt_toolkit import prompt
from prompt_toolkit.shortcuts import yes_no_dialog, input_dialog, checkboxlist_dialog
from prompt_toolkit.completion import WordCompleter
from prompt_toolkit.key_binding import KeyBindings
from prompt_toolkit.document import Document
from prompt_toolkit.validation import Validator, ValidationError

bindings = KeyBindings()

@bindings.add('c-c')
def _(event):
    event.app.exit()

def get_input(prompt_text, default=''):
    return input_dialog(title="Input", text=prompt_text, default=default).run()

def get_boolean(prompt_text, default=False):
    return yes_no_dialog(title="Boolean", text=prompt_text, default=default).run()

def get_select(prompt_text, options, default=None):
    completer = WordCompleter(options, ignore_case=True)
    return prompt(prompt_text, completer=completer, complete_while_typing=True, key_bindings=bindings)

def get_multiline(prompt_text, default=''):
    return prompt(prompt_text, default=default, multiline=True, key_bindings=bindings)

def main():
    parser = argparse.ArgumentParser(description="Form Builder CLI")
    parser.add_argument('--method', type=str, default="GET", help="HTTP Method")
    parser.add_argument('--url', type=str, default="http://example.com", help="URL")
    parser.add_argument('--headers', type=str, default="Content-Type: application/json", help="Headers")
    parser.add_argument('--body', type=str, default="", help="Body/Parameters")
    args = parser.parse_args()

    print("Use Arrow keys to navigate between fields.")
    method = get_select("Method: ", ["GET", "POST", "PUT", "DELETE"], default=args.method)
    url = get_input("URL: ", default=args.url)
    headers = get_multiline("Headers: ", default=args.headers)
    body = get_multiline("Body/Parameters: ", default=args.body)

    print(f"Method: {method}")
    print(f"URL: {url}")
    print(f"Headers: {headers}")
    print(f"Body/Parameters: {body}")

if __name__ == "__main__":
    main()
