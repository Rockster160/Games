import sys
import termios
import tty
import curses
import json
import os

class FormBuilder:
    def __init__(self):
        self.fields = []
        self.current_field = 0

    def add_field(self, name, type="string", default="", options=None):
        self.fields.append({
            "name": name,
            "type": type,
            "value": default,
            "options": options,
            "default": default
        })

    def run(self):
        curses.wrapper(self._main)

    def _main(self, stdscr):
        curses.curs_set(0)
        stdscr.clear()

        while True:
            self._display_form(stdscr)
            key = stdscr.getch()

            if key == ord('\n'):  # Enter key
                if self.fields[self.current_field]["type"] == "multiline" and self.fields[self.current_field]["value"] != self.fields[self.current_field]["default"]:
                    continue
                break
            elif key == curses.KEY_UP:
                self.current_field = (self.current_field - 1) % len(self.fields)
            elif key == curses.KEY_DOWN or key == ord('\t'):
                self.current_field = (self.current_field + 1) % len(self.fields)
            elif key == curses.KEY_LEFT:
                self._handle_left(stdscr)
            elif key == curses.KEY_RIGHT:
                self._handle_right(stdscr)
            else:
                self._handle_input(stdscr, key)

        return {field["name"]: field["value"] for field in self.fields}

    def _display_form(self, stdscr):
        stdscr.clear()
        for i, field in enumerate(self.fields):
            prefix = ">" if i == self.current_field else " "
            stdscr.addstr(i * 2, 0, f"{prefix} {field['name']}: ")
            if field["type"] == "select":
                options_str = " | ".join(field["options"])
                selected_index = field["options"].index(field["value"])
                stdscr.addstr(i * 2, len(field['name']) + 3, options_str)
                stdscr.addstr(i * 2, len(field['name']) + 3 + sum(len(opt) for opt in field["options"][:selected_index]) + selected_index * 3, field["value"], curses.A_REVERSE)
            elif field["type"] == "boolean":
                stdscr.addstr(i * 2, len(field['name']) + 3, "Yes" if field["value"] else "No", curses.A_REVERSE if i == self.current_field else curses.A_NORMAL)
            else:
                stdscr.addstr(i * 2, len(field['name']) + 3, str(field["value"]))
        stdscr.refresh()

    def _handle_left(self, stdscr):
        field = self.fields[self.current_field]
        if field["type"] == "select":
            options = field["options"]
            current_index = options.index(field["value"])
            field["value"] = options[(current_index - 1) % len(options)]
        elif field["type"] == "boolean":
            field["value"] = not field["value"]
        elif field["type"] == "multiline":
            field["type"] = "string"

    def _handle_right(self, stdscr):
        field = self.fields[self.current_field]
        if field["type"] == "select":
            options = field["options"]
            current_index = options.index(field["value"])
            field["value"] = options[(current_index + 1) % len(options)]
        elif field["type"] == "boolean":
            field["value"] = not field["value"]
        elif field["type"] == "string":
            field["type"] = "multiline"
            curses.def_prog_mode()
            os.system('clear')
            print(f"Editing {field['name']} (Ctrl+G to save and exit):")
            if field["value"] == field["default"]:
                field["value"] = ""
            new_value = self._get_multiline_input(field["value"])
            field["value"] = new_value if new_value else field["default"]
            curses.reset_prog_mode()

    def _handle_input(self, stdscr, key):
        field = self.fields[self.current_field]
        if field["type"] in ["string", "multiline"]:
            if key == ord('\b') or key == 127:  # Backspace
                field["value"] = field["value"][:-1]
            else:
                field["value"] += chr(key)

    def _get_multiline_input(self, initial_text):
        fd = sys.stdin.fileno()
        old_settings = termios.tcgetattr(fd)
        try:
            tty.setraw(fd)
            editor = os.environ.get('EDITOR', 'nano')
            with open('/tmp/multiline_input.txt', 'w') as f:
                f.write(initial_text)
            os.system(f'{editor} /tmp/multiline_input.txt')
            with open('/tmp/multiline_input.txt', 'r') as f:
                return f.read().strip()
        finally:
            termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
            os.remove('/tmp/multiline_input.txt')

def parse_field_arg(arg):
    parts = arg.split(':')
    name = parts[0]
    type = parts[1] if len(parts) > 1 else "string"
    default = parts[2] if len(parts) > 2 else ""
    options = parts[3].split(',') if len(parts) > 3 else None
    return {"name": name, "type": type, "default": default, "options": options}

def main():
    if len(sys.argv) < 2:
        print("Usage: formbuilder <field1> <field2> ...")
        print("Field format: name:type:default:option1,option2,...")
        print("Types: string, select, boolean, multiline")
        sys.exit(1)

    form = FormBuilder()
    for arg in sys.argv[1:]:
        field = parse_field_arg(arg)
        form.add_field(**field)

    result = form.run()
    print(json.dumps(result, indent=2))

if __name__ == "__main__":
    main()
