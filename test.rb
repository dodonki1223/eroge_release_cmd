# frozen_string_literal: true

require './spreadsheet/spreadsheet.rb'
require './spreadsheet/spreadsheet_writer.rb'
require 'bundler/setup'
require 'google_drive'
require 'csv'

test = SpreadsheetWriter.new('Your Sheet Id')
test.delete_worksheet_by_title('201902')
test.get_worksheet_by_title_not_exist_create('201902')

# puts test.worksheet.human_url

test.write_by_csv('getchuya_scraping/created/201902.csv')

# csv_data = CSV.read('getchuya_scraping/created/201902.csv')
# csv_data.each_with_index do |data, row|
#   data.each_with_index do |value, cell|
#     test.worksheet[row + 1 , cell + 1] = value
#   end
# end

# csv_data = CSV.read('getchuya_scraping/created/201902.csv')
# csv_data.each_with_index do |data, row|
#   data.each_with_index do |value, cell|
#     test.worksheet[row + 1 , cell + 1] = value
#   end
# end

# test.worksheet[1, 1] = '名倉じゅんじゅわぁー（ホリケン）'
# test.worksheet[1, 2] = '空にはばたけパラグライダー（ホリケン）'
# test.worksheet.save
