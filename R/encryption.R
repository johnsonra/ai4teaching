# encryption functions for sqlite database

# Will need to generate or load a 32-byte key (store in 1Password or .Renviron)
# key <- sodium::random(32)
# Sys.setenv(ENCRYPTION_KEY = sodium::bin2hex(key))

#' encrypt_text
#' Encryption and decryption of text using the sodium library
#' 
#' @param plain_text Character vector to encrypt
#' @param key_hex Encryption key
#' 
#' @details You will need to generate a 32-byte key (or load one, e.g. from `.Renviron`). See examples below.
#' 
#' @examples
#' # set ENCRYPTION_KEY
#' key <- sodium::random(32)
#' Sys.setenv(ENCRYPTION_KEY = sodium::bin2hex(key))
#' 
#' # encrypt
#' (encrypted <- encrypt_text(c("Sensitive text to encrypt", "abc123")))
#' 
#' # decrypt
#' decrypt_text(encrypted)
#' 
#' @return Encrypted text
#' @export
#' @importFrom OPsecrets get_secret
encrypt_text <- function(plain_text, key_hex = get_secret("ENCRYPTION_KEY", "Private", "learnr", "key_hex"))
{
  encrypted_text <- character(length(plain_text))

  for(i in 1:length(plain_text))
  {
    encrypted_text[i] <- encrypt_text_one(plain_text[i])
  }

  return(encrypted_text)
}

#' encrypt_text_one
#' @rdname encrypt_text
#' 
#' @importFrom OPsecrets get_secret
#' @importFrom sodium bin2hex data_encrypt hex2bin random
encrypt_text_one <- function(plain_text, key_hex = get_secret("ENCRYPTION_KEY", "Private", "learnr", "key_hex"))
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
  plain_text <- character(length(hex_cipher))

  for(i in 1:length(hex_cipher))
  {
    plain_text[i] <- decrypt_text_one(hex_cipher[i])
  }

  return(plain_text)
}

#' decrypt_text_one
#' @rdname encrypt_text
#' 
#' @importFrom OPsecrets get_secret
#' @importFrom sodium data_decrypt hex2bin
decrypt_text_one <- function(hex_cipher, key_hex = get_secret("ENCRYPTION_KEY", "Private", "learnr", "key_hex"))
{
  if (is.na(hex_cipher) || is.null(hex_cipher)) return(NA_character_)

  key <- hex2bin(key_hex)
  cipher_raw <- hex2bin(hex_cipher)

  data_decrypt(cipher_raw[25:length(cipher_raw)], key, cipher_raw[1:24]) |>
    rawToChar()
}
