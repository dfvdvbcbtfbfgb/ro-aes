local bit = bit32

-- AES-256 Encryption
function aes256_encrypt(key, plaintext)
    local function sub_word(word)
        local sbox = {
            0x63, 0x7C, 0x77, 0x7B, 0xF2, 0x6B, 0x6F, 0xC5, 0x30, 0x01, 0x67, 0x2B, 0xFE, 0xD7, 0xAB, 0x76,
            0xCA, 0x82, 0xC9, 0x7D, 0xFA, 0x59, 0x47, 0xF0, 0xAD, 0xD4, 0xA2, 0xAF, 0x9C, 0xA4, 0x72, 0xC0,
            0xB7, 0xFD, 0x93, 0x26, 0x36, 0x3F, 0xF7, 0xCC, 0x34, 0xA5, 0xE5, 0xF1, 0x71, 0xD8, 0x31, 0x15,
            0x04, 0xC7, 0x23, 0xC3, 0x18, 0x96, 0x05, 0x9A, 0x07, 0x12, 0x80, 0xE2, 0xEB, 0x27, 0xB2, 0x75,
            0x09, 0x83, 0x2C, 0x1A, 0x1B, 0x6E, 0x5A, 0xA0, 0x52, 0x3B, 0xD6, 0xB3, 0x29, 0xE3, 0x2F, 0x84,
            0x53, 0xD1, 0x00, 0xED, 0x20, 0xFC, 0xB1, 0x5B, 0x6A, 0xCB, 0xBE, 0x39, 0x4A, 0x4C, 0x58, 0xCF,
            0xD0, 0xEF, 0xAA, 0xFB, 0x43, 0x4D, 0x33, 0x85, 0x45, 0xF9, 0x02, 0x7F, 0x50, 0x3C, 0x9F, 0xA8,
            0x51, 0xA3, 0x40, 0x8F, 0x92, 0x9D, 0x38, 0xF5, 0xBC, 0xB6, 0xDA, 0x21, 0x10, 0xFF, 0xF3, 0xD2,
            0xCD, 0x0C, 0x13, 0xEC, 0x5F, 0x97, 0x44, 0x17, 0xC4, 0xA7, 0x7E, 0x3D, 0x64, 0x5D, 0x19, 0x73,
            0x60, 0x81, 0x4F, 0xDC, 0x22, 0x2A, 0x90, 0x88, 0x46, 0xEE, 0xB8, 0x14, 0xDE, 0x5E, 0x0B, 0xDB,
            0xE0, 0x32, 0x3A, 0x0A, 0x49, 0x06, 0x24, 0x5C, 0xC2, 0xD3, 0xAC, 0x62, 0x91, 0x95, 0xE4, 0x79,
            0xE7, 0xC8, 0x37, 0x6D, 0x8D, 0xD5, 0x4E, 0xA9, 0x6C, 0x56, 0xF4, 0xEA, 0x65, 0x7A, 0xAE, 0x08,
            0xBA, 0x78, 0x25, 0x2E, 0x1C, 0xA6, 0xB4, 0xC6, 0xE8, 0xDD, 0x74, 0x1F, 0x4B, 0xBD, 0x8B, 0x8A,
            0x70, 0x3E, 0xB5, 0x66, 0x48, 0x03, 0xF6, 0x0E, 0x61, 0x35, 0x57, 0xB9, 0x86, 0xC1, 0x1D, 0x9E,
            0xE1, 0xF8, 0x98, 0x11, 0x69, 0xD9, 0x8E, 0x94, 0x9B, 0x1E, 0x87, 0xE9, 0xCE, 0x55, 0x28, 0xDF,
            0x8C, 0xA1, 0x89, 0x0D, 0xBF, 0xE6, 0x42, 0x68, 0x41, 0x99, 0x2D, 0x0F, 0xB0, 0x54, 0xBB, 0x16
        }
        return bit.bxor(sbox[bit.band(bit.rshift(word, 24), 0xFF)], bit.lshift(sbox[bit.band(bit.rshift(word, 16), 0xFF)], 8),
                        bit.lshift(sbox[bit.band(bit.rshift(word, 8), 0xFF)], 16), bit.lshift(sbox[bit.band(word, 0xFF)], 24))
    end

    local function key_expansion(key)
        local rcon = {
            0x01, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00,
            0x10, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00,
            0x1B, 0x00, 0x00, 0x00, 0x36, 0x00, 0x00, 0x00, 0x6C, 0x00, 0x00, 0x00, 0xD8, 0x00, 0x00, 0x00,
            0xAB, 0x00, 0x00, 0x00, 0x4D, 0x00, 0x00, 0x00, 0x9A, 0x00, 0x00, 0x00, 0x2F, 0x00, 0x00, 0x00,
            0x5E, 0x00, 0x00, 0x00, 0xBC, 0x00, 0x00, 0x00, 0x63, 0x00, 0x00, 0x00, 0xC6, 0x00, 0x00, 0x00,
            0x97, 0x00, 0x00, 0x00, 0x35, 0x00, 0x00, 0x00, 0x6A, 0x00, 0x00, 0x00, 0xD4, 0x00, 0x00, 0x00,
            0xB3, 0x00, 0x00, 0x00, 0x7D, 0x00, 0x00, 0x00, 0xFA, 0x00, 0x00, 0x00, 0xEF, 0x00, 0x00, 0x00,
            0xC5, 0x00, 0x00, 0x00, 0x91, 0x00, 0x00, 0x00, 0x39, 0x00, 0x00, 0x00, 0x72, 0x00, 0x00, 0x00
        }
        local w = {}
        for i = 1, 8 do
            w[i] = bit.band(bit.lshift(key[i * 4 - 3], 24), 0xFF000000) + bit.band(bit.lshift(key[i * 4 - 2], 16), 0x00FF0000)
                + bit.band(bit.lshift(key[i * 4 - 1], 8), 0x0000FF00) + bit.band(key[i * 4], 0x000000FF)
        end
        for i = 9, 60 do
            local temp = w[i - 1]
            if i % 8 == 1 then
                temp = bit.bxor(sub_word(bit.rshift(temp, 8)), rcon[i / 8])
            elseif i % 8 == 5 then
                temp = sub_word(temp)
            end
            w[i] = bit.bxor(w[i - 8], temp)
        end
        return w
    end

    local function shift_rows(state)
        for row = 1, 4 do
            for shift = 1, row - 1 do
                state[row][1], state[row][2], state[row][3], state[row][4] = state[row][2], state[row][3], state[row][4], state[row][1]
            end
        end
        return state
    end

    local function mix_columns(state)
        local mul = {
            {0x02, 0x03, 0x01, 0x01},
            {0x01, 0x02, 0x03, 0x01},
            {0x01, 0x01, 0x02, 0x03},
            {0x03, 0x01, 0x01, 0x02}
        }
        local result = {}
        for col = 1, 4 do
            result[col] = {}
            for row = 1, 4 do
                result[col][row] = bit.bxor(bit.bxor(bit.bxor(bit.band(bit.lshift(mul[row][1], 1), 0xFF) * bit.band(bit.rshift(state[1][col], 7), 1),
                                                                 bit.band(bit.lshift(mul[row][2], 1), 0xFF) * bit.band(bit.rshift(state[2][col], 7), 1)),
                                                      bit.band(bit.lshift(mul[row][3], 1), 0xFF) * bit.band(bit.rshift(state[3][col], 7), 1)),
                                           bit.band(bit.lshift(mul[row][4], 1), 0xFF) * bit.band(bit.rshift(state[4][col], 7), 1))
                for i = 1, 3 do
                    state[i][col] = bit.band(bit.lshift(state[i][col], 1), 0xFE) + bit.band(bit.rshift(state[i + 1][col], 7), 1)
                end
                state[4][col] = bit.band(bit.lshift(state[4][col], 1), 0xFE) + bit.band(bit.rshift(result[col][row], 7), 1)
            end
        end
        return result
    end

    local function add_round_key(state, round_key)
        for col = 1, 4 do
            for row = 1, 4 do
                state[row][col] = bit.bxor(state[row][col], bit.rshift(round_key[col], (4 - row) * 8))
            end
        end
        return state
    end

    local function sub_bytes(state)
        for row = 1, 4 do
            for col = 1, 4 do
                local sbox = {
                    {0x63, 0x7C, 0x77, 0x7B, 0xF2, 0x6B, 0x6F, 0xC5, 0x30, 0x01, 0x67, 0x2B, 0xFE, 0xD7, 0xAB, 0x76},
                    {0xCA, 0x82, 0xC9, 0x7D, 0xFA, 0x59, 0x47, 0xF0, 0xAD, 0xD4, 0xA2, 0xAF, 0x9C, 0xA4, 0x72, 0xC0},
                    {0xB7, 0xFD, 0x93, 0x26, 0x36, 0x3F, 0xF7, 0xCC, 0x34, 0xA5, 0xE5, 0xF1, 0x71, 0xD8, 0x31, 0x15},
                    {0x04, 0xC7, 0x23, 0xC3, 0x18, 0x96, 0x05, 0x9A, 0x07, 0x12, 0x80, 0xE2, 0xEB, 0x27, 0xB2, 0x75},
                    {0x09, 0x83, 0x2C, 0x1A, 0x1B, 0x6E, 0x5A, 0xA0, 0x52, 0x3B, 0xD6, 0xB3, 0x29, 0xE3, 0x2F, 0x84},
                    {0x53, 0xD1, 0x00, 0xED, 0x20, 0xFC, 0xB1, 0x5B, 0x6A, 0xCB, 0xBE, 0x39, 0x4A, 0x4C, 0x58, 0xCF},
                    {0xD0, 0xEF, 0xAA, 0xFB, 0x43, 0x4D, 0x33, 0x85, 0x45, 0xF9, 0x02, 0x7F, 0x50, 0x3C, 0x9F, 0xA8},
                    {0x51, 0xA3, 0x40, 0x8F, 0x92, 0x9D, 0x38, 0xF5, 0xBC, 0xB6, 0xDA, 0x21, 0x10, 0xFF, 0xF3, 0xD2},
                    {0xCD, 0x0C, 0x13, 0xEC, 0x5F, 0x97, 0x44, 0x17, 0xC4, 0xA7, 0x7E, 0x3D, 0x64, 0x5D, 0x19, 0x73},
                    {0x60, 0x81, 0x4F, 0xDC, 0x22, 0x2A, 0x90, 0x88, 0x46, 0xEE, 0xB8, 0x14, 0xDE, 0x5E, 0x0B, 0xDB},
                    {0xE0, 0x32, 0x3A, 0x0A, 0x49, 0x06, 0x24, 0x5C, 0xC2, 0xD3, 0xAC, 0x62, 0x91, 0x95, 0xE4, 0x79},
                    {0xE7, 0xC8, 0x37, 0x6D, 0x8D, 0xD5, 0x4E, 0xA9, 0x6C, 0x56, 0xF4, 0xEA, 0x65, 0x7A, 0xAE, 0x08},
                    {0xBA, 0x78, 0x25, 0x2E, 0x1C, 0xA6, 0xB4, 0xC6, 0xE8, 0xDD, 0x74, 0x1F, 0x4B, 0xBD, 0x8B, 0x8A},
                    {0x70, 0x3E, 0xB5, 0x66, 0x48, 0x03, 0xF6, 0x0E, 0x61, 0x35, 0x57, 0xB9, 0x86, 0xC1, 0x1D, 0x9E},
                    {0xE1, 0xF8, 0x98, 0x11, 0x69, 0xD9, 0x8E, 0x94, 0x9B, 0x1E, 0x87, 0xE9, 0xCE, 0x55, 0x28, 0xDF},
                    {0x8C, 0xA1, 0x89, 0x0D, 0xBF, 0xE6, 0x42, 0x68, 0x41, 0x99, 0x2D, 0x0F, 0xB0, 0x54, 0xBB, 0x16}
                }
                state[row][col] = sbox[bit.band(bit.rshift(state[row][col], 4), 0x0F) + 1][bit.band(state[row][col], 0x0F) + 1]
            end
        end
        return state
    end

    local function encrypt_block(block, round_keys)
        local state = {
            {bit.band(bit.rshift(block[1], 24), 0xFF), bit.band(bit.rshift(block[2], 24), 0xFF), bit.band(bit.rshift(block[3], 24), 0xFF), bit.band(bit.rshift(block[4], 24), 0xFF)},
            {bit.band(bit.rshift(block[1], 16), 0xFF), bit.band(bit.rshift(block[2], 16), 0xFF), bit.band(bit.rshift(block[3], 16), 0xFF), bit.band(bit.rshift(block[4], 16), 0xFF)},
            {bit.band(bit.rshift(block[1], 8), 0xFF), bit.band(bit.rshift(block[2], 8), 0xFF), bit.band(bit.rshift(block[3], 8), 0xFF), bit.band(bit.rshift(block[4], 8), 0xFF)},
            {bit.band(block[1], 0xFF), bit.band(block[2], 0xFF), bit.band(block[3], 0xFF), bit.band(block[4], 0xFF)}
        }
        state = add_round_key(state, round_keys[1])
        for round = 2, 14 do
            state = sub_bytes(state)
            state = shift_rows(state)
            if round ~= 14 then
                state = mix_columns(state)
            end
            state = add_round_key(state, round_keys[round])
        end
        local output = {}
        for col = 1, 4 do
            for row = 1, 4 do
                output[col * 4 - (4 - row)] = state[row][col]
            end
        end
        return output
    end

    function aes256_encrypt(plaintext, key)
        local round_keys = expand_key(key)
        local encrypted_blocks = {}
        for i = 1, #plaintext / 16 do
            local block = {}
            for j = 1, 16 do
                block[j] = plaintext[(i - 1) * 16 + j]
            end
            local encrypted_block = encrypt_block(block, round_keys)
            for j = 1, 16 do
                encrypted_blocks[(i - 1) * 16 + j] = encrypted_block[j]
            end
        end
        return encrypted_blocks
    end
end

return aes256
