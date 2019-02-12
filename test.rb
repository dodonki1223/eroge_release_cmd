# frozen_string_literal: true

require './spreadsheet/spreadsheet.rb'
require './spreadsheet/spreadsheet_writer.rb'

# test = SpreadsheetWriter.new('1fI-31J8AbOEaZd_35-NM_deXIXLVlq5SPgPjZLwjrCY')
test = SpreadsheetWriter.new('1fI-31J8AbOEaZd_35-NM_deXIXLVlq5SPgPjZLwjrCY')

test.get_worksheet_by_title_not_exist_create('aaaaaaaaaa')
test.worksheet[1, 1] = '名倉じゅんじゅわぁー（ホリケン）'
test.worksheet[1, 2] = '空にはばたけパラグライダー（ホリケン）'
test.worksheet.save
