# frozen_string_literal: true

require 'curb'
require 'fileutils'

class FileDownloader
  def self.download(uri, directory: Rails.root.join('tmp'), extension: nil, &block)
    content = Curl.get(uri).body_str

    name = "file-downloader-tmp-file-#{Digest::SHA256.hexdigest(content)}#{".#{extension}" if extension}"
    path = File.join(directory, name)

    File.binwrite(path, content)
    result = yield(path)

    FileUtils.rm(path)

    result
  end
end
