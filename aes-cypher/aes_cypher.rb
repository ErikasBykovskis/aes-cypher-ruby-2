# rubocop:disable Style/FrozenStringLiteralComment
# rubocop:disable Style/AsciiComments
# rubocop:disable Style/UnpackFirst
# rubocop:disable Style/AndOr

require 'openssl'
require 'digest/sha2'
require 'base64'

# Mes naudojame AES 256 bitų šifravimo blokų grandinės simetrinį šifravimą
alg = 'AES-256-CBC'

# Mes norime 256 bitų simetrinio rakto, pagrįsto tam tikra slapta fraze
digest = Digest::SHA256.new
digest.update('symetric key')
key = digest.digest
# Mes taip pat galėjome sukurti atsitiktinį raktą
# key = OpenSSL::Cipher::Cipher.new(alg).random_key

# Saugumui, kaip šifravimo algoritmo daliai, sukuriame atsitiktinį
# inicializavimo vektorių.
iv = OpenSSL::Cipher::Cipher.new(alg).random_iv

# Pavyzdžiui, deriname raktą išvesties įvairiais formatais
puts 'Key'
p key
# Base64 raktas
puts 'Key base 64'
key64 = [key].pack('m')
puts key64
# Base64 iššifruoja raktą
puts 'Our key retrieved from base64'
p key64.unpack('m')[0]
raise 'Key Error' if key.nil? or key.size != 32

# Dabar mes atliekame faktinį šifro nustatymą
aes = OpenSSL::Cipher::Cipher.new(alg)
aes.encrypt
aes.key = key
aes.iv = iv

# Dabar užšifruojame paprastą tekstą.
cipher = aes.update("Tai yra 1 eilutė\n")
cipher << aes.update('Tai yra kita eilutė be linijinio pertraukimo.')
cipher << aes.update('Tai seka iškart po taško.')
cipher << aes.update('Tas pats ir su šiuo paskutiniu sakiniu')
cipher << aes.final

puts 'Encrypted data in base64'
cipher64 = [cipher].pack('m')
puts cipher64

decode_cipher = OpenSSL::Cipher::Cipher.new(alg)
decode_cipher.decrypt
decode_cipher.key = key
decode_cipher.iv = iv
plain = decode_cipher.update(cipher64.unpack('m')[0])
plain << decode_cipher.final
puts 'Decrypted Text'
puts plain

# rubocop:enable Style/FrozenStringLiteralComment
# rubocop:enable Style/AsciiComments
# rubocop:enable Style/UnpackFirst
# rubocop:enable Style/AndOr
