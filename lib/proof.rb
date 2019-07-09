# Taken from https://github.com/keybase/prove_keybase

module KeybaseProofs
  class Proof
    def initialize(username, kb_username, sig_hash)
      @username = username
      @kb_username = kb_username
      @sig_hash = sig_hash
      @domain = Discourse.base_url.sub(/^https?\:\/\//,'')
      @api_conn = Excon.new("https://keybase.io")
    end

    def valid?
      res = JSON.parse(@api_conn.get(
        :path => '/_/api/1.0/sig/proof_valid.json',
        :query => {
          :domain => @domain,
          :username => @username,
          :kb_username => @kb_username,
          :sig_hash => @sig_hash,
        },
      ).body)
      res.fetch('proof_valid', false)
    rescue
      false
    end

    def live?
      res = JSON.parse(@api_conn.get(
        :path => '/_/api/1.0/sig/proof_live.json',
        :query => {
          :domain => @domain,
          :username => @username,
          :kb_username => @kb_username,
          :sig_hash => @sig_hash,
        },
      ).body)
      res.fetch('proof_live', false)
    rescue
      false
    end

    def pic_url
      res = JSON.parse(@api_conn.get(
        :path => '/_/api/1.0/user/pic_url.json',
        :query => {
          :username => @kb_username,
        },
      ).body)
      res.fetch('pic_url')
    rescue KeyError
      "https://keybase.io/images/icons/icon-keybase-logo-64@2x.png"
    end

    def signature
      {
        kb_username: @kb_username,
        sig_hash: @sig_hash,
      }
    end
  end
end
