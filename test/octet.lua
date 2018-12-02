print()
print '= OCTET FIRST CLASS CITIZEN TESTS'
print()

-- octet = require'octet'

function dotest(l,r,reason)
   if(l == r
	  and
	  #l == #r) then
	  return true
   else
	  print 'ERROR'
	  print 'left:'
	  print(l)
	  print 'right:'
	  print(r)
	  assert(false, reason)
   end
end

-- random and  check hash of octets
-- ecdh = require'ecdh'
right = OCTET.string([[Minim quis typewriter ut. Deep v ut man braid neutra culpa in officia consectetur tousled art party stumptown yuccie. Elit lo-fi pour-over woke venmo keffiyeh in normcore enim sunt labore williamsburg flexitarian. Tumblr distillery fanny pack, banjo tacos vaporware keffiyeh.]])
teststr = right:string()
test64  = right:base64()
test58  = right:base58()
testhex = right:hex()

print '== test octet copy'
left = right;
hash = HASH.new()
dotest(left, right)
dotest(hash:process(left),hash:process(right))

print '== test string import/export'
left = OCTET.string(teststr)
print '=== compare octets'
dotest(left, right)
print '=== compare strings'
dotest(left:string(), teststr)
print '=== compare hashes'
dotest(hash:process(left), hash:process(right))

print '== test base64 import/export'
left = OCTET.base64(test64)
dotest(left, right)
dotest(left:base64(), test64)
dotest(hash:process(left), hash:process(right))

print '== test base58 import/export'
left = OCTET.base58(test58)
dotest(left, right)
dotest(left:base58(), test58)
dotest(hash:process(left), hash:process(right))


print '== test hex import/export'
left = OCTET.hex(testhex)
dotest(left, right)
dotest(left:hex(), testhex)
dotest(hash:process(left), hash:process(right))

-- print '= OK'


print '== ECP import/export'
rng = RNG.new()
left = INT.new(rng,ECP.order()) * ECP.generator() -- ECP point aka pub key
b64 = left:octet():base64()
-- print(b64)
right = base64(b64)
-- print(right:base64())
dotest(left:octet(),right)
print '== JSON import/export'
function jsontest(f,reason)
   str = JSON.encode({public = f(left)})
   right = JSON.decode(str)
   dotest(left:octet(),f(right['public']),reason)
   ECP.new(f(right['public'])) -- test if ecp point on curve
end
jsontest(base64,"base64")
jsontest(hex,"hex")
jsontest(base58,"base58")
-- jsontest(bin,"bin") -- TODO: fix

-- more testing using crypto verification of pub/priv keypair
function jsoncryptotest(f)
   local key = {}
   key.private = INT.new(rng,ECP.order())
   key.public = key.private * ECP.G()
   str = JSON.encode({private = _G[f](key.private)})
   dstr = L.property('private')(JSON.decode(str))
   doct = _G[f](dstr)
   assert(doct == key.private, "Error importing to OCTET from "..f..":\n"
			 .._G[f](doct).."\n".._G[f](key.private))
   dint = BIG.new(_G[f](dstr))
   assert(dint * ECP.G() == key.public, "Error importing to BIG from "..f..":\n"
			 .._G[f](dint).."\n".._G[f](key.private))
end
jsoncryptotest('hex')
jsoncryptotest('base64')
jsoncryptotest('base58')
-- jsoncryptotest('bin') -- TODO: fix
print '= OK'


