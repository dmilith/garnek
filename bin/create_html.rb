#!/usr/bin/env ruby

# PBS 4 Dec. 2013
# Renders HTML for all the .md files in the current directory.


require 'rdiscount'
require 'find'
require 'fileutils'


def markdown_file?(f)
  filename = File.basename(f)

  if filename[0] == ?.
    return false end
  if FileTest.directory?(f)
    return false end

  extension = File.extname(filename)
  if extension == '.md'
    return true end

  false
end

def text_of_file(f)
  file = File.open(f, 'r')
  s = file.read
  file.close
  s
end

def filename_with_suffix_dropped(filename)
  filename_array = filename.split('.')
  filename_array.delete_at(filename_array.length - 1)
  filename = filename_array.join('.')

  filename
end

def filename_with_suffix_changed(filename, new_suffix)
  filename = filename_with_suffix_dropped(filename)
  filename + new_suffix
end

def write_file(s, f)
  FileUtils.mkdir_p(File.dirname(f))
  f = File.open(f, 'a')
  f.puts(s)
  f.close
end

def html_text_for_file(f)
  puts "File: #{f}"
  markdown_text = text_of_file(f)
  RDiscount.new(markdown_text).to_html
end

def generate_and_write_html(f)
  filename = File.basename(f)
  html_filename = filename_with_suffix_changed(filename, '.html')

  folder = File.dirname(f)
  html_folder = folder + "/"

  html_filepath = html_folder + html_filename
  html_text = html_text_for_file(f)
  write_file(html_text, html_filepath)
end


folder = Dir.pwd + "/arts/"
Find.find(folder) do |f|
  filename = File.basename(f)

  if markdown_file?(f)
    print(filename + "\n")
    generate_and_write_html(f)
  end
end


header = "<html><head><title>Programowanie Garnka</title><link href=/css/style.css rel=stylesheet></head><body><h2>Programowanie Garnka</h2>"
footer = "<p><code>Garnek wczytany - 2014</code> <a href=\"https://twitter.com/dmilith\" rel=\"noreferrer\">@dmilith</a></p></body></html>"
content_file = Dir.pwd + "/index.html"

write_file(header, content_file)
Find.find(folder) do |f|
  filename = folder + "/" + File.basename(f)
  puts "Filename: #{filename}"
  if filename.end_with?(".html")
    write_file("<article>", content_file)
    write_file(text_of_file(filename), content_file)
    write_file("</article>", content_file)
  end
end
write_file(footer, content_file)
