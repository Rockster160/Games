require "pry-rails"

@str = "Debtor    2ASTRALABS Incoc#37 Filed 03/30/23 Entered 03/30/23 10:55:22 Main Document Pg 13 of          Case number   (if known)          23-10164\n                                                                            15\n           Name\n\n       Name of the person who supervised the taking of the inventory                      Date of           The dollar amount and basis (cost, market, or\n                                                                                          inventory         other basis) of each inventory\n\n\n\n\n\n       Name and address of the person who has possession of inventory records\n\n 27.1.\n\n      Name\n\n\n      Street\n\n\n\n      City                                     State              ZIP Code\n\n 28. List the debtor's officers, directors, managing members, general partners, members in control, controlling shareholders, or other people in\n      control of the debtor at the time of the filing of this case.\n\n       Name                           Address                                                   Position and nature of any           % of interest, if any\n                                                                                                interest\n\n\n      Ryan, Andrew                   979 Springdale Rd. Suite #123 Austin, TX 78723            CEO, Owner                                        42.00%\n\n      Nihar Patel                    979 Springdale Rd. Suite #123 Austin, TX 78723            Co-Founder,                                       20.00%\n\n 29. Within 1 year before the filing of this case, did the debtor have officers, directors, managing members, general partners, members in control of\n      the debtor, or shareholders in control of the debtor who no longer hold these positions?\n\n      ❑  No\n      ❑  Yes. Identify below.\n\n       Name                           Address                                                Position and nature of any        Period during which\n\n                                                                                             interest                          position or interest was\n                                                                                                                               held\n\n                                                                                            ,                                   From\n\n                                                                                                                                To\n\n 30. Payments, distributions, or withdrawals credited or given to insiders\n\n      Within 1 year before filing this case, did the debtor provide an insider with value in any form, including salary, other compensation, draws, bonuses, loans,\n      credits on loans, stock redemptions, and options exercised?\n      ❑  No\n\n      ❑  Yes. Identify below.\n\n       Name and address of recipient                                     Amount of money or description          Dates               Reason for providing\n                                                                         and value of property                                       the value\n\n\n\n 30.1.Ryan, Andrew                                                           $284,269.00 - for last 12 months   03/17/2023\n      Name\n      979 Springdale Rd. Suite #123\n\n      Street\n\n\n      Austin, TX 78723\n      City                                   State        ZIP Code\n\n\n       Relationship to debtor\n\n      CEO\n\n\n\n\n\n\n\n\n\n\n\n\n\nOfficial Form 207                          Statement of Financial Affairs for Non-Individuals Filing for Bankruptcy                                 page 12"

def parse(number)
  section = @str[/\n\s*#{number}\..*?\n\s*\d+/m]
  lines = section.split("\n")[..-2]
  header_idx = lines.index { |line| line.match?(/\w*Name/) }
  header_line = lines[header_idx]
  header_idxs = header_line[/\S.*?$/].split(/\s{2,}/).map { |header_txt| header_line.index(header_txt) }

  after_header = lines[header_idx + lines[header_idx..].index { |line| line.match?(/^\s*$/) }..]
  people_lines = after_header.select { |line| !line.match?(/^\s*$/) }
  headers = [:name, :address, :position, :equity]

  people_lines.map { |line|
    line.gsub(/^\s*|\s*$/, "").split(/ {2,}/).map.with_index { |val, idx|
      [headers[idx], val]
    }.to_h
  }
end

puts @str

require "json"
puts JSON.pretty_generate(parse(28))
