class MainController < ApplicationController

  def index
    @converters = Converter.all
  end

  def convert
    if params['query'].present?
      query_string = params['query']
      @errors = find_errors(query_string)
      query_commands = %w(first select where find distinct group having includes joins order preload pluck last take limit)
      sql_structure_hash = {
          query_string: query_string,
          main_table: query_string.split('.').first
      }

      query_commands.each do |command|
        if query_string.include? command
          if query_string[query_string.index("#{command}") - 1] == '.'
            sql_structure_hash[command] = {}
            command_index = query_string.index("#{command}") + "#{command}".length
            if query_string.rindex('.') > command_index
              sql_structure_hash[command][:command] = query_string[command_index..(query_string[command_index..-1]).index(').') + command_index]
              sql_structure_hash[command][:type] = get_command_type(sql_structure_hash, command)
              sql_structure_hash[command][:end] = false
              'debug'
            elsif query_string[-1] == ')'
              sql_structure_hash[command][:command] = query_string[command_index..(query_string[command_index..-1]).index(')') + command_index]
              sql_structure_hash[command][:type] = get_command_type(sql_structure_hash, command)
              sql_structure_hash[command][:end]= true
            else
              sql_structure_hash[command][:command] = command
              sql_structure_hash[command][:end]= true
            end
          end
        end
      end

      sql_structure_hash['sql'] = generate_sql(sql_structure_hash)

      @convert = sql_structure_hash

    end

    render :convert
  end

  private

  def get_command_type(object,command)
    command_string = object[command][:command]
    if (command_string[1] == "'" && command_string[-2] == "'") ||
       (command_string[1] == '"' && command_string[-2] == '"')
         return 'quoted'
    elsif command_string[1] == ':'
         return 'symbol'
    elsif command_string.index(':').present?
         return 'hash' if command_string.index(':') > 2 && command_string.index(':') < command_string.length - 1
    elsif !!(command_string.gsub(/([()])/, '') =~ /\A[-+]?[0-9]+\z/)
         return 'integer'
    end
  end

  def find_errors(query)
    errors = []
    errors << 'query must be executed on ActiveRecord model' if is_uppercase?(query[0])
  end

  def is_uppercase?(letter)
    case letter
      when /[[:upper:]]/ then return true
      else return false
    end
  end

  def generate_sql(object)
    sql_string = ''
    if object['select'].present?
      sql_string += "SELECT #{object['select'][:command].gsub("'", '').gsub(/[()]/, '')} FROM #{object[:main_table].tableize}"
    end
    if object['where'].present?

    end

    sql_string
  end

end