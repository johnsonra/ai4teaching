# encryption functions for sqlite database

# Will need to generate or load a 32-byte key (store in .Renviron)
# key <- sodium::random(32)
# Sys.setenv(ENCRYPTION_KEY = sodium::bin2hex(key))

#' encrypt_text
#' Encrypt text using the sodium library
#' 
#' @param plain_text Character string to encrypt
#' @param key_hex Encryption key
#' 
#' @details You will need to generate a 32-byte key (or load one, e.g. from `.Renviron`). See examples below.
#' @examples
#' # set ENCRYPTION_KEY
#' key <- sodium::random(32)
#' Sys.setenv(ENCRYPTION_KEY = sodium::bin2hex(key))
#' 
#' # encrypt
#' (encrypted <- encrypt_text("Sensitive text to encrypt"))
#' 
#' # decrypt
#' decrypt_text(encrypted)
#' 
#' @return Encrypted text
#' @export
#' @importFrom OPsecrets get_secret
#' @importFrom sodium data_encrypt hex2bin random
encrypt_text <- function(plain_text, key_hex = get_secret("ENCRYPTION_KEY", "Private", "learnr", "key_hex"))
{
  if (is.na(plain_text) || is.null(plain_text)) return(NA_character_)

  key <- hex2bin(key_hex)
  nonce <- sodium::random(24)
  msg <- charToRaw(plain_text)

  cipher <- data_encrypt(msg, key, nonce)

  c(nonce, cipher) |> 
    bin2hex()
}

#' decrypt_text
#' Decrypt text using the sodium library
#' @rdname encrypt_text
#' 
#' @param hex_cipher Character string to decrypt
#' 
#' @return Decrypted text
#' @export
#' @importFrom OPsecrets get_secret
#' @importFrom sodium data_decrypt hex2bin
decrypt_text <- function(hex_cipher, key_hex = get_secret("ENCRYPTION_KEY", "Private", "learnr", "key_hex"))
{
  if (is.na(hex_cipher) || is.null(hex_cipher)) return(NA_character_)

  key <- hex2bin(key_hex)
  cipher_raw <- hex2bin(hex_cipher)

  data_decrypt(cipher_raw[25:length(cipher_raw)], key, cipher_raw[1:24]) |>
    rawToChar()
}
