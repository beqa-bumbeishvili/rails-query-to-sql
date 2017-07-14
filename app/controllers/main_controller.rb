class MainController < ApplicationController

  def index
    @converters = Converter.all
  end

  def convert
    query_string = params['query']
    @errors = find_errors(query_string)
    inside_brackets = query_string.scan(/\(([^\)]+)\)/)
    inside_brackets.each { |substring| query_string.slice! substring.first }
    commands_array =  query_string.gsub('()', '').split('.')
    sql_structure_hash = {
      main_table: commands_array.first
    }
    1.upto(commands_array.length) do |i|
      sql_structure_hash["#{commands_array[i]}"] ||= []
      sql_structure_hash["#{commands_array[i]}"] << inside_brackets[i-1]
      sql_structure_hash["#{commands_array[i]}"].flatten!
    end

    @convert = ''
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