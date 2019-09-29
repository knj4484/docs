CONTENT_TOP_DIRS = %w(blog community docs download governance index webtools assets)

def find_translations(item, items)
  language_code = language_code(item)
  canonic_path = canonical_path(item)
  translation_items = items.find_all {|i| language_code(i) != language_code and canonical_path(i) == canonic_path }
  translation_items.map {|i| { :path => i.identifier.to_s, :language_code => language_code(i) } }
end

def langulage_path_prefix(item)
  top_dir = item.identifier.to_s.split('/')[1]
  language_code = (CONTENT_TOP_DIRS.include?(top_dir) or top_dir.nil?) ? '' : '/' + top_dir
end
def language_code(item)
  top_dir = item.identifier.to_s.split('/')[1]
  language_code = (CONTENT_TOP_DIRS.include?(top_dir) or top_dir.nil?) ? 'en' : top_dir
end

def canonical_path(item)
  prefix = langulage_path_prefix(item)
  item.identifier.to_s[prefix.length..-1]
end

def find_altanates(item, items)
  altanates = [
    {
      :hreflang => language_code(item),
      :path => item.path
    },
    {
      :hreflang => 'x-default',
      :path => canonical_path(item)
    }
  ]
  translations = find_translations(item, items).map do |t|
    {
      :hreflang => t[:language_code],
      :path => t[:path]
    }
  end
  altanates.concat(translations)
end