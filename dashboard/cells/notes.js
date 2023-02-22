$(".ctr-dashboard").ready(function() {
  Cell.init({
    title: "Notes",
    h: 2,
    w: 2,
    x: 2,
    y: 1,
    reloader: function(cell) {
      if (localStorage.getItem("notes") == null) {
        var lines = []
        lines.push("Click on this cell to select Notes")
        lines.push("Enter any text to add as an item to the list.")
        lines.push("Type - followed by a number to remove that item from the list. For example: '-3' will remove this item")
        lines.push("Use '.clear' to completely empty all notes.")
        lines.push("This message will reappear after a reload if '.clear' is used, but not if you remove the lines one by one.")
        lines.push("Cells can be positioned specifically and resized, but will default to 1x1 and left-right top-bottom.")
        lines = Text.numberedList(lines)
        localStorage.setItem("notes", lines.join("\n"))
        cell.lines(lines)
      } else {
        cell.text(localStorage.getItem("notes"))
      }
    },
    commands: {
      clear: function(cell) {
        localStorage.removeItem("notes")
        cell.text("")
      }
    },
    command: function(text, cell) {
      if (/^-\d+$/.test(text)) {
        var num = parseInt(text.match(/\d+/)[0])
        var lines = cell.text().split("\n")
        lines.splice(num-1, 1)
      } else {
        var lines = cell.text() ? cell.text().split("\n") : []
        lines.push(text)
      }

      var note = Text.numberedList(lines).join("\n")

      localStorage.setItem("notes", note)
      cell.text(note)
    }
  })
})
