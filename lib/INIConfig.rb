#encoding: utf-8

# Copyright (c) 2013-2014, Sylvain LAPERCHE
# All rights reserved.
# License: BSD 3-Clause (http://opensource.org/licenses/BSD-3-Clause)

# This class signals that an INI-exception of some sort has occurred.
class INIError < StandardError
end

# This class provides a parser, in pure Ruby, for the INI-like configuration
# files.
#
# It provides the necessary methods to deal with the configuration files. It
# allows the reading of existing files as well as creating new ones.
class INIConfig
  # Returns a new, empty configuration.
  #
  # @param opts [Hash] the hash of options.
  # @option opts [String] :delimiter ('=') the option/value delimiter.
  # @option opts [String] :default ('Default') name of the default section.
  def initialize(opts = {})
    @delimiter = opts.fetch(:delimiter, '=')
    @default_section = opts.fetch(:default, 'Default')
    @comment_pattern = /^\s*(#|;).*$/
    @section_pattern = /\[(.+?)\]/
    @option_pattern  = /^(.+?)\s*#{Regexp.escape(@delimiter)}\s*(.+)$/

    @conf = {}
  end

  # Returns the list of sections.
  #
  # @return [Array] the list of sections.
  def sections
    @conf.keys()
  end

  # Returns the list of options in the specified section.
  #
  # @param section [String,Symbol] section name.
  # @return [Array] the list of options in the specified section.
  # @raise [INIError] if the section does not exist.
  def options(section)
    if has_section?(section)
      return @conf[section].keys()
    else
      fail INIError.new("Section '#{section}' does not exist.")
    end
  end

  # Tests the existence of a section in the configuration.
  #
  # @param section [String,Symbol] section name.
  # @return [Boolean] true if the section exist, otherwise false.
  def has_section?(section)
    @conf.has_key?(section)
  end

  # Tests the existence of an option in a section of the configuration.
  #
  # @param section [String,Symbol] section name.
  # @param option  [String,Symbol] option name.
  # @return [Boolean] true if the option exist in the section, otherwise false.
  # @raise [INIError] if the section does not exist.
  def has_option?(section, option)
    if has_section?(section)
      @conf[section].has_key?(option)
    else
      fail INIError.new("Section '#{section}' does not exist.")
    end
  end

  # Returns the value associated to the option.
  #
  # @param section [String,Symbol] section name.
  # @param option  [String,Symbol] option name.
  # @return [String] the value associated to the option.
  # @raise [INIError] if the section and/or the item does not exist.
  def [](section, option)
    if has_option?(section, option)
      @conf[section][option]
    else
      fail INIError.new("Option '#{option}' does not exist " <<
                        "in section '#{section}'.")
    end
  end

  # Set the value of the option.
  #
  # @param section [String,Symbol] section name.
  # @param option  [String,Symbol] option name.
  # @param value   [#to_s] new value.
  # @raise [INIError] if the section and/or the item does not exist.
  def []=(section, option, value)
    if has_option?(section, option)
      @conf[section][option] = value
    else
      fail INIError.new("Option '#{option}' does not exist " <<
                        "in section '#{section}'.")
    end
  end

  # Adds a section to the configuration.
  #
  # @param section [String,Symbol] section name.
  # @raise [INIError] if the section already exists.
  def add_section(section)
    if has_section?(section)
      fail INIError.new("Section '#{section}' already exist.")
    else
      @conf[section] = {}
    end
  end

  # Adds an option to the section of a configuration.
  #
  # @param section [String,Symbol] section name.
  # @param option  [String,Symbol] option name.
  # @param value   [#to_s]         option value.
  # @raise [INIError] if the section does not exist or if the section already
  #                   contains an option with the same name.
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
  # @param section [String,Symbol] name of the section to delete.
  # @raise [INIError] if the section does not exist.
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
  # @param section [String,Symbol] name of the section containing the option to
  #                                be deleted.
  # @param option [String,Symbol] name of the option to delete.
  # @raise [INIError] if the section does not exist and/or if the option does
  #                   not exist
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
  # @return [String] a string representing the configuration.
  def to_s
    str = ''
    @conf.each_key() do |section|
      str << '[' << section.to_s() << "]\n"
      @conf[section].each() do |option, value|
        val = value.to_s()
        # If the value is only whitespaces or begin like a comment, quote it.
        val = '"' + val + '"' if val.strip.empty? || val =~ /^(;|#)/
        str << option.to_s() << @delimiter << val << "\n"
      end
    end
    return str
  end

  # Loads the content of an existing configuration file.
  #
  # @param path      [String]          file path.
  # @param encoding  [Encoding,String] the encoding to be used on the file.
  # @param to_symbol [Boolean]         convert section and option names to
  #                                    symbol?
  # @raise [INIError] if the INI-file is malformed.
  def load(path, encoding = Encoding.default_external(), to_symbol = false)
    lines = IO.readlines(path, :encoding => encoding.to_s(), :mode => 'rb')
    section_name = nil
    lineno = 0
    it = lines.each()
    loop do
      # I make the assumption that configuration files are quite short in
      # practice, so it is not worth to change the encoding of all the
      # patterns/strings ((instead of changing the encoding of each lines) to
      # increase the speed. The gain will be insignificant.
      line = it.next().encode('UTF-8')
      lineno += 1
      if line !~ @comment_pattern
        match = @section_pattern.match(line)
        if match
          section_name = to_symbol ? match[1].to_sym() : match[1]
          add_section(section_name)
          next
        end
        match = @option_pattern.match(line)
        if match
          name  = match[1].lstrip()
          value = match[2]
          if value.start_with?('"') || value.start_with?("'")
            value = parse_quoted_value(value, it)
          else
            value = parse_unquoted_value(value, it)
          end
          unless section_name
            section_name = @default_section
            add_section(section_name)
          end
          add_option(section_name, to_symbol ? name.to_sym() : name, value)
          next
        end
        if line !~ /^\s*$/ # If the line is not an "empty" line.
          # If we arrive here that means the current line is neither a comment,
          # nor a section declaration, nor an option declaration, nor an "empty"
          # line.
          fail INIError.new("Cannot parse '#{line.chomp()}'")
        end
      end
    end
  rescue INIError => err
    raise INIError.new("Line #{lineno}: " << err.message)
  end

  # Writes a configuration object into a file.
  #
  # @param path     [String]          file path.
  # @param encoding [Encoding,String] the encoding to be used on the file.
  def save(path, encoding = Encoding.default_external())
    IO.write(path, to_s(), :encoding => encoding.to_s())
  end

private

  # Parses the option value.
  #
  # @param value    [String]     current value of the option.
  # @param iterator [Enumerator] iterator on the lines.
  # @return [String] the option value.
  # @raise [INIError] if no matching quotation mark is found before the end of
  #                   the file.
  def parse_quoted_value(value, iterator)
    print(iterator.class)
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
    quoted_value.gsub!(/\\\\/, '\\')
    return quoted_value
  rescue StopIteration => err # We reach the end of the file.
    raise INIError.new('Un-terminated quoted field')
  end

  # Parses the option value.
  #
  # @param value    [String]     current value of the option.
  # @param iterator [Enumerator] iterator on the lines.
  # @return [String] the option value.
  # @raise [INIError] if the multiline value does not end before the end of the
  #                   file.
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
