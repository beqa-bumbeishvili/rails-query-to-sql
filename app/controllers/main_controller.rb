class MainController < ApplicationController

  def index
    @converters = Converter.all
  end

  def convert
    if params['query'].present?
      query_string = params['query']
      @errors = find_errors(query_string)
      query_commands = %w(select where find distinct group having includes joins order preload )
      sql_structure_hash = {
          main_table: query_string.split('.').first
      }

      query_commands.each do |command|
        if query_string.include? command
          command_index = query_string.index("#{command}") + "#{command}".length
          sql_structure_hash[command] = query_string[command_index..(query_string[command_index..-1]).index(')') + command_index]
        end
      end

      commands_array =  query_string.gsub('()', '').split('.')

      1.upto(commands_array.length) do |i|
        sql_structure_hash["#{commands_array[i]}"] ||= []
        sql_structure_hash["#{commands_array[i]}"] << inside_brackets[i-1]
        sql_structure_hash["#{commands_array[i]}"].flatten!
      end

      @convert = ''
    end

    render :convert
  end


  private

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

end