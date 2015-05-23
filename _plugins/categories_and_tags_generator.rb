# encoding: utf-8

module Jekyll

  class CatsAndTags < Generator
  
    safe true

    CATEGORY_DIR = 'category'
    TAG_DIR = 'tag'

    def generate(site)
      site.categories.each do |category|
        build_subpages(site, CATEGORY_DIR, category)
      end

      site.tags.each do |tag|
        build_subpages(site, TAG_DIR, tag)
      end
    end

    def build_subpages(site, type, posts) 
      posts[1] = posts[1].sort_by { |p| -p.date.to_f }     
      atomize(site, type, posts)
      paginate(site, type, posts)
    end

    def atomize(site, type, posts)
      path = CatsAndTags.dest_dir(type, posts[0])
      atom = AtomPage.new(site, site.source, path, type, posts[0], posts[1])
      site.pages << atom
    end

    def paginate(site, type, posts)
      pages = Paginate::Pager.calculate_pages(posts[1], site.config['paginate'].to_i)
      (1..pages).each do |num_page|
        pager = Paginate::Pager.new(site, num_page, posts[1], pages)
        path  = CatsAndTags.dest_dir(type, posts[0])
        if num_page > 1
          path = path + "/page#{num_page}"
        end
        newpage = GroupSubPage.new(site, site.source, path, type, posts[0])
        newpage.pager = pager
        site.pages << newpage 

      end
    end

    # Processes the given dir and removes leading and trailing slashes. Falls
    # back on the default if no dir is provided.
    def self.dest_dir(base_dir, category)
      base_dir = base_dir.gsub(/^\/*(.*)\/*$/, '\1')
      category = category.gsub(/_|\P{Word}/, '-').gsub(/-{2,}/, '-').downcase
      File.join(base_dir, category)
    end

    def self.category_dir(category)
      CatsAndTags.dest_dir(CATEGORY_DIR, category)
    end

    def self.tag_dir(tag)
      CatsAndTags.dest_dir(TAG_DIR, tag)
    end

  end

  class GroupSubPage < Page
    def initialize(site, base, dir, type, val)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), "group_index.html")
      self.data["grouptype"] = type
      self.data[type] = val
    end
  end
  
  class AtomPage < Page
    def initialize(site, base, dir, type, val, posts)
      @site = site
      @base = base
      @dir = dir
      @name = 'atom.xml'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), "group_atom.xml")
      self.data[type] = val
      self.data["grouptype"] = type
      self.data["posts"] = posts[0..9]
    end
  end

  class TagCloudTag < Liquid::Tag
    safe = true
    def initialize(tag_name, text, tokens)
      super
    end
 
    def render(context)
      html = ""
      tags = context.registers[:site].tags
      avg = tags.inject(0.0) {|memo, tag| memo += tag[1].length} / tags.length
      weights = Hash.new
      tags.each {|tag| weights[tag[0]] = [tag[1].length/avg, 3].min}
      tags.each do |tag, posts|
        if weights[tag] > 1
          html << "<span style='font-size: #{sprintf("%d", weights[tag] * 100)}%'><a href='/" + CatsAndTags.tag_dir(tag) + "'>#{tag}</a></span>\n"
        end
      end
      html
    end
end 

  # Adds some extra filters used during the category creation process.
  module Filters

    # Outputs a link to the given category.
    #
    #  +category+ is the category name
    #
    # Returns string
    def category_link(category)
        category_dir = CatsAndTags.category_dir(category)
        # Make sure the category directory begins with a slash.
        category_dir = "/#{category_dir}" unless category_dir =~ /^\//
        return "#{category_dir}/"
    end

    # Outputs the post.date as formatted html, with hooks for CSS styling.
    #
    #  +date+ is the date object to format as HTML.
    #
    # Returns string
    def date_to_html_string(date)
      result = '<span class="month">' + date.strftime('%b').upcase + '</span> '
      result += date.strftime('<span class="day">%d</span> ')
      result += date.strftime('<span class="year">%Y</span> ')
      result
    end

  end

end

Liquid::Template.register_tag('tag_cloud', Jekyll::TagCloudTag)
