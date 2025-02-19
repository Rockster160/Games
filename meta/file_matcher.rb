# Used by `multifile_content_replace`

class FileMatcher
  attr_accessor :file, :matchdata

  def initialize(file, matchdata)
    @file = file
    @matchdata = matchdata
  end

  def content
    @content = File.read(@file)
  end

  def full_match
    @matchdata.to_a[0]
  end

  def match(idx)
    @matchdata.to_a[idx+1]
  end
end
