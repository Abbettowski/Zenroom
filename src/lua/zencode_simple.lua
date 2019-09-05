-- This file is part of Zenroom (https://zenroom.dyne.org)
--
-- Copyright (C) 2018-2019 Dyne.org foundation
-- designed, written and maintained by Denis Roio <jaromil@dyne.org>
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Affero General Public License as
-- published by the Free Software Foundation, either version 3 of the
-- License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Affero General Public License for more details.
--
-- You should have received a copy of the GNU Affero General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

-- make sure relevant defaults are there
CONF.curve = CONF.curve or 'goldilocks'
CONF.encoding = CONF.encoding or url64
CONF.encoding_prefix = CONF.encoding_prefix or 'u64'

local _ecdh = ECDH.new(CONF.curve) -- used for validation

ZEN.add_schema({
	  -- keypair (ECDH)
	  public_key = function(obj)
		 local o = obj.public_key or obj -- fix recursive schema check
		 if type(o) == "string" then o = ZEN:import(o) end
		 ZEN.assert(_ecdh:checkpub(o),
					"Public key is not a valid point on curve: "..CONF.curve)
		 return o
	  end,
      keypair = function(obj)
         return { public_key  = ZEN:validate_recur(obj, 'public_key'),
                  private_key = ZEN.get(obj, 'private_key') }
	  end,
	  secret_message = function(obj)
		 return { checksum = ZEN.get(obj, 'checksum'),
				  header   = ZEN.get(obj, 'header'),
				  iv       = ZEN.get(obj, 'iv'),
				  text     = ZEN.get(obj, 'text') }
	  end,
	  signed_message = function(obj)
		 return { r = ZEN.get(obj, 'r'),
				  s = ZEN.get(obj, 's'),
				  text = ZEN.get(obj, 'text') }
	  end
})

-- generate keypair
local function f_keygen()
   local kp
   local ecdh = ECDH.new(CONF.curve)
   kp = ecdh:keygen()
   ZEN:pick('keypair', { public_key = kp.public,
						 private_key = kp.private })
   ZEN:validate('keypair')
   ZEN:ack('keypair')
end
When("I create my new keypair", f_keygen)
When("I generate my keys", f_keygen)

-- encrypt with a header and secret
When("I encrypt the message with the secret", function()
		ZEN.assert(ACK.message, "Data to encrypt not found: message")
		ZEN.assert(ACK.secret, "Secret used to encrypt not found: secret")
		-- KDF2 sha256 on all secrets
		local secret = ECDH.kdf2(HASH.new('sha256'),ACK.secret)
		ACK.secret_message = { header = ACK.header or 'empty',
							   iv = O.random(32) }
		ACK.secret_message.text, ACK.secret_message.checksum =
		   ECDH.aead_encrypt(secret, ACK.message,
							 ACK.secret_message.iv,
							 ACK.secret_message.header)
end)

-- decrypt with a secret
When("I decrypt the secret message with the secret", function()
		ZEN.assert(ACK.secret, "Secret used to decrypt not found: secret")
		ZEN.assert(ACK.secret_message,
				   "Secret data to decrypt not found: secret message")

        local secret = ECDH.kdf2(HASH.new('sha256'),ACK.secret)
        -- KDF2 sha256 on all secrets, this way the
        -- secret is always 256 bits, safe for direct aead_decrypt
        ACK.message = { header = ACK.secret_message.header }
        ACK.message.text, ACK.checksum =
           ECDH.aead_decrypt(secret,
							 ACK.secret_message.text,
							 ACK.secret_message.iv,
							 ACK.message.header)
        ZEN.assert(ACK.checksum == ACK.secret_message.checksum,
                   "Decryption error: authentication failure, checksum mismatch")
end)

-- encrypt to a single public key
When("I encrypt the message for ''", function(_key)
		ZEN.assert(ACK.keypair, "Keys not found: keypair")
		ZEN.assert(ACK.keypair.private_key, "Private key not found in keypair")
		ZEN.assert(ACK.message, "Data to encrypt not found: message")
		ZEN.assert(type(ACK.public_key) == 'table',
				   "Public keys not found in keyring")
		ZEN.assert(ACK.public_key[_key], "Public key not found for: ".._key)
		local header = ACK.header or 'empty'
		local from = ECDH.new(CONF.curve)
		from:private(ACK.keypair.private_key)
		local to = ECDH.new(CONF.curve)
		to:public(ACK.public_key[_key])
		ACK.secret_message =
		   from:encrypt(to, ACK.message, header)
end)


When("I decrypt the secret message from ''", function(_key)
		ZEN.assert(ACK.keypair, "Keyring not found")
		ZEN.assert(ACK.keypair.private_key, "Private key not found in keyring")
		ZEN.assert(ACK.secret_message, "Data to decrypt not found: secret_message")
		ZEN.assert(ACK.public_key[_key],
				   "Key to decrypt not found: public key[".._key.."])")
		local recpt = ECDH.new(CONF.curve)
		recpt:private(ACK.keypair.private_key)
		ACK.secret_message.pubkey = ACK.public_key[_key]
		ACK.message = recpt:decrypt(ACK.secret_message)
end)

-- sign a message and verify
When("I sign the '' as ''", function(doc, dst)
		ZEN.assert(ACK.keypair, "Keyring not found")
		ZEN.assert(ACK.keypair.private_key, "Private key not found in keyring")
		local dsa = ECDH.new(CONF.curve)
		dsa:private(ACK.keypair.private_key)
		ACK[dst] = dsa:sign(ACK[doc])
		-- include contextual information
		ACK[dst].text = ACK[doc]
end)

When("I verify the '' is authentic", function(msg)
		ZEN.assert(ACK.public_key, "Public key not found")
		local dsa = ECDH.new(CONF.curve)
		dsa:public(ACK.public_key)
		local sm = ACK[msg]
		ZEN.assert(sm, "Signed message not found: "..msg)
		ZEN.assert(dsa:verify(sm.text,{ r = sm.r, s = sm.s }),
				   "The signature is not authentic")
end)
