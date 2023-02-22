options = [
  :includeOnlyEventsFromNowOn,
  :formatOutput,
  :separateByDate,
  :noRelativeDates,
  :noCalendarNames,
  :showUIDs,
]
options_with_vals = {
  excludeCals: "Bills, B18F1275-1162-4B5F-9FA6-6C02C5FE484B",
  includeCalTypes: "CalDAV",
  excludeEventProps: "notes, attendees",
}
options_str = options.map { |opt| "--#{opt}" }.join(" ")
options_str += " " + options_with_vals.map { |opt, val| "--#{opt} \"#{val}\"" }.join(" ")

puts `/usr/local/bin/icalBuddy #{options_str} eventsToday+10`
