# frozen_string_literal: true

module KeybaseProofs

  class ProofController < ApplicationController

    requires_login only: [:create, :revoke]
    skip_before_action :check_xhr, except: [:new]

    def new
    end

    # This is ugly: but I get a CORS error if I try to fetch the pic url from the client
    def pic_url
      kb_username = params.fetch("kb_username")
      # we don't need the sig_hash here
      proof = Proof.new(current_user.username, kb_username, "")
      render json: {
        pic_url: proof.pic_url,
      }
    end

    def create
      kb_username = params.fetch('kb_username')
      sig_hash = params.fetch('sig_hash')

      proof = Proof.new(current_user.username, kb_username, sig_hash)
      unless proof.valid?
        raise Discourse::InvalidParameters, I18n.t('keybase_proofs.invalid_proof')
      end

      proofs = JSON.parse(current_user.custom_fields['keybase_proofs'] || "{}")
      # Override the signature because the old one might have been
      # revoked and not yet updated on our side.
      proofs[kb_username] = proof.signature

      current_user.custom_fields["keybase_proofs"] = proofs.to_json
      current_user.save
      
      render json: success_json
    end

    def check
      user = fetch_user_from_params
      proofs = JSON.parse(user.custom_fields['keybase_proofs'] || "{}")
      render json: {
        signatures: proofs.values,
        avatar: ProofController.user_avatar_url(user),
      }
    end

    def revoke
      kb_username = params.fetch('kb_username')

      proofs = JSON.parse(current_user.custom_fields['keybase_proofs'] || "{}")
      sig = proofs.delete(kb_username)

      current_user.custom_fields['keybase_proofs'] = proofs.to_json
      current_user.save

      # Hit the Keybase endpoint so they know immediately that the proof is no longer live
      proof = Proof.new(current_user.username, sig['kb_username'], sig['sig_hash'])
      proof.live?

      render json: success_json
    end

    def self.user_avatar_url(user)
      UrlHelper.absolute(user.avatar_template.gsub('{size}', '360'))
    end

  end

end
