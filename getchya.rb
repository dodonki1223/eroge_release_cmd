# frozen_string_literal: true

require './getchya_scraping/command_line_arg.rb'

command_line_args = CommandLineArg.new

puts command_line_args.has?(:title)
puts command_line_args.get(:title)

puts command_line_args.options
