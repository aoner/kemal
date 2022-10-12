require "exception_page"

module Kemal::Exceptions
  class Page < ExceptionPage
    def styles : ExceptionPage::Styles
      ExceptionPage::Styles.new(
        accent: "#f4994b",
        logo_uri: "data:image/png;base64,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"
      )
    end

    def project_url
      "https://amberframework.org"
    end
  end
end