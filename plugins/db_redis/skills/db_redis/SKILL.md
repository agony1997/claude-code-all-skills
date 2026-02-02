---
name: db_redis
description: "Redis 快取與資料結構專家。專精於快取策略、資料結構 (String/Hash/List/Set/ZSet)、發布訂閱、分散式鎖、Redis Cluster、效能優化。關鍵字: redis, cache, 快取, pub/sub, distributed lock, 分散式鎖, session"
---

# Redis 專家

你是一位 Redis 專家，專精於快取策略、資料結構、發布/訂閱（Pub/Sub）訊息傳遞、分散式鎖（Distributed Lock）以及高效能 Redis 操作。

## 概述

Redis 是一種記憶體內資料結構儲存系統，可作為資料庫、快取、訊息代理（Message Broker）和串流引擎（Streaming Engine）使用。它支援多種資料結構，並提供亞毫秒級的延遲。

**核心能力：**
- 快取策略（Cache-Aside、Write-Through、Write-Behind）
- 資料結構（String、Hash、List、Set、Sorted Set、Bitmap、HyperLogLog）
- 發布/訂閱訊息傳遞（Pub/Sub Messaging）
- 分散式鎖（Distributed Locks）
- Redis Cluster 與 Sentinel
- 效能優化

## 何時使用此技能

當使用者有以下需求時啟用此技能：
- 實作快取（關鍵字: "redis", "cache", "快取", "caching strategy"）
- 使用資料結構（關鍵字: "hash", "list", "set", "zset", "sorted set"）
- 實作發布/訂閱（關鍵字: "pub/sub", "publish", "subscribe", "發布訂閱"）
- 需要分散式鎖（關鍵字: "distributed lock", "分散式鎖", "redlock"）
- 儲存 Session（關鍵字: "session", "會話", "session store"）
- 實作限流（關鍵字: "rate limit", "限流"）

## 核心概念

### 1. String 操作

**基本 String 指令：**
```bash
# Set and get
SET key value
GET key

# Set with expiration
SETEX session:123 3600 "user_data"  # Expires in 3600 seconds
SET key value EX 3600

# Set if not exists
SETNX lock:resource 1

# Multiple operations
MSET key1 value1 key2 value2
MGET key1 key2

# Increment/Decrement
INCR counter
INCRBY counter 5
DECR counter
INCRBYFLOAT price 10.5

# Append
APPEND key " more data"

# Get and Set
GETSET key newvalue
```

**使用情境：**
```bash
# Page view counter
INCR page:views:article:123

# Rate limiting (simple)
SET rate:limit:user:123 1 EX 60 NX
# If returns 1, allow; if returns 0, deny

# Cache user data
SETEX user:profile:123 3600 '{"name":"John","email":"john@example.com"}'
```

### 2. Hash 操作

**Hash 指令：**
```bash
# Set field
HSET user:123 name "John Doe"
HSET user:123 email "john@example.com" age 30

# Get field
HGET user:123 name

# Get all fields
HGETALL user:123

# Multiple fields
HMSET user:123 name "John" age 30 city "NY"
HMGET user:123 name age

# Check field exists
HEXISTS user:123 email

# Delete field
HDEL user:123 age

# Increment field
HINCRBY user:123 login_count 1

# Get all keys/values
HKEYS user:123
HVALS user:123
```

**使用情境：**
```bash
# Store user profile
HSET user:123 name "John" email "john@example.com" age 30

# Shopping cart
HSET cart:user:123 product:1 2  # Product 1, quantity 2
HSET cart:user:123 product:5 1
HGETALL cart:user:123

# Session store
HSET session:abc123 user_id 123 username "john" last_active 1706342400
EXPIRE session:abc123 3600
```

### 3. List 操作

**List 指令：**
```bash
# Push
LPUSH mylist "item1"  # Push to left
RPUSH mylist "item2"  # Push to right

# Pop
LPOP mylist
RPOP mylist

# Blocking pop (wait if empty)
BLPOP mylist 30  # Wait up to 30 seconds

# Range
LRANGE mylist 0 -1  # Get all
LRANGE mylist 0 9   # Get first 10

# Length
LLEN mylist

# Index
LINDEX mylist 0  # Get first item

# Insert
LINSERT mylist BEFORE "item2" "new_item"

# Trim
LTRIM mylist 0 99  # Keep only first 100 items
```

**使用情境：**
```bash
# Message queue
LPUSH queue:emails "email1"
RPOP queue:emails  # Process from other end

# Recent activities (latest 100)
LPUSH activity:user:123 "logged_in"
LTRIM activity:user:123 0 99

# Task queue with blocking
BLPOP queue:tasks 0  # Wait indefinitely for new task
```

### 4. Set 操作

**Set 指令：**
```bash
# Add members
SADD myset "member1" "member2"

# Remove member
SREM myset "member1"

# Check membership
SISMEMBER myset "member1"

# Get all members
SMEMBERS myset

# Count
SCARD myset

# Random member
SRANDMEMBER myset
SPOP myset  # Remove and return random

# Set operations
SINTER set1 set2  # Intersection
SUNION set1 set2  # Union
SDIFF set1 set2   # Difference
```

**使用情境：**
```bash
# Tags
SADD post:123:tags "redis" "cache" "database"
SMEMBERS post:123:tags

# Online users
SADD online:users "user:123" "user:456"
SREM online:users "user:123"  # User logged out
SISMEMBER online:users "user:123"  # Check if online

# Unique visitors
SADD visitors:2024-01-27 "user:123" "user:456"
SCARD visitors:2024-01-27  # Count unique visitors

# Find common friends
SINTER friends:user:123 friends:user:456
```

### 5. Sorted Set 操作

**Sorted Set 指令：**
```bash
# Add with score
ZADD leaderboard 100 "player1"
ZADD leaderboard 200 "player2" 150 "player3"

# Get rank
ZRANK leaderboard "player1"  # 0-based rank (ascending)
ZREVRANK leaderboard "player1"  # Descending rank

# Get score
ZSCORE leaderboard "player1"

# Increment score
ZINCRBY leaderboard 10 "player1"

# Range by rank
ZRANGE leaderboard 0 9  # Top 10 (ascending)
ZREVRANGE leaderboard 0 9  # Top 10 (descending)
ZREVRANGE leaderboard 0 9 WITHSCORES

# Range by score
ZRANGEBYSCORE leaderboard 100 200

# Count
ZCARD leaderboard
ZCOUNT leaderboard 100 200  # Count between scores

# Remove
ZREM leaderboard "player1"
ZREMRANGEBYRANK leaderboard 0 9  # Remove bottom 10
```

**使用情境：**
```bash
# Leaderboard
ZADD leaderboard:game 9500 "player1" 8700 "player2"
ZREVRANGE leaderboard:game 0 9 WITHSCORES  # Top 10

# Priority queue
ZADD tasks $(date +%s) "task1"  # Use timestamp as score
ZRANGE tasks 0 0  # Get highest priority (oldest)

# Trending posts (score = views)
ZINCRBY trending:posts 1 "post:123"
ZREVRANGE trending:posts 0 9  # Top 10 trending

# Time-based expiration
ZADD expiring:keys $(date +%s) "key1"
ZREMRANGEBYSCORE expiring:keys 0 $(date +%s)  # Remove expired
```

### 6. 快取策略

**Cache-Aside 模式（旁路快取）：**
```python
def get_user(user_id):
    # Try cache first
    user = redis.get(f"user:{user_id}")
    if user:
        return json.loads(user)

    # Cache miss, load from DB
    user = db.query("SELECT * FROM users WHERE id = ?", user_id)

    # Store in cache
    redis.setex(f"user:{user_id}", 3600, json.dumps(user))

    return user

def update_user(user_id, data):
    # Update database
    db.execute("UPDATE users SET ... WHERE id = ?", user_id)

    # Invalidate cache
    redis.delete(f"user:{user_id}")
```

**Write-Through 模式（直寫快取）：**
```python
def save_user(user_id, data):
    # Write to cache
    redis.setex(f"user:{user_id}", 3600, json.dumps(data))

    # Write to database
    db.execute("INSERT/UPDATE users ...", data)
```

**快取擊穿防護（Cache Stampede Prevention）：**
```python
import time
import random

def get_data(key):
    # Try cache
    data = redis.get(key)
    if data:
        return data

    # Acquire lock to prevent stampede
    lock_key = f"lock:{key}"
    if redis.setnx(lock_key, 1):
        redis.expire(lock_key, 10)  # Lock timeout

        try:
            # Load from database
            data = load_from_database(key)

            # Store in cache
            redis.setex(key, 3600, data)

            return data
        finally:
            redis.delete(lock_key)
    else:
        # Wait for lock holder to populate cache
        time.sleep(random.uniform(0.01, 0.1))
        return get_data(key)  # Retry
```

### 7. 分散式鎖

**簡易鎖（正式環境請使用 Redlock）：**
```python
import time
import uuid

class RedisLock:
    def __init__(self, redis_client, lock_name, timeout=10):
        self.redis = redis_client
        self.lock_name = f"lock:{lock_name}"
        self.timeout = timeout
        self.identifier = str(uuid.uuid4())

    def acquire(self):
        end_time = time.time() + self.timeout
        while time.time() < end_time:
            if self.redis.set(self.lock_name, self.identifier, nx=True, ex=self.timeout):
                return True
            time.sleep(0.001)
        return False

    def release(self):
        # Lua script for atomic check-and-delete
        script = """
        if redis.call("get", KEYS[1]) == ARGV[1] then
            return redis.call("del", KEYS[1])
        else
            return 0
        end
        """
        self.redis.eval(script, 1, self.lock_name, self.identifier)

# Usage
lock = RedisLock(redis_client, "resource:123")
if lock.acquire():
    try:
        # Critical section
        process_resource()
    finally:
        lock.release()
```

### 8. 發布/訂閱（Pub/Sub）

**發布者/訂閱者：**
```python
# Publisher
import redis

r = redis.Redis()
r.publish('notifications', 'Hello, World!')

# Subscriber
pubsub = r.pubsub()
pubsub.subscribe('notifications')

for message in pubsub.listen():
    if message['type'] == 'message':
        print(f"Received: {message['data']}")

# Pattern subscription
pubsub.psubscribe('news.*')
```

**使用情境：**
```python
# Chat application
r.publish('chat:room:123', json.dumps({
    'user': 'John',
    'message': 'Hello everyone!'
}))

# Real-time notifications
r.publish('notifications:user:123', json.dumps({
    'type': 'order_shipped',
    'order_id': 'ORD-456'
}))
```

### 9. Spring Boot 整合

**組態設定：**
```yaml
spring:
  redis:
    host: localhost
    port: 6379
    password: ${REDIS_PASSWORD}
    database: 0
    jedis:
      pool:
        max-active: 8
        max-idle: 8
        min-idle: 0
    timeout: 3000ms
```

**Redis Template：**
```java
@Configuration
public class RedisConfig {

    @Bean
    public RedisTemplate<String, Object> redisTemplate(RedisConnectionFactory factory) {
        RedisTemplate<String, Object> template = new RedisTemplate<>();
        template.setConnectionFactory(factory);

        // JSON serialization
        Jackson2JsonRedisSerializer<Object> serializer = new Jackson2JsonRedisSerializer<>(Object.class);
        template.setValueSerializer(serializer);
        template.setKeySerializer(new StringRedisSerializer());

        return template;
    }
}

@Service
public class UserCacheService {

    @Autowired
    private RedisTemplate<String, Object> redisTemplate;

    public void cacheUser(User user) {
        String key = "user:" + user.getId();
        redisTemplate.opsForValue().set(key, user, 1, TimeUnit.HOURS);
    }

    public User getUser(Long userId) {
        String key = "user:" + userId;
        return (User) redisTemplate.opsForValue().get(key);
    }

    public void deleteUser(Long userId) {
        redisTemplate.delete("user:" + userId);
    }
}
```

**@Cacheable 註解：**
```java
@Service
public class ProductService {

    @Cacheable(value = "products", key = "#id")
    public Product getProduct(Long id) {
        // This will be cached
        return productRepository.findById(id);
    }

    @CachePut(value = "products", key = "#product.id")
    public Product updateProduct(Product product) {
        return productRepository.save(product);
    }

    @CacheEvict(value = "products", key = "#id")
    public void deleteProduct(Long id) {
        productRepository.deleteById(id);
    }

    @CacheEvict(value = "products", allEntries = true)
    public void clearAllProducts() {
        // Clear all products cache
    }
}
```

## 最佳實踐

### 1. Key 命名規範
```bash
# Use colon as delimiter
user:123:profile
order:456:items
session:abc123

# Include type
string:user:123
hash:cart:456
list:queue:emails
```

### 2. 設定過期時間
```bash
# Always set TTL for cache data
SETEX key 3600 value
EXPIRE key 3600
```

### 3. 使用 Pipeline 進行批次操作
```python
pipe = redis.pipeline()
for i in range(1000):
    pipe.set(f"key:{i}", f"value:{i}")
pipe.execute()
```

### 4. 監控記憶體使用量
```bash
INFO memory
MEMORY USAGE key
```

### 5. 使用適當的資料結構
- String：簡單的鍵值對、計數器
- Hash：具有欄位的物件
- List：佇列、最近項目
- Set：唯一項目、標籤
- Sorted Set：排行榜、優先佇列

## 快速參考

### 常用指令
```bash
# Keys
SET key value
GET key
DEL key
EXISTS key
EXPIRE key seconds
TTL key
KEYS pattern  # Avoid in production
SCAN cursor

# Hash
HSET key field value
HGET key field
HGETALL key

# List
LPUSH key value
RPOP key
LRANGE key start stop

# Set
SADD key member
SMEMBERS key

# Sorted Set
ZADD key score member
ZRANGE key start stop
ZREVRANGE key start stop

# Other
PUBLISH channel message
SUBSCRIBE channel
```

### 資料型別選擇

| 使用情境 | 資料型別 |
|----------|-----------|
| 簡單快取 | String |
| 使用者個人資料 | Hash |
| 訊息佇列 | List |
| 標籤、追蹤者 | Set |
| 排行榜 | Sorted Set |
| 即時訊息傳遞 | Pub/Sub |
| Session 儲存 | Hash 搭配 TTL |
| 限流 | String 搭配 INCR |
| 分散式鎖 | String 搭配 NX |

---

**請記住：** Redis 之所以快速，是因為它在記憶體中運作。請務必設定適當的過期時間，並監控記憶體使用量以避免 OOM（Out of Memory）錯誤。
