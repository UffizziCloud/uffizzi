# frozen_string_literal: true

module Octokit
  class Client
    module Contents
      def contents?(repo, options = {})
        options = options.dup
        repo_path = options.delete(:path)
        url = "#{Repository.path(repo)}/contents/#{repo_path}"
        head(url, options).nil?
      rescue Octokit::NotFound
        false
      end
    end
  end
end
