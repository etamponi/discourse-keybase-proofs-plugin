# frozen_string_literal: true

module KeybaseProofs

  class ConfigController < ApplicationController

    skip_before_action :check_xhr

    def index
      render json: {
        version: 1,
        domain: Discourse.base_url,
        display_name: SiteSetting.title,

        username: {
          re: "^[a-zA-Z0-9_]{2,20}$",
          min: 2,
          max: 20,
        },

        brand_color: "##{ColorScheme.hex_for_name('header_background', view_context.scheme_id)}",

        logo: {
          svg_full: UrlHelper.absolute(SiteSetting.site_manifest_icon_url),
        },

        description: SiteSetting.site_description,

        prefill_url: "#{Discourse.base_url}/keybase-proofs/new-proof?kb_username=%{kb_username}&username=%{username}&sig_hash=%{sig_hash}&kb_ua=%{kb_ua}",

        profile_url: "#{Discourse.base_url}/u/%{username}/summary",

        check_url: "#{Discourse.base_url}/keybase-proofs/proofs?username=%{username}",
        check_path: ["signatures"],
        avatar_path: ["avatar"],

        contact: [SiteSetting.contact_email],
      }
    end

  end
  
end
