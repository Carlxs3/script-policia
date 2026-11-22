local ibanCache = {}

function GetPlayerBankNumber(identifier, qbAccount)
    if qbAccount then return qbAccount end
    if not identifier then return "XXXXXXXXX" end

    if ibanCache[identifier] then return ibanCache[identifier] end

    local iban = MySQL.awaitScalar(
        'SELECT iban FROM ptg_bank_profiles WHERE identifier = ? LIMIT 1',
        { identifier }
    )

    if iban then
        ibanCache[identifier] = iban -- el IBAN no cambia, así que se cachea
        return iban
    end

    return "Sin cuenta"
end
exports("GetPlayerBankNumber", GetPlayerBankNumber)