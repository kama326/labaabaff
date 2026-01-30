import redis
import time
import uuid
import sys

# Connect to Redis
try:
    r = redis.Redis(host='nosql_lab_redis', port=6379, decode_responses=True)
    r.ping()
    print("Connected to Redis!")
except Exception as e:
    print(f"Error connecting: {e}")
    sys.exit(1)

def login(username):
    # Generate token
    token = str(uuid.uuid4())
    # Create session with 10 seconds TTL
    r.set(f"session:{token}", username, ex=10)
    print(f"User {username} logged in. Token: {token}")
    return token

def check_session(token):
    username = r.get(f"session:{token}")
    if username:
        print(f"Session valid for user: {username}")
        # Refresh session
        r.expire(f"session:{token}", 10)
        return True
    else:
        print("Session expired or invalid.")
        return False

def add_to_cart(token, item):
    if not check_session(token):
        return
    
    username = r.get(f"session:{token}")
    cart_key = f"cart:{username}"
    r.rpush(cart_key, item)
    print(f"Added {item} to {username}'s cart.")

print("\n--- Day 2: Session Caching ---")

# 1. Login
token = login("jdoe")

# 2. Check Valid Session
check_session(token)

# 3. Add to Cart
add_to_cart(token, "Apple")
add_to_cart(token, "Banana")

# 4. View Cart
username = r.get(f"session:{token}")
items = r.lrange(f"cart:{username}", 0, -1)
print(f"Cart items: {items}")

# 5. Simulate Expiry
print("\nWaiting for session to expire (10s)...")
time.sleep(11)

check_session(token)
add_to_cart(token, "Orange") # Should fail
