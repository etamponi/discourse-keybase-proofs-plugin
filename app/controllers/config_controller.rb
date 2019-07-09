# frozen_string_literal: true

module KeybaseProofs

  class ConfigController < ApplicationController

    skip_before_action :check_xhr

    def index
      # using base_url proxy to make experiments, since on dev base_url is on http.
      base_url = Discourse.base_url
      # ... like this one:
      # base_url = "https://example.com"

      render json: {
        version: 1,
        domain: base_url,
        display_name: SiteSetting.title,

        username: {
          re: "^[a-zA-Z0-9_]{2,20}$",
          min: 2,
          max: 20,
        },

        brand_color: "##{ColorScheme.hex_for_name('header_background', view_context.scheme_id)}",

        # Until we figure out how to provide custom SVGs, let's use these
        # hardcoded values.
        logo: {
          svg_black: "https://d11a6trkgmumsb.cloudfront.net/original/3X/e/b/ebee30bd98aef20357e4a177a5a1e45b877ce088.svg",
          svg_full: "https://d11a6trkgmumsb.cloudfront.net/original/3X/e/b/ebee30bd98aef20357e4a177a5a1e45b877ce088.svg",
        },

        description: SiteSetting.site_description,

        prefill_url: "#{base_url}/keybase-proofs/new-proof?kb_username=%{kb_username}&username=%{username}&sig_hash=%{sig_hash}&kb_ua=%{kb_ua}",

        profile_url: "#{base_url}/u/%{username}/summary",

        check_url: "#{base_url}/keybase-proofs/proofs?username=%{username}",
        check_path: ["signatures"],
        avatar_path: ["avatar"],

        contact: [SiteSetting.contact_email],
      }
    end

  end
  
end
