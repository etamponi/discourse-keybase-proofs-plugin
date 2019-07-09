# frozen_string_literal: true

require 'rails_helper'

describe KeybaseProofs::ProofController do
  before do
    Jobs.run_immediately!
  end
  
  describe "POST /keybase-proofs/proof" do
    before do
      stub_request(:get, 'https://keybase.io/_/api/1.0/sig/proof_valid.json')
        .with(query: {
          :domain => Discourse.base_url.sub(/^https?\:\/\//,''),
          :username => "discourse_foobar",
          :kb_username => "kb_foobar",
          :sig_hash => "kb_signature_hash",
        })
        .to_return(body: { :proof_valid => true }.to_json, status: 200)

      stub_request(:get, 'https://keybase.io/_/api/1.0/sig/proof_valid.json')
        .with(query: {
          :domain => Discourse.base_url.sub(/^https?\:\/\//,''),
          :username => "discourse_foobar",
          :kb_username => "kb_quzbaz",
          :sig_hash => "kb_another_hash",
        })
        .to_return(body: { :proof_valid => true }.to_json, status: 200)

      stub_request(:get, 'https://keybase.io/_/api/1.0/sig/proof_valid.json')
        .with(query: {
          :domain => Discourse.base_url.sub(/^https?\:\/\//,''),
          :username => "discourse_foobar",
          :kb_username => "wrong_kb_username",
          :sig_hash => "wrong_kb_signature_hash",
        })
        .to_return(body: { :proof_valid => false }.to_json, status: 200)
    end

    it "can create proofs when they are valid" do
      user = Fabricate(:user, username: "discourse_foobar")
      sign_in(user)
  
      post "/keybase-proofs/proofs", params: {
        :kb_username => "kb_foobar",
        :sig_hash => "kb_signature_hash",
      }
      user.reload
      expect(response.status).to eq(200)
      expect(user.custom_fields['keybase_proofs']).to eq({
        kb_foobar: {
          kb_username: "kb_foobar",
          sig_hash: "kb_signature_hash",
        },
      }.to_json)
  
      # Add another identity and verify it saved both
      post "/keybase-proofs/proofs", params: {
        :kb_username => "kb_quzbaz",
        :sig_hash => "kb_another_hash",
      }
      user.reload
      expect(response.status).to eq(200)  
      expect(user.custom_fields['keybase_proofs']).to eq({
        kb_foobar: {
          kb_username: "kb_foobar",
          sig_hash: "kb_signature_hash",
        },
        kb_quzbaz: {
          kb_username: "kb_quzbaz",
          sig_hash: "kb_another_hash",
        },
      }.to_json)
    end
  
    it "fails to create a proof when it is not valid" do
      user = Fabricate(:user, username: "discourse_foobar")
      sign_in(user)
  
      post "/keybase-proofs/proofs", params: {
        :kb_username => "wrong_kb_username",
        :sig_hash => "wrong_kb_signature_hash",
      }
      expect(response.status).to eq(400)
      proofs = user.custom_fields['keybase_proofs']
      expect(proofs).to be(nil)
    end
  end

  describe "GET /keybase-proofs/proofs" do
    it "returns the user proofs" do      
      user = Fabricate(:user)
      user.custom_fields['keybase_proofs'] = {
        kb_username_1: {
          kb_username: 'kb_username_1',
          sig_hash: 'kb_signature_hash_1',
        },
        kb_username_2: {
          kb_username: 'kb_username_2',
          sig_hash: 'kb_signature_hash_2',
        },
      }.to_json
      user.save

      get '/keybase-proofs/proofs', params: {
        :username => user.username,
      }
      expect(response.status).to eq(200)
      expect(response.body).to eq({
        signatures: [{
          kb_username: 'kb_username_1',
          sig_hash: 'kb_signature_hash_1',
        }, {
          kb_username: 'kb_username_2',
          sig_hash: 'kb_signature_hash_2',
        }],
        avatar: KeybaseProofs::ProofController.user_avatar_url(user),
      }.to_json)
    end
  end

  describe "DELETE /keybase-proofs/proofs" do
    before do
      stub_request(:get, 'https://keybase.io/_/api/1.0/sig/proof_live.json')
        .with(query: {
          :domain => Discourse.base_url.sub(/^https?\:\/\//,''),
          :username => "discourse_foobar",
          :kb_username => "kb_username_1",
          :sig_hash => "kb_signature_hash_1",
        })
        .to_return(body: { :proof_valid => true, :proof_live => false }.to_json, status: 200)
    end

    it "revokes a proof" do
      user = Fabricate(:user, username: "discourse_foobar")
      user.custom_fields['keybase_proofs'] = {
        kb_username_1: {
          kb_username: 'kb_username_1',
          sig_hash: 'kb_signature_hash_1',
        },
        kb_username_2: {
          kb_username: 'kb_username_2',
          sig_hash: 'kb_signature_hash_2',
        },
      }.to_json
      user.save
      sign_in(user)

      delete "/keybase-proofs/proofs", params: {
        :kb_username => "kb_username_1",
      }
      user.reload
      expect(response.status).to eq(200)
      expect(user.custom_fields['keybase_proofs']).to eq({
        kb_username_2: {
          kb_username: 'kb_username_2',
          sig_hash: 'kb_signature_hash_2',
        },
      }.to_json)
    end
  end
end
