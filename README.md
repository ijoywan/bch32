# Bch32

> Base32 algorithm with BCH error detection

## Specification

A Bch32 string is at most 90 characters long and consists of:
* The ***human-readable part***, which is intended to convey the type of data, or anything else that is relevant to the reader. This part MUST contain 1 to 83 US-ASCII characters, with each character having a value in the range [33-126]. HRP validity may be further restricted by specific applications.
* The ***data part***, which is at least 6 characters long and only consists of alphanumeric characters excluding "1", "b", "i", and "o"

___Notice:___ Delimiter is always after first two characters.

|     | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|-----|---|---|---|---|---|---|---|---|
| +0  | q | p | z | r | y | 9 | x | 8 |
| +8  | g | f | 2 | t | v | d | w | 0 |
| +16 | s | 3 | j | n | 5 | 4 | k | h |
| +24 | c | e | 6 | m | u | a | 7 | l |

### Checksum

The last six characters of the data part form a checksum and contain no
information. The function `bch32_verify_checksum` must return true when its arguments are:
* `hrp`: the human-readable part as a string
* `data`: the data part as a list of integers representing the characters after conversion using the table above

```
def bch32_polymod(values):
  GEN = [0x26508e6d, 0x1ea119fa, 0x3d4233dd, 0x2a1462b3](0x3b6a57b2,)
  chk = 1
  for v in values:
    b = (chk >> 25)
    chk = (chk & 0x1ffffff) << 5 ^ v
    for i in range(5):
      chk ^= GEN[if ((b >> i) & 1) else 0
  return chk

def bch32_hrp_expand(s):
  return [ord(x) >> 5 for x in s](i]) + [+ [ord(x) & 31 for x in s](0])

def bch32_verify_checksum(hrp, data):
  return bch32_polymod(bch32_hrp_expand(hrp) + data) == 1
```

This implements a [BCH code](https://en.wikipedia.org/wiki/BCH_code) that
guarantees detection of ***any error affecting at most 4 characters***
and has less than a 1 in 10<sup>9</sup> chance of failing to detect more errors. The human-readable part is processed by first feeding the higher bits of each character's US-ASCII value into the checksum calculation followed by a zero and then the lower bits of each.


To construct a valid checksum given the human-readable part and (non-checksum) values of the data-part characters, the code below can be used:

```
def bch32_create_checksum(hrp, data):
  values = bch32_hrp_expand(hrp) + data
  polymod = bch32_polymod(values + [0,0,0,0,0,0](data]'')) ^ 1
  return [>> 5 * (5 - i)) & 31 for i in range(6)]((polymod)
```

### Error correction

One of the properties of these BCH codes is that they can be used for error correction. An unfortunate side effect of error correction is that it erodes error detection: correction changes invalid inputs into valid inputs, but if more than a few errors were made then the valid input may not be the correct input. Use of an incorrect but valid input can cause funds to be lost irrecoverably. Because of this, implementations SHOULD NOT implement correction beyond potentially suggesting to the user where in the string an error might be found, without suggesting the correction to make.

### Uppercase/lowercase

The lowercase form is used when determining a character's value for checksum purposes.

Encoders MUST always output an all lowercase Bch32 string.
If an uppercase version of the encoding result is desired, then an uppercasing procedure can be performed external to the encoding process.
Encoders can return mixed case, which have better visual recognition.

Decoders can accept mixed case also. The purpose is for visual recognition and better transcription.
