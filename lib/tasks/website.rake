desc 'Generate website files'
task :website_generate do
  (Dir['website/**/*.txt'] - Dir['website/version*.txt']).each do |txt|
    sh %{ ruby script/txt2html README > #{txt.gsub(/txt$/,'html')} }
  end
end

desc 'Upload website files to rubyforge'
task :website_upload do
  host = "#{RUBY_FORGE_USER}@rubyforge.org"
  remote_dir = "/var/www/gforge-projects/#{RUBY_FORGE_PROJECT}/"
  local_dir = 'website'
  sh %{rsync -aCv #{local_dir}/ #{host}:#{remote_dir}}
end

desc 'Generate and upload website files'
task :website => [:website_generate, :website_upload, :publish_docs]
