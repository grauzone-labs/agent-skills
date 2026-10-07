def invoice_recipient(client):
    return client["legal_name"]


def payment_recipient(customer):
    return customer["legal_name"]


def receipt_recipient(account):
    return account["legal_name"]
