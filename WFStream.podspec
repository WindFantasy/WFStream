Pod::Spec.new do |spec|
  spec.name         = "WFStream"
  spec.version      = "1.0.1"
  spec.summary      = "WFStream is for doing sequential stream things like JAVA."

  spec.homepage     = "https://github.com/WindFantasy/WFStream"
  spec.license      = "MIT"
  spec.author       = { "Jerry" => "windfant@sina.com" }
  spec.source       = { :git => "https://github.com/WindFantasy/WFStream.git", :tag => "#{spec.version}" }

  spec.source_files  = "**/*.{h,mm,m}"
  spec.exclude_files = "WFStreamTests"
  spec.public_header_files = "**/WFStream.h", "**/wf_stream.h"

end
