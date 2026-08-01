module Forums::WebsitesHelper
  def external_url(url)
    url.match?(%r{\Ahttps?://}i) ? url : "https://#{url}"
  end
end
