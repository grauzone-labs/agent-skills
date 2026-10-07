"""Repository fixture: public API, product search, and order cancellation."""

API_KEYS = {"customer-key": "customer-1", "internal-key": "warehouse"}
INTERNAL_CLIENTS = {"warehouse"}
PRODUCTS = [{"id": 1, "name": "Tea", "price": 5}]
PRODUCT_CACHE = {}
ORDERS = {
    1: {"status": "draft", "paid": False},
    2: {"status": "confirmed", "paid": True},
}


def authenticate(headers, remote_ip):
    key = headers.get("X-API-Key")
    return {"client_id": API_KEYS.get(key), "ip": remote_ip}


def public_api(request):
    identity = authenticate(request["headers"], request["remote_ip"])
    if identity["client_id"] is None:
        return {"status": 401, "headers": {}, "body": "Unauthorized"}
    return {"status": 200, "headers": {}, "body": search(request["query"])}


def search(query):
    return [p.copy() for p in PRODUCTS if query.lower() in p["name"].lower()]


def product_details(product_id):
    if product_id not in PRODUCT_CACHE:
        PRODUCT_CACHE[product_id] = next(
            p.copy() for p in PRODUCTS if p["id"] == product_id
        )
    return PRODUCT_CACHE[product_id]


def update_price(product_id, price):
    next(p for p in PRODUCTS if p["id"] == product_id)["price"] = price
    PRODUCT_CACHE.pop(product_id, None)


def cancel_order(order_id):
    order = ORDERS[order_id]
    order["status"] = "void" if order["paid"] else "cancelled"


def support_void(order_id):
    ORDERS[order_id]["status"] = "void"
