require "tilt/erubis"
require "sinatra"
require "sinatra/reloader"

helpers do
  def in_paragraphs(text)
    text.split("\n\n")
        .map.with_index { |paragraph, index| "<p id=paragraph#{index}>#{paragraph}</p>"}
        .join
  end

  def highlight(text, query)
    text.gsub(query, "<strong>#{query}</strong>")
  end
end

before do
  @contents = File.readlines("data/toc.txt")
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"

  erb :home
end

get "/chapters/:chapter_id" do
  chapter_id = params[:chapter_id].to_i
  chapter_name = @contents[chapter_id - 1]

  redirect "/" unless (1..@contents.size).cover?(chapter_id)

  @title = "Chapter #{chapter_id}: #{chapter_name}"

  @chapter = File.read("data/chp#{chapter_id}.txt")

  erb :chapter
end

def each_chapter
  @contents.each_with_index do |title, index|
    number = index + 1
    contents = File.read("data/chp#{number}.txt")
    yield number, title, contents
  end
end

def chapters_matching(query)
  results = []

  return results unless query

  each_chapter do |number, name, contents|
    matches = {}
    contents.split("\n\n").each_with_index do |paragraph, index|
      matches[index] = paragraph if paragraph.include?(query)
    end
    results << {number: number, name: name, paragraphs: matches} if matches.any?
  end

  results
end

get "/search" do
  @results = chapters_matching(params[:query])

  erb :search
end

not_found do
  redirect "/"
end