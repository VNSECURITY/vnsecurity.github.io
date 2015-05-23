# encoding: utf-8
=begin

CategoryPagination allows Jekyll sites to have index pages for each category, and to break those 
category indexes into multiple pages.

This code belongs in the _plugins directory. 

The following items need to be true:

*   There is a file called "category_index.html" in the _layouts directory
*   In the _config.yml, there needs to be a line that says "pagination: true"
*   There needs to be an "index.html" page with "category: category-name" in the YAML front matter. 
    Be sure to use the actual category name.
    
For instance, if you wanted to have a paginated set of pages for all posts in the "recipes" 
category, place a file called "index.html" in the "recipes" directory. Make sure that in the 
YAML front matter, there is a line that says "category: recipes".

This plugin is structured so that each category index page can have its own unique landing page. 
For instance, a page showing all the recipes can be different than the page showing all the blog
entries. Subsequent pages (page 2 of the recipes, for example), use the category_index.html 
template. This is by design. Perhaps someday I'll add a parameter to the index page to specify
which template to use for sub-pages.

I have created a custom filter for displaying previous and next links on category pages.

=end

module Jekyll

  class Site

    attr_accessor :articles

		def reset
			self.articles = Array.new
		end
		
		alias_method :site_payload_articles, :site_payload
		def site_payload
			p = site_payload_articles
      p['site']['articles'] = self.articles
			p
		end

		alias_method :read_posts_articles, :read_posts
		def read_posts(dir)
		
      self.articles = Array.new

			read_posts_articles dir
			self.posts.each do |p| 
      
        if (not p.categories.include?('statuses') and not p.categories.include?('checkins') and not p.categories.include?('events'))
          self.articles << p
        end        
      
			end
			
			self.articles.sort_by! { |p| -p.date.to_f }
		
		end
  end

  class Pagination < Generator
    def generate(site)
    end
  end

  class CategoryPages < Generator
  
    CATEGORY_DIR = 'categories'

    safe true

    def generate(site)
      site.categories.keys.each do |category|
        paginate(site, category)
      end

    end

    def paginate(site, category)

      # sort categories by descending date of publish
      category_posts = site.categories[category].sort_by { |p| -p.date.to_f }

      # calculate total number of pages
      pages = CategoryPager.calculate_pages(category_posts, site.config['paginate'].to_i)

      category_base_dir = site.config['category_dir']

      # iterate over the total number of pages and create a physical page for each
      (1..pages).each do |num_page|
      
        # the CategoryPager handles the paging and category data
        pager = CategoryPager.new(site, num_page, category_posts, category, pages)

        # the first page is the index, so no page needs to be created. However, the subsequent pages need to be generated
        if num_page > 1
          newpage = CategorySubPage.new(site, site.source, category)
          newpage.pager = pager
          newpage.dir = File.join(CategoryPages.category_dir(category_base_dir, category) , "/page#{num_page}")
          site.pages << newpage
        else
          newpage = CategorySubPage.new(site, site.source, category)
          newpage.pager = pager
          newpage.dir = File.join(CategoryPages.category_dir(category_base_dir, category) , "/")
          site.pages << newpage
        end

      end
    end

    # Processes the given dir and removes leading and trailing slashes. Falls
    # back on the default if no dir is provided.
    def self.category_dir(base_dir, category)
      base_dir = (base_dir || CATEGORY_DIR).gsub(/^\/*(.*)\/*$/, '\1')
      category = category.gsub(/_|\P{Word}/, '-').gsub(/-{2,}/, '-').downcase
      File.join(base_dir, category)
    end

  end
  
  class CategoryPager < Paginate::Pager

    attr_reader :category

    def self.pagination_enabled?(config, page)
      page.name == 'index.html' && page.data.key?('category') && !config['paginate'].nil?
    end
    
    # same as the base class, but includes the category value
    def initialize(site, page, all_posts, category, num_pages = nil)
    	@category = category
      super site, page, all_posts, num_pages
    end

    # use the original to_liquid method, but add in category info
    alias_method :original_to_liquid, :to_liquid
    def to_liquid
      x = original_to_liquid
      x['category'] = @category
      x
    end
    
  end
  
  # The CategorySubPage class creates a single category page for the specified tag.
  # This class exists to specify the layout to use for pages after the first index page
  class CategorySubPage < Page
    
    def initialize(site, base, category, layout = nil)
        
      @site = site
      @base = base
      @dir  = category
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), layout || 'category_index.html')

      title_prefix             = site.config['cateogry_title_prefix'] || 'Everything in the '
      self.data['title']       = "#{title_prefix}#{category}"

    end
    
  end

  
  module Filters
  
  	def pager_links(pager)

		if pager['previous_page'] || pager['next_page']
  	  	
			html = '<div class="pager clearfix">'
			if pager['previous_page']
				
				if pager['previous_page'] == 1
					html << "<div class=\"previous\"><a href=\"/#{pager['category']}/\">&laquo; Newer posts</a></div>"
				else
					html << "<div class=\"previous\"><a href=\"/#{pager['category']}/page#{pager['previous_page']}\">&laquo; Newer posts</a></div>"
				end
	
			end
	
			if pager['next_page'] 
				html << "<div class=\"next\"><a href=\"/#{pager['category']}/page#{pager['next_page']}\">Older posts &raquo;</a></div>"
			end
			
			html << '</div>'
			html

		end

  	end
  
  end

end