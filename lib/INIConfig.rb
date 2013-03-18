# encoding: utf-8


# This class signals that an INI-exception of some sort has occurred.
class INIError < StandardError
end

# This class provides a parser, in pure Ruby, for the INI-like
# configuration files.
#
# It provides the necessary methods to deal with the configuration files. It
# allows read existing file as well creating new.
class INIConfig
  # Returns a new, empty configuration.
  #
  # * *Args*    :
  #   - +delimiter+ -> name of the section inside which to search the options.
  def initialize(delimiter = '=')
    @conf = {}
    @delimiter = delimiter
    @comment_pattern = /^\s*(#|;).*$/
    @section_pattern = /\[(.+?)\]/
    @option_pattern  = /^(.+?)\s*#{Regexp.escape(@delimiter)}\s*(.+)$/
  end

  # Returns the list of sections.
  #
  # * *Returns* :
  #   - the list of sections.
  def sections
    @conf.keys()
  end

  # Returns the list of options in the specified section.
  #
  # * *Args*    :
  #   - +section+ -> name of the section inside which to search the options.
  # * *Returns* :
  #   - the list of options in the specified section.
  # * *Raises* :
  #   - +INIError+ -> if the section does not exist.
  def options(section)
    if has_section?(section)
      return @conf[section].keys()
    else
      fail INIError.new("Section '#{section}' does not exist.")
    end
  end

  # Tests the existence of a section in the configuration.
  #
  # * *Args*    :
  #   - +section+ -> section name.
  # * *Returns* :
  #   - true if the section exist, otherwise false.
  def has_section?(section)
    @conf.has_key?(section)
  end

  # Tests the existence of an option in a section of the configuration.
  #
  # * *Args*    :
  #   - +section+ -> name of the section inside which to test the existence of
  #   the option.
  #   - +option+ -> option name.
  # * *Returns* :
  #   - true if the option exist in the section, otherwise false.
  # * *Raises* :
  #   - +INIError+ -> if the section does not exist.
  def has_option?(section, option)
    if has_section?(section)
      @conf[section].has_key?(option)
    else
      fail INIError.new("Section '#{section}' does not exist.")
    end
  end

  # Returns the value associated to the option.
  #
  # * *Args*    :
  #   - +section+ -> section name.
  #   - +option+ -> option name.
  # * *Returns* :
  #   - the value associated to the option.
  # * *Raises* :
  #   - +INIError+ -> if the section and/or the item does not exist.
  def [](section, option)
    if has_option?(section, option)
      @conf[section][option]
    else
      fail INIError.new("Option '#{option}' does not exist " <<
                        "in section '#{section}'.")
    end
  end

  # Adds a section to the configuration.
  #
  # * *Args*    :
  #   - +section+ -> section name.
  # * *Raises* :
  #   - +INIError+ -> if the section already exist.
  def add_section(section)
    if has_section?(section)
      fail INIError.new("Section '#{section}' already exist.")
    else
      @conf[section] = {}
    end
  end

  # Adds an option to the section of a configuration.
  #
  # * *Args*    :
  #   - +section+ -> name of the section inside which to create the option.
  #   - +option+ -> option name.
  #   - +value+ -> option value.
  # * *Raises* :
  #   - +INIError+ -> if the section does not exist or if the section
  #   already contains an option with the same name
  def add_option(section, option, value)
    if has_option?(section, option)
      fail INIError.new("Option '#{option}' already exist " <<
                        "in section '#{section}'.")
    else
      @conf[section][option] = value
    end
  end

  # Removes a section from the configuration.
  #
  # * *Args*    :
  #   - +section+ -> name of the section to delete.
  # * *Raises* :
  #   - +INIError+ -> if the section does not exist.
  def delete_section(section)
    if has_section?(section)
      @conf[section].clear()
      @conf.delete(section)
    else
      fail INIError.new("Section '#{section}' does not exist.")
    end
  end

  # Removes an option from a section of a configuration.
  #
  # * *Args*    :
  #   - +section+ -> name of the section inside which to delete the option.
  #   - +option+ -> name of the option to delete.
  # * *Raises* :
  #   - +INIError+ -> if the section does not exist and/or if the option does
  #   not exist
  def delete_option(section, option)
    if has_option?(section, option)
      @conf[section].delete(option)
    else
      fail INIError.new("Option '#{option}' does not exist " <<
                        "in section '#{section}'.")
    end
  end

  # Returns a string representing the configuration.
  #
  # * *Returns* :
  #   - a string representing the configuration.
  def to_s
    str = ''
    @conf.each_key() do |section|
      str << '[' << section.to_s() << "]\n"
      @conf[section].each() do |option, value|
        str << option.to_s() << @delimiter << value.to_s() << "\n"
      end
    end
    str
  end

  def load(path, encoding = Encoding.default_external())
    lines = IO.readlines(path, :encoding => encoding.to_s(), :mode => 'rb')
    section_name = nil
    lineno = 0
    it = lines.each()
    loop do
      line = it.next()
      lineno += 1
      if line !~ @comment_pattern # If the line is not a comment.
        match = @section_pattern.match(line)
        if match # If the line is a section declaration.
          section_name = match[1]
          add_section(section_name)
        end
        match = @option_pattern.match(line)
        if match # If the line is an option declaration.
          name  = match[1].lstrip()
          value = match[2]
          if value.start_with?('"') || value.start_with?("'")
            value = parse_quoted_value(value, it)
          else
            value = parse_unquoted_value(value, it)
          end
          add_option(section_name, name, value)
        end
      end
    end
  rescue INIError => err
    raise INIError.new("Line #{lineno}: " << err.message)
  end

  # Writes a configuration object into a file.
  #
  # * *Args*    :
  #   - +path+ -> file path.
  #   - +encoding+ -> the encoding to be used on the file.
  def save(path, encoding = Encoding.default_external())
    IO.write(path, to_s(), :encoding => encoding.to_s())
  end

private

  def parse_quoted_value(value, iterator)
    quoted_value = ''
    quote = value[0] # Extract the quoting character.
    value.slice!(0)  # Remove the first quoting character.
    end_quote = false
    # We search a quoting character that is not preceded by a backslash or a
    # quoting character alone on a line.
    regexp = /([^\\]#{quote})|(^#{quote}$)/
    while !end_quote
      match = regexp.match(value)
      if match
        quoted_value << value[0 ... match.end(0) - 1]
        quoted_value.chomp!()
        end_quote = true
      else
        quoted_value << value + "\n"
        value = iterator.next()
      end
    end
    # Unescape the escaped quotes.
    quoted_value.gsub!(/\\#{quote}/, quote)
    # Unescape the escaped escape character (\).
    quoted_value.gsub(/\\\\/, '\\')
  rescue StopIteration => err # We reach the end of the file.
    raise INIError.new('Un-terminated quoted field')
  end

  def parse_unquoted_value(value, iterator)
    full_value = ''
    # Remove trailing spaces and inline comments.
    value.gsub!(/\s*((#|;).*)?$/, '')
    while value.end_with?('\\')
      # Remove trailing \
      value = value.strip()[0 ... -1]
      full_value << value
      value = iterator.next()
      # Remove trailing spaces and inline comments.
      value.gsub!(/\s*((#|;).*)?$/, '')
    end
    full_value << value.strip()
  rescue StopIteration => err # We reach the end of the file.
    raise INIError.new('Non-ended multiline field')
  end
end
