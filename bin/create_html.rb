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
  puts "Translating: #{f} => html"
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
    generate_and_write_html(f)
  end
end


header = "<html><head><title>Programowanie… garnka - log kulinarny.</title><link href=css/style.css rel=stylesheet><meta charset=\"utf-8\"> </head><body><pre><h1>Programowanie garnka</h1></pre>"
footer = "<hr/><pre><footer>2014-2018 - <a href=\"https://twitter.com/dmilith\" rel=\"noreferrer\">@dmilith</a></h4></footer></pre></body></html>"
content_file = Dir.pwd + "/index.html"

file_list = []
Find.find(folder) do |f|
  filename = folder + "/" + File.basename(f)
  if filename.end_with? ".html"
    file_list << text_of_file(filename)
  end
end

# Write to output file:
write_file header, content_file
for elem in file_list.reverse
  # NOTE: change "pre" tags to regular "div":
  a_file = elem.gsub! "pre", "div"
  a_file = elem.gsub! "h3", "header"
  a_file = elem.gsub! "h6", "section"
  a_file = elem.gsub! "div", "summary"

  write_file "<hr/><article>", content_file
  write_file a_file, content_file
  write_file "</article>", content_file
end
write_file(footer, content_file)
