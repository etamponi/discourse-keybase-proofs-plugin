# frozen_string_literal: true

# name: KeybaseProofs
# about:
# version: 0.1
# authors: Emanuele Tamponi
# url: https://github.com/etamponi/discourse-keybase-proofs-plugin

enabled_site_setting :keybase_proofs_enabled

register_asset "stylesheets/common/keybase-proofs.scss"

DiscoursePluginRegistry.serialized_current_user_fields << "keybase_proofs"

after_initialize do
  load File.expand_path('../lib/proof.rb', __FILE__)

  load File.expand_path('../app/controllers/config_controller.rb', __FILE__)
  load File.expand_path('../app/controllers/proof_controller.rb', __FILE__)

  register_editable_user_custom_field [:keybase_proofs]

  module ::KeybaseProofs
    PLUGIN_NAME ||= "KeybaseProofs".freeze
  
    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace KeybaseProofs
    end
  end
  
  KeybaseProofs::Engine.routes.draw do
    get "/config" => "config#index"

    get "/new-proof/:username/:kb_username/:sig_hash" => "proof#new",
      :constraints => { :username => /[^\/]+/, :kb_username => /[^\/]+/ }
    
    post "/proofs" => "proof#create"
    get "/proofs" => "proof#check"
    delete "/proofs" => "proof#revoke"

    get "/pic-url" => "proof#pic_url"
  end
  
  Discourse::Application.routes.append do
    mount ::KeybaseProofs::Engine, at: "/keybase-proofs"
  end
end
