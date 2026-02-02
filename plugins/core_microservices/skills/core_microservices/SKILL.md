---
name: core_microservices
description: "微服務架構模式專家。專精於服務拆分、服務通訊、API Gateway、服務治理、分散式事務、微服務安全、可觀測性。關鍵字: microservices, 微服務, service mesh, api gateway, distributed system, 分散式系統, 服務治理"
---

# Microservices (微服務) 架構專家

您是一位微服務架構專家，專精於設計、實作及營運分散式微服務系統。

## 概述

微服務架構將應用程式組織為一組鬆散耦合、可獨立部署的服務集合。每個服務專注於特定的業務能力，可以獨立開發、部署和擴展。

**核心能力:**
- 服務拆分策略
- 服務間通訊 (REST, gRPC, Messaging)
- API Gateway 模式
- Service Discovery (服務發現) 與 Load Balancing (負載均衡)
- 分散式事務管理 (Saga Pattern)
- 微服務安全
- Observability (可觀測性)：日誌、指標、追蹤

## 何時使用此技能

當使用者遇到以下情境時啟用此技能：
- 設計微服務架構 (關鍵字: "microservices", "微服務架構", "服務拆分")
- 實作服務通訊 (關鍵字: "service communication", "服務通訊", "api gateway")
- 處理分散式事務 (關鍵字: "distributed transaction", "分散式事務", "saga")
- 需要服務發現 (關鍵字: "service discovery", "服務發現", "consul")
- 實作可觀測性 (關鍵字: "observability", "可觀測性", "monitoring")

## 核心概念

### 1. 服務拆分

**依業務能力拆分:**
```
E-commerce System
├── User Service (Authentication, Profile)
├── Product Service (Catalog, Inventory)
├── Order Service (Order Management)
├── Payment Service (Payment Processing)
├── Shipping Service (Delivery Management)
└── Notification Service (Email, SMS)
```

**依子領域拆分 (DDD 方法):**
```
Core Domain:
- Order Management Service
- Product Catalog Service

Supporting Domain:
- User Management Service
- Payment Service

Generic Domain:
- Notification Service
- Reporting Service
```

### 2. 服務通訊模式

**同步 - REST:**
```java
@RestController
@RequestMapping("/api/orders")
public class OrderController {

    @Autowired
    private RestTemplate restTemplate;

    @PostMapping
    public OrderDTO createOrder(@RequestBody OrderRequest request) {
        // Call User Service
        String userServiceUrl = "http://user-service/api/users/" + request.getUserId();
        UserDTO user = restTemplate.getForObject(userServiceUrl, UserDTO.class);

        // Call Product Service
        String productServiceUrl = "http://product-service/api/products/" + request.getProductId();
        ProductDTO product = restTemplate.getForObject(productServiceUrl, ProductDTO.class);

        // Create order
        Order order = new Order(user, product);
        return orderService.create(order);
    }
}
```

**同步 - gRPC:**
```protobuf
syntax = "proto3";

service UserService {
  rpc GetUser (GetUserRequest) returns (UserResponse);
  rpc CreateUser (CreateUserRequest) returns (UserResponse);
}

message GetUserRequest {
  int64 user_id = 1;
}

message UserResponse {
  int64 id = 1;
  string name = 2;
  string email = 3;
}
```

**非同步 - Message Queue (訊息佇列):**
```java
// Publisher
@Service
public class OrderService {

    @Autowired
    private RabbitTemplate rabbitTemplate;

    public void createOrder(Order order) {
        orderRepository.save(order);

        // Publish event
        OrderCreatedEvent event = new OrderCreatedEvent(order.getId(), order.getUserId());
        rabbitTemplate.convertAndSend("order.exchange", "order.created", event);
    }
}

// Consumer
@Component
public class InventoryEventListener {

    @RabbitListener(queues = "inventory.queue")
    public void handleOrderCreated(OrderCreatedEvent event) {
        // Reserve inventory
        inventoryService.reserve(event.getOrderId());
    }
}
```

### 3. API Gateway 模式

**Spring Cloud Gateway:**
```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: user-service
          uri: lb://user-service
          predicates:
            - Path=/api/users/**
          filters:
            - StripPrefix=1
            - AuthenticationFilter

        - id: order-service
          uri: lb://order-service
          predicates:
            - Path=/api/orders/**
          filters:
            - StripPrefix=1
            - RateLimitFilter
```

**自訂 Gateway Filter:**
```java
@Component
public class AuthenticationFilter implements GlobalFilter, Ordered {

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        String token = exchange.getRequest().getHeaders().getFirst("Authorization");

        if (token == null || !validateToken(token)) {
            exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
            return exchange.getResponse().setComplete();
        }

        return chain.filter(exchange);
    }

    @Override
    public int getOrder() {
        return -100;
    }
}
```

### 4. 分散式事務 - Saga Pattern (Saga 模式)

**Choreography-based Saga (編排式 Saga):**
```java
// Order Service
@Service
public class OrderService {

    @Autowired
    private EventPublisher eventPublisher;

    @Transactional
    public void createOrder(OrderRequest request) {
        Order order = new Order(request);
        order.setStatus(OrderStatus.PENDING);
        orderRepository.save(order);

        // Publish event
        eventPublisher.publish(new OrderCreatedEvent(order.getId()));
    }

    @EventListener
    public void handlePaymentCompleted(PaymentCompletedEvent event) {
        Order order = orderRepository.findById(event.getOrderId());
        order.setStatus(OrderStatus.PAID);
        orderRepository.save(order);

        eventPublisher.publish(new OrderPaidEvent(order.getId()));
    }

    @EventListener
    public void handlePaymentFailed(PaymentFailedEvent event) {
        Order order = orderRepository.findById(event.getOrderId());
        order.setStatus(OrderStatus.CANCELLED);
        orderRepository.save(order);
    }
}

// Payment Service
@Service
public class PaymentService {

    @EventListener
    public void handleOrderCreated(OrderCreatedEvent event) {
        try {
            Payment payment = processPayment(event.getOrderId());
            eventPublisher.publish(new PaymentCompletedEvent(event.getOrderId()));
        } catch (Exception e) {
            eventPublisher.publish(new PaymentFailedEvent(event.getOrderId()));
        }
    }
}
```

**Orchestration-based Saga (協調式 Saga):**
```java
@Service
public class OrderSagaOrchestrator {

    public void createOrder(OrderRequest request) {
        String sagaId = UUID.randomUUID().toString();

        try {
            // Step 1: Create order
            Order order = orderService.createOrder(request);

            // Step 2: Reserve inventory
            inventoryService.reserve(order.getId());

            // Step 3: Process payment
            paymentService.process(order.getId());

            // Step 4: Arrange shipping
            shippingService.arrange(order.getId());

            // Success
            order.setStatus(OrderStatus.COMPLETED);

        } catch (Exception e) {
            // Compensating transactions
            compensate(sagaId);
        }
    }

    private void compensate(String sagaId) {
        shippingService.cancel(sagaId);
        paymentService.refund(sagaId);
        inventoryService.release(sagaId);
        orderService.cancel(sagaId);
    }
}
```

### 5. Service Discovery (服務發現)

**Eureka Client:**
```java
@SpringBootApplication
@EnableDiscoveryClient
public class UserServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(UserServiceApplication.class, args);
    }
}
```

```yaml
eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka/
  instance:
    prefer-ip-address: true
    instance-id: ${spring.application.name}:${spring.application.instance_id:${random.value}}
```

### 6. Circuit Breaker (斷路器)

**Resilience4j:**
```java
@Service
public class OrderService {

    @CircuitBreaker(name = "paymentService", fallbackMethod = "paymentFallback")
    @Retry(name = "paymentService")
    @TimeLimiter(name = "paymentService")
    public CompletableFuture<Payment> processPayment(Order order) {
        return CompletableFuture.supplyAsync(() ->
            paymentClient.process(order.getId(), order.getTotalAmount())
        );
    }

    private CompletableFuture<Payment> paymentFallback(Order order, Exception ex) {
        log.error("Payment service unavailable for order: {}", order.getId());
        return CompletableFuture.completedFuture(
            Payment.failed(order.getId(), "Service temporarily unavailable")
        );
    }
}
```

### 7. Distributed Tracing (分散式追蹤)

**設定:**
```yaml
management:
  tracing:
    sampling:
      probability: 1.0
  zipkin:
    tracing:
      endpoint: http://localhost:9411/api/v2/spans

logging:
  pattern:
    level: '%5p [${spring.application.name:},%X{traceId:-},%X{spanId:-}]'
```

### 8. Centralized Configuration (集中式設定)

**Config Server:**
```yaml
spring:
  cloud:
    config:
      server:
        git:
          uri: https://github.com/your-org/config-repo
          default-label: main
```

**Config Client:**
```yaml
spring:
  application:
    name: user-service
  config:
    import: configserver:http://localhost:8888
```

## 常見模式與範例

### 模式 1: Database per Service (每服務一資料庫)

```
User Service → User Database (PostgreSQL)
Order Service → Order Database (MySQL)
Product Service → Product Database (MongoDB)
```

**優點:**
- 鬆散耦合
- 獨立擴展
- 技術多樣性

**挑戰:**
- 資料一致性
- 跨服務的複雜查詢

### 模式 2: Shared Database (共享資料庫) (反模式)

避免在服務之間共享資料庫，因為這會造成緊密耦合。

### 模式 3: Event-Driven Architecture (事件驅動架構)

```java
// Event Store
@Entity
public class DomainEvent {
    @Id
    private String id;
    private String aggregateId;
    private String eventType;
    private String payload;
    private LocalDateTime occurredAt;
}

// Event Publisher
@Service
public class EventPublisher {

    @Autowired
    private KafkaTemplate<String, DomainEvent> kafkaTemplate;

    public void publish(DomainEvent event) {
        kafkaTemplate.send("domain-events", event.getAggregateId(), event);
    }
}

// Event Listener
@Component
public class OrderEventListener {

    @KafkaListener(topics = "domain-events", groupId = "order-service")
    public void handleEvent(DomainEvent event) {
        if ("PaymentCompleted".equals(event.getEventType())) {
            orderService.markAsPaid(event.getAggregateId());
        }
    }
}
```

### 模式 4: CQRS (命令查詢職責分離)

```java
// Command Side
@Service
public class OrderCommandService {

    public OrderId createOrder(CreateOrderCommand command) {
        Order order = new Order(command);
        orderRepository.save(order);
        eventPublisher.publish(new OrderCreatedEvent(order.getId()));
        return order.getId();
    }
}

// Query Side (Denormalized)
@Service
public class OrderQueryService {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public List<OrderSummary> findRecentOrders() {
        return jdbcTemplate.query(
            "SELECT * FROM order_summary_view ORDER BY created_at DESC LIMIT 10",
            (rs, rowNum) -> new OrderSummary(...)
        );
    }
}
```

## 最佳實踐

### 1. 服務獨立性
- 每個服務應擁有自己的資料庫
- 服務應可獨立部署
- 避免共享函式庫 (優先使用 API 契約)

### 2. API 版本控制
```java
@RestController
@RequestMapping("/api/v1/users")
public class UserV1Controller {
    // Version 1 API
}

@RestController
@RequestMapping("/api/v2/users")
public class UserV2Controller {
    // Version 2 API
}
```

### 3. Health Check (健康檢查)
```java
@Component
public class CustomHealthIndicator implements HealthIndicator {

    @Override
    public Health health() {
        if (checkDatabaseConnection() && checkExternalService()) {
            return Health.up()
                .withDetail("database", "Connected")
                .withDetail("externalService", "Available")
                .build();
        }
        return Health.down().build();
    }
}
```

### 4. Graceful Degradation (優雅降級)
```java
@Service
public class RecommendationService {

    @CircuitBreaker(name = "mlService", fallbackMethod = "getDefaultRecommendations")
    public List<Product> getRecommendations(Long userId) {
        return mlServiceClient.getRecommendations(userId);
    }

    private List<Product> getDefaultRecommendations(Long userId, Exception ex) {
        // Return popular products as fallback
        return productService.getPopularProducts();
    }
}
```

### 5. Idempotency (冪等性)
```java
@Service
public class PaymentService {

    public Payment processPayment(String idempotencyKey, PaymentRequest request) {
        // Check if already processed
        Optional<Payment> existing = paymentRepository.findByIdempotencyKey(idempotencyKey);
        if (existing.isPresent()) {
            return existing.get();
        }

        // Process payment
        Payment payment = new Payment(idempotencyKey, request);
        return paymentRepository.save(payment);
    }
}
```

### 6. Monitoring and Alerting (監控與告警)
```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  metrics:
    export:
      prometheus:
        enabled: true
    tags:
      application: ${spring.application.name}
```

### 7. Security (安全性)
```java
// JWT Token Validation in Gateway
@Component
public class JwtAuthenticationFilter implements GlobalFilter {

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        String token = extractToken(exchange.getRequest());

        if (!jwtUtil.validateToken(token)) {
            exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
            return exchange.getResponse().setComplete();
        }

        // Add user context to request headers
        ServerHttpRequest modifiedRequest = exchange.getRequest().mutate()
            .header("X-User-Id", jwtUtil.getUserId(token))
            .build();

        return chain.filter(exchange.mutate().request(modifiedRequest).build());
    }
}
```

## 快速參考

### 微服務特性

| 特性 | 說明 |
|------|------|
| **可獨立部署** | 每個服務可在不影響其他服務的情況下部署 |
| **圍繞業務能力組織** | 服務與業務領域對齊 |
| **去中心化資料管理** | 每個服務擁有自己的資料 |
| **基礎設施自動化** | CI/CD、容器化 |
| **為失敗而設計** | Circuit Breaker (斷路器)、Retry (重試)、Fallback (後備方案) |

### 通訊模式

| 模式 | 使用場景 | 技術 |
|------|----------|------|
| **同步 REST** | 簡單查詢、CRUD 操作 | Spring Web, RestTemplate |
| **gRPC** | 高效能、型別安全 | gRPC, Protocol Buffers |
| **非同步訊息** | 事件驅動、解耦合 | RabbitMQ, Kafka |
| **GraphQL** | 彈性查詢、行動應用 | Spring GraphQL |

### 常見反模式

1. **Distributed Monolith (分散式單體)** - 服務之間耦合過緊
2. **Chatty Services (多話服務)** - 過多的服務間呼叫
3. **Shared Database (共享資料庫)** - 違反獨立性原則
4. **No API Gateway (缺少 API 閘道)** - 用戶端複雜度過高
5. **Lack of Monitoring (缺乏監控)** - 無法進行問題排查

### 工具與技術

- **Service Discovery (服務發現):** Eureka, Consul, Kubernetes
- **API Gateway (API 閘道):** Spring Cloud Gateway, Kong, Nginx
- **Message Queue (訊息佇列):** RabbitMQ, Kafka, AWS SQS
- **Tracing (追蹤):** Zipkin, Jaeger, AWS X-Ray
- **Monitoring (監控):** Prometheus, Grafana, ELK

---

**請記住:** 微服務會增加系統複雜度。只有在需要獨立擴展、獨立部署及團隊自主性時，才應採用此架構。
